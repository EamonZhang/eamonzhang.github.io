---
title: "Postgres 监控"
date: 2018-12-06T16:21:08+08:00
draft: false
---

#### 各种监控方式

- [zabbix](https://github.com/cavaliercoder/libzbxpgsql)  Monitor PostgreSQL with Zabbix

- [postgres_exporter](https://github.com/wrouesnel/postgres_exporter)  A PostgresSQL metric exporter for Prometheus

- [pgwatch2](https://github.com/cybertec-postgresql/pgwatch2) PostgreSQL metrics monitor/dashboard

- [pgmetrics](https://github.com/rapidloop/pgmetrics) Collect and display information and stats from a running PostgreSQL server 

- [pgdash](https://pgdash.io/)  (收费)

- [pganalyze](https://pganalyze.com) PostgreSQL Performance Monitoring

- [参考自己实现](https://yq.aliyun.com/live/927) 


#### 状态查看
[pgcenter](https://github.com/lesovsky/pgcenter)


```
pgcenter top
pgcenter: 2018-12-20 11:10:25, load average: 0.94, 0.84, 0.86                                                                         state [ok]: ::1:5432 postgres@postgres (ver: 10.6, up 8 days 19:57:54, recovery: f)
    %cpu: 15.0 us,  3.7 sy,  0.0 ni, 75.3 id,  5.7 wa,  0.0 hi,  0.2 si,  0.0 st                                                        activity:  5/1000 conns,  0/0 prepared,  2 idle,  0 idle_xact,  3 active,  0 waiting,  0 others
 MiB mem:   7821 total,    162 free,    424 used,     7235 buff/cached                                                                autovacuum:  0/3 workers/max,  0 manual,  0 wraparound, 00:00:00 vac_maxtime
MiB swap:   1023 total,    903 free,    120 used,      0/0 dirty/writeback                                                            statements: 1888 stmt/s, 2.330 stmt_avgtime, 00:00:00 xact_maxtime, 00:00:00 prep_maxtime      

pid     cl_addr      cl_port   datname       usename    appname    backend_type        wait_etype   wait_event     state    xact_age   query_age         change_age        query           
27908   ::1          40204     postgres      postgres   pgcenter   client backend                                  active   00:00:00   00:00:00          00:00:00          SELECT pid, client_addr AS cl_addr, client_port AS cl_port, datname, usename, left(application
27660   10.1.88.22   34224     timescaledb   postgres              client backend      LWLock       WALWriteLock   active   00:00:00   00:00:00          00:00:00          COMMIT                                                                                        
27410   10.1.88.22   34058     timescaledb   postgres              client backend                                  active   00:00:00   00:00:00          00:00:00          COMMIT                 
```

[pg_activity](https://github.com/dalibo/pg_activity)
```
pg_activity
- postgres@localhost:5432/postgres - Ref.: 2s
  Size:   60.54G -     0.00B/s        | TPS:        1243        | Active Connections:           2        | Duration mode:       query
  Mem.:   24.40% -     4.51G/62.66G   | IO Max:      342/s
  Swap:    2.10% -   515.50M/23.85G   | Read :      0.00B/s -      0/s
  Load:    0.93 1.38 1.49             | Write:      0.00B/s -      0/s
                                                                               RUNNING QUERIES
PID    DATABASE                      APP             USER           CLIENT   CPU% MEM%   READ/s  WRITE/s     TIME+  W  IOW              state   Query
33430  None                  walreceiver         postgres     10.1.80.6/32    1.0  0.0    0.00B    0.00B  0.000000  N    N             active
```

[monitoring-stats](https://www.postgresql.org/docs/devel/monitoring-stats.html)


