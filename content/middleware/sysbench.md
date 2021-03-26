---
title: "Sysbench 测试"
date: 2018-11-16T19:25:45+08:00
draft: false
---

##### 下载安装 1.0.15 [sysbench官网](https://github.com/akopytov/sysbench)
```
curl -s https://packagecloud.io/install/repositories/akopytov/sysbench/script.rpm.sh | sudo bash
sudo yum -y install sysbench

```
##### 参数说明
```
sysbench --help
Usage:
  sysbench [options]... [testname] [command]

Commands implemented by most tests: prepare run cleanup help

General options: 
  --threads=N                     number of threads to use [1]  线程数
  --events=N                      limit for total number of events [0] 事务数
  --time=N                        limit for total execution time in seconds [10] 测压时间
  --forced-shutdown=STRING        number of seconds to wait after the --time limit before forcing shutdown, or 'off' to disable [off]
  --thread-stack-size=SIZE        size of stack per thread [64K]
  --rate=N                        average transactions rate. 0 for unlimited rate [0]
  --report-interval=N             periodically report intermediate statistics with a specified interval in seconds. 0 disables intermediate reports [0]
  --report-checkpoints=[LIST,...] dump full statistics and reset all counters at specified points in time. The argument is a list of comma-separated values representing the amount of time in seconds elapsed from start of test when report checkpoint(s) must be performed. Report checkpoints are off by default. []
  --debug[=on|off]                print more debugging info [off]
  --validate[=on|off]             perform validation checks where possible [off]
  --help[=on|off]                 print help and exit [off]
  --version[=on|off]              print version and exit [off]
  --config-file=FILENAME          File containing command line options
  --tx-rate=N                     deprecated alias for --rate [0]
  --max-requests=N                deprecated alias for --events [0]
  --max-time=N                    deprecated alias for --time [0]
  --num-threads=N                 deprecated alias for --threads [1]

Pseudo-Random Numbers Generator options:
  --rand-type=STRING random numbers distribution {uniform,gaussian,special,pareto} [special]
  --rand-spec-iter=N number of iterations used for numbers generation [12]
  --rand-spec-pct=N  percentage of values to be treated as 'special' (for special distribution) [1]
  --rand-spec-res=N  percentage of 'special' values to use (for special distribution) [75]
  --rand-seed=N      seed for random number generator. When 0, the current time is used as a RNG seed. [0]
  --rand-pareto-h=N  parameter h for pareto distribution [0.2]

Log options:
  --verbosity=N verbosity level {5 - debug, 0 - only critical messages} [3]

  --percentile=N       percentile to calculate in latency statistics (1-100). Use the special value of 0 to disable percentile calculations [95]
  --histogram[=on|off] print latency histogram in report [off]

General database options:

  --db-driver=STRING  specifies database driver to use ('help' to get list of available drivers) [mysql]
  --db-ps-mode=STRING prepared statements usage mode {auto, disable} [auto]
  --db-debug[=on|off] print database-specific debug information [off]


Compiled-in database drivers: 数据库驱动类型
  mysql - MySQL driver
  pgsql - PostgreSQL driver

mysql options:
  --mysql-host=[LIST,...]          MySQL server host [localhost]
  --mysql-port=[LIST,...]          MySQL server port [3306]
  --mysql-socket=[LIST,...]        MySQL socket
  --mysql-user=STRING              MySQL user [sbtest]
  --mysql-password=STRING          MySQL password []
  --mysql-db=STRING                MySQL database name [sbtest]
  --mysql-ssl[=on|off]             use SSL connections, if available in the client library [off]
  --mysql-ssl-cipher=STRING        use specific cipher for SSL connections []
  --mysql-compression[=on|off]     use compression, if available in the client library [off]
  --mysql-debug[=on|off]           trace all client library calls [off]
  --mysql-ignore-errors=[LIST,...] list of errors to ignore, or "all" [1213,1020,1205]
  --mysql-dry-run[=on|off]         Dry run, pretend that all MySQL client API calls are successful without executing them [off]

pgsql options:
  --pgsql-host=STRING     PostgreSQL server host [localhost]
  --pgsql-port=N          PostgreSQL server port [5432]
  --pgsql-user=STRING     PostgreSQL user [sbtest]
  --pgsql-password=STRING PostgreSQL password []
  --pgsql-db=STRING       PostgreSQL database name [sbtest]

Compiled-in tests: 测试类型
  fileio - File I/O test
  cpu - CPU performance test
  memory - Memory functions speed test
  threads - Threads subsystem performance test
  mutex - Mutex performance test

See 'sysbench <testname> help' for a list of options for each test.

```
##### 默认lua 脚本位置
```
ll /usr/share/sysbench/
total 60
-rwxr-xr-x 1 root root  1452 7月   4 04:07 bulk_insert.lua
-rw-r--r-- 1 root root 14369 7月   4 04:07 oltp_common.lua
-rwxr-xr-x 1 root root  1290 7月   4 04:07 oltp_delete.lua
-rwxr-xr-x 1 root root  2415 7月   4 04:07 oltp_insert.lua
-rwxr-xr-x 1 root root  1265 7月   4 04:07 oltp_point_select.lua
-rwxr-xr-x 1 root root  1649 7月   4 04:07 oltp_read_only.lua
-rwxr-xr-x 1 root root  1824 7月   4 04:07 oltp_read_write.lua
-rwxr-xr-x 1 root root  1118 7月   4 04:07 oltp_update_index.lua
-rwxr-xr-x 1 root root  1127 7月   4 04:07 oltp_update_non_index.lua
-rwxr-xr-x 1 root root  1440 7月   4 04:07 oltp_write_only.lua
-rwxr-xr-x 1 root root  1919 7月   4 04:07 select_random_points.lua
-rwxr-xr-x 1 root root  2118 7月   4 04:07 select_random_ranges.lua

```

##### sysbench对数据库进行压力测试的过程

- prepare  这个阶段是用来做准备的、建立好测试用的表、并向表中填充数据。
- run      这个阶段是才是去跑压力测试的SQL
- cleanup 这个阶段是去清除数据的、也就是prepare阶段初始化好的表要都drop掉。

```
sysbench --threads=100 --time=100 --db-driver=mysql --mysql-host=localhost --mysql-port=3306 --mysql-user=sbtest --mysql-password=123456 --mysql-db=tempdb oltp_insert prepare
sysbench --threads=100 --time=100 --db-driver=mysql --mysql-host=localhost --mysql-port=3306 --mysql-user=sbtest --mysql-password=123456 --mysql-db=tempdb oltp_insert run
sysbench --threads=100 --time=100 --db-driver=mysql --mysql-host=localhost --mysql-port=3306 --mysql-user=sbtest --mysql-password=123456 --mysql-db=tempdb oltp_insert cleanup
```
```
sysbench --threads=100 --time=100 --db-driver=pgsql --pgsql-host=10.1.7.126 --pgsql-port=5432 --pgsql-user=postgres --pgsql-password=123456 --pgsql-db=test1 oltp_insert prepare
sysbench --threads=100 --time=100 --db-driver=pgsql --pgsql-host=10.1.7.126 --pgsql-port=5432 --pgsql-user=postgres --pgsql-password=123456 --pgsql-db=test1 oltp_insert run
sysbench --threads=100 --time=100 --db-driver=pgsql --pgsql-host=10.1.7.126 --pgsql-port=5432 --pgsql-user=postgres --pgsql-password=123456 --pgsql-db=test1 oltp_insert clean
```
