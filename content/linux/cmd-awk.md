---
title: "awk 命令"
date: 2018-12-25T10:14:43+08:00
draft: false
---

#### What is awk 

[官网](https://www.gnu.org/software/gawk/manual/gawk.html)   
man 告诉我们 pattern scanning and processing language  

那么awk能做什么，awk适合做什么 ？
awk最常用的工作一般是遍历一个文件中的每一行，然后分别对文件的每一行进行处理。
由于awk天生提供对文件中文本分列进行处理，所以如果一个文件中的每行都被特定的分隔符(常见的是空格)隔开，
我们可以将这个文件看成是由很多列的文本组成，这样的文件最适合用awk进行处理，通过awk对你感兴趣的信息进行提取,其实awk在工作中很多时候被用来处理log文件，进行一些统计工作等。

#### 如何使用

完整格式:
```
awk  [options]  'BEGIN{ commands } pattern{ commands } END{ commands }'  file

-F fs			--field-separator=fs
```

##### 简单方式

```
对一行文本按照空行进行分割，并提取第3列内容
echo '11 22 33 44' | awk '{print $3}'
33

说明：默认分割符为空格; print 为awk 内置函数; $数字引用变量


多行处理
echo -e '11 22 33 44\naa bb cc dd' | awk '{print $3}'
33
cc

说明: -e 转换符\n 生效;
```

#### parttern 

```
加入partter $1>2
echo -e '1 2 3 4\n5 6 7 8' | awk '$1>2{print $3}'
3

说明:  $1>2 表示如果当前行的第1列的值大于2则处理当前行，否则不处理。
parttern 可以时任何表达式判断，例如>，<，==，>=，<=，!= 同时还可以使用+，-，*，/运算与条件表达式相结合的复合表达式，逻辑 &&，||，! 同样也可以使用进来。另外pattern部分还可以使用 /正则/ 选择需要处理的行。
```

#### BEGIN END语句块   
BEGIN语句块是在匹配文件第一行之前运行的语句块。类似于Before,做一些初始化工作，环境变量定义。    
END语句块是在awk循环执行完所有行的处理之后，才执行的，与BEGIN一样，END语句块也只执行一次。类似于After
```
简单例子
echo -e '1\n2\n3' | awk 'BEGIN{print "begin"}{print $1}END{print "end"}'
begin
1
2
3
end
```
```
cat test.txt
11 22 33
23 45 34
22 32 43

awk 'BEGIN{sum=0}{sum+=$1}END{print sum}' test.txt
输出结果：56

说明: 首先在BEGIN语句块中为变量sum赋值0，然后在循环语句块中将每一行的第1列加到sum中，当文件的所有行全部循环处理完成之后，打印出sum变量的值。
当然这个例子中BEGIN语句块是可以省略的，我们可以直接在循环语句块中使用sum变量，此时sum第一次使用，该变量会自动被建立，默认的初始值是0。
```

[更多](https://www.cnblogs.com/wangqiguo/p/5863266.html)
