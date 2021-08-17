---
title: "使用curl命令操作elasticsearch"
date: 2019-10-16T08:49:46+08:00
draft: false
---

第一：_cat系列

```
_cat系列提供了一系列查询elasticsearch集群状态的接口。你可以通过执行
curl -XGET localhost:9200/_cat
获取所有_cat系列的操作
=^.^=
/_cat/allocation
/_cat/shards
/_cat/shards/{index}
/_cat/master
/_cat/nodes
/_cat/indices
/_cat/indices/{index}
/_cat/segments
/_cat/segments/{index}
/_cat/count
/_cat/count/{index}
/_cat/recovery
/_cat/recovery/{index}
/_cat/health
/_cat/pending_tasks
/_cat/aliases
/_cat/aliases/{alias}
/_cat/thread_pool
/_cat/plugins
/_cat/fielddata
/_cat/fielddata/{fields}

你也可以后面加一个v，让输出内容表格显示表头，举例

curl -XGET  http://10.1.80.85:9200/_cat/indices?v
health status index                     uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   filebeat-7.3.2-2019.09.27 agrhjW7KR_ObgdwrUOpJMA   1   1     218974            0    181.8mb           91mb
```

第二：_cluster系列

```
1、查询设置集群状态
curl -XGET localhost:9200/_cluster/health?pretty=true
pretty=true表示格式化输出
level=indices 表示显示索引状态
level=shards 表示显示分片信息
2、curl -XGET localhost:9200/_cluster/stats?pretty=true
显示集群系统信息，包括CPU JVM等等
3、curl -XGET localhost:9200/_cluster/state?pretty=true
集群的详细信息。包括节点、分片等。
3、curl -XGET localhost:9200/_cluster/pending_tasks?pretty=true
获取集群堆积的任务
3、修改集群配置
举例：

curl -XPUT localhost:9200/_cluster/settings -d '{
    "persistent" : {
        "discovery.zen.minimum_master_nodes" : 2
    }
}'
transient 表示临时的，persistent表示永久的
4、curl -XPOST ‘localhost:9200/_cluster/reroute’ -d ‘xxxxxx’
对shard的手动控制，参考http://zhaoyanblog.com/archives/687.html
5、关闭节点
关闭指定192.168.1.1节点
curl -XPOST ‘http://192.168.1.1:9200/_cluster/nodes/_local/_shutdown’
curl -XPOST ‘http://localhost:9200/_cluster/nodes/192.168.1.1/_shutdown’
关闭主节点
curl -XPOST ‘http://localhost:9200/_cluster/nodes/_master/_shutdown’
关闭整个集群
$ curl -XPOST ‘http://localhost:9200/_shutdown?delay=10s’
$ curl -XPOST ‘http://localhost:9200/_cluster/nodes/_shutdown’
$ curl -XPOST ‘http://localhost:9200/_cluster/nodes/_all/_shutdown’
delay=10s表示延迟10秒关闭
```

第三：_nodes系列

```
1、查询节点的状态
curl -XGET ‘http://localhost:9200/_nodes/stats?pretty=true’
curl -XGET ‘http://localhost:9200/_nodes/192.168.1.2/stats?pretty=true’
curl -XGET ‘http://localhost:9200/_nodes/process’
curl -XGET ‘http://localhost:9200/_nodes/_all/process’
curl -XGET ‘http://localhost:9200/_nodes/192.168.1.2,192.168.1.3/jvm,process’
curl -XGET ‘http://localhost:9200/_nodes/192.168.1.2,192.168.1.3/info/jvm,process’
curl -XGET ‘http://localhost:9200/_nodes/192.168.1.2,192.168.1.3/_all
curl -XGET ‘http://localhost:9200/_nodes/hot_threads
```

第四：索引操作

```
1、获取索引
curl -XGET ‘http://localhost:9200/{index}/{type}/{id}’
2、索引数据
curl -XPOST ‘http://localhost:9200/{index}/{type}/{id}’ -d'{“a”:”avalue”,”b”:”bvalue”}’
3、删除索引
curl -XDELETE ‘http://localhost:9200/{index}/{type}/{id}’
4、设置mapping

curl -XPUT http://localhost:9200/{index}/{type}/_mapping -d '{
  "{type}" : {
	"properties" : {
	  "date" : {
		"type" : "long"
	  },
	  "name" : {
		"type" : "string",
		"index" : "not_analyzed"
	  },
	  "status" : {
		"type" : "integer"
	  },
	  "type" : {
		"type" : "integer"
	  }
	}
  }
}'
5、获取mapping
curl -XGET http://localhost:9200/{index}/{type}/_mapping
6、搜索

curl -XGET 'http://localhost:9200/{index}/{type}/_search' -d '{
    "query" : {
        "term" : { "user" : "kimchy" } //查所有 "match_all": {}
    },
	"sort" : [{ "age" : {"order" : "asc"}},{ "name" : "desc" } ],
	"from":0,
	"size":100
}
curl -XGET 'http://localhost:9200/{index}/{type}/_search' -d '{
    "filter": {"and":{"filters":[{"term":{"age":"123"}},{"term":{"name":"张三"}}]},
	"sort" : [{ "age" : {"order" : "asc"}},{ "name" : "desc" } ],
	"from":0,
	"size":100
}

```
