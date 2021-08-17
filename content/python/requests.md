---
title: "Requests"
date: 2021-07-15T15:04:14+08:00
draft: false
toc: false
categories: []
tags: []
---

## requests 模块

HTTP 协议接口的请求调用

#### 安装, 引用

```
pip install requests
```

```
import requests
```

#### 测试URL

```
https://httpbin.org/post
```

#### GET 请求

发送数据: 

以下为postman 请求示例
```
{
    "args": {
        "arg1": "arg_1"
    },
    "headers": {
        "Accept": "*/*",
        "Accept-Encoding": "gzip, deflate, br",
        "Content-Length": "24",
        "Content-Type": "application/json",
        "Host": "httpbin.org",
        "Postman-Token": "187197c1-effa-4b4b-a499-7c3d66bc9049",
        "User-Agent": "PostmanRuntime/7.26.8",
        "X-Amzn-Trace-Id": "Root=1-60efdcf5-2c52d3eb46a1e19520fe108c"
    },
    "origin": "113.232.142.231",
    "url": "http://httpbin.org/get?arg1=arg_1"
}
```

#### POST 请求

发送数据

以下为postman 请求示例

```
{
    "args": {
        "p ": "1"
    },
    "data": "{\n    \"json\": \"123456\"\n}",
    "files": {},
    "form": {},
    "headers": {
        "Accept": "*/*",
        "Accept-Encoding": "gzip, deflate, br",
        "Content-Length": "24",
        "Content-Type": "application/json",
        "Host": "httpbin.org",
        "Postman-Token": "187879a8-fe0f-45a0-a94e-cf0b1d8e5184",
        "User-Agent": "PostmanRuntime/7.26.8",
        "X-Amzn-Trace-Id": "Root=1-60eff356-44291b474115a4e2111fbec4"
    },
    "json": {
        "json": "123456"
    },
    "origin": "113.232.142.231",
    "url": "http://httpbin.org/post?p =1"
}
```

对比GET请求 ， POST 数据发送数据更丰富

除了args 外还包括 data 、 files 、 form

注意：header 中的 Content-Type

#### python 示例

```
import requests
import json

class RequestTest(object):

    def __init__(self,baseUrl):
        self.url = baseUrl
        self.headers = {
            "User-Agent": "User-Agent':'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.132 Safari/537.36 QIHU 360SE",
            # "Content-Type": "application/json",
        }

    def httpGetTest(self, data, path='get'):
        r = requests.get(self.url+"/"+path, headers=self.headers, params=data)
        return r

    def httpPostTest(self, path="post",files=None,data=None,args=None,form=None):
        r = requests.post(self.url+"/"+path, headers=self.headers,params=args,data=form,json=json.dumps(data),files=files)
        return r


if __name__ == '__main__':
    rt = RequestTest("http://httpbin.org")
    # 测试GET 请求
    # args = {"key1": "value1","key2": "value2"}
    # r = rt.httpGetTest(args)
    # print(r.status_code)
    # print(r.text)

    # # 测试POST 请求
    rt.headers = {
        "User-Agent": "User-Agent':'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.132 Safari/537.36 QIHU 360SE",
        # "Content-Type": "application/json", # data
        "Content-Type": "application/x-www-form-urlencoded", # form
        # "Content-Type": "multipart/form-data;", #form
    }
    args = {"key1": "value1","key2": "value2"}
    data = {"name" : "zhangsan"}
    files = [
        ("a", ("a", open("/tmp/a", "rb"))),
    ]
    form = {"fk1": "fv1"}
    # r = rt.httpPostTest(args=args,data=data,files=files,form=form)
    r = rt.httpPostTest(args=args,form=form)
    print(r.status_code)
    print(r.text)
```
