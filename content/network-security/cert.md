---
title: "自签名证书"
date: 2018-10-22T11:05:47+08:00
draft: false
---

1.环境预备

 curl -s -L -o /usr/local/bin/cfssl https://pkg.cfssl.org/R1.2/cfssl_linux-amd64  
 curl -s -L -o /usr/local/bin/cfssljson https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64  
 chmod +x /usr/local/bin/{cfssl,cfssljson}

2.生成配置模板

 三类证书：服务器证书server cert，客户端证书client cert，对等证书peer cert(表示既是server cert又是client cert)

 cfssl print-defaults config > ca-config.json  
 cat ca-config.json

```
{
    "signing": {
        "default": {
            "expiry": "168h"
        },
        "profiles": {
            "www": {
                "expiry": "8760h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "server auth"
                ]
            },
            "client": {
                "expiry": "8760h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "client auth"
                ]
            }
        }
    }
}

``` 

修改模板, 包括三种类型的证书

```
{
    "signing": {
        "default": {
            "expiry": "43800h"
        },
        "profiles": {
            "server": {
                "expiry": "43800h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "server auth"
                ]
            },
            "client": {
                "expiry": "43800h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "client auth"
                ]
            },
            "peer": {
                "expiry": "43800h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "server auth",
                    "client auth"
                ]
            }
        }
    }
}
```
　
生成ca证书模板 
cfssl print-defaults csr > ca-csr.json 
cat ca-csr.json 
```
{
    "CN": "example.net",
    "hosts": [
        "example.net",
        "www.example.net"
    ],
    "key": {
        "algo": "ecdsa",
        "size": 256
    },
    "names": [
        {
            "C": "US",
            "L": "CA",
            "ST": "San Francisco"
        }
    ]
}
```

修改ca 模板
```
{
    "CN": "My own CA",
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "US",
            "L": "CA",
            "O": "My Company Name",
            "ST": "San Francisco",
            "OU": "Org Unit 1",
            "OU": "Org Unit 2"
        }
    ]
}
```
C=country, O=organization, OU=organizational unit, CN=common name

3.创建证书 

3.1 ca证书 
cfssl gencert -initca ca-csr.json | cfssljson -bare ca - 

将得到三个文件  
ca-key.pem  #ca私钥,保存好,不要丢失或泄露  
ca.csr  
ca.pem  　  #ca公钥 

3.2 服务端证书 

cat server.json  
```
{
    "CN": "eamon",
    "hosts": [
        "www.zhangeamon.top"
    ],
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "US",
            "L": "CA",
            "ST": "San Francisco"
        }
    ]
}

```

cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=server server.json | cfssljson -bare server

将得到三个文件,包括服务端私钥、公钥  
server-key.pem  
server.csr  
server.pem  

3.3 依据此法创建客户端证书和对等证书 

4．验证 

openssl x509 -in ca.pem -text -noout  
openssl x509 -in server.pem -text -noout  
openssl x509 -in client.pem -text -noout 

[参见](https://coreos.com/os/docs/latest/generate-self-signed-certificates.html) 
