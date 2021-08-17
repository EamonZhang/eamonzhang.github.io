---
title: "go grpc"
date: 2020-08-13T10:06:19+08:00
draft: false
---

python 实现

cat Server.py 
```
from SimpleXMLRPCServer import SimpleXMLRPCServer
def fun_add(a,b):
    total = a+b
    return total

if __name__=='__main__':
    s = SimpleXMLRPCServer(('0.0.0.0',8081))
    s.register_function(fun_add)
    print "server in on line"
    s.serve_forever()
```

cat Client.py 
```
from xmlrpclib import ServerProxy
s = ServerProxy("http://xx.xxx.xxx.xxx:8081")
print s.fun_add(1,2)
```

go 实现

