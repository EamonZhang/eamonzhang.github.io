---
title: "语音识别的基本概念"
date: 2021-06-11T09:13:57+08:00
draft: true 
toc: false
categories: []
tags: []
---

- ASR ， Automatic Speech Recogntion 语音识别

- VAD ， Voice Activity Detection 语音端点检测

- LM ， Language Mode 语言模型

- AM ， 声学模型

- DNN-HMM 语音识别框架 

- WFST , Weighted Finite State Transducers  有限加权状态转换机 建立从HMM状态到单词的映射

- Lattice Rescore 词图

- Nbest 最优路径

- NLP,Natural Language Processing 自然语言处理

参考
- http://www.360doc.com/content/20/1211/20/7673502_950883057.shtml

导读
在语音识别系统中，有限加权状态转换机（Weighted Finite State Transducers, WFST）扮演着重要角色。本文主要介绍发音词典、语言模型和WFST的原理，以及在实践过程中的一些优化方法。

背景
目前的实际场景中的语音识别系统更多是基于HMM的传统语音识别框架，如：DNN-HMM，这种框架是由声学模型、发音词典、语言模型和解码器构成的pipeline结构，其中声学模型建模粒度为比音素还小的三音素状态，而语言模型和WFST在其中扮演着重要的角色。
本文将主要围绕三个问题展开：（1）如何实现从HMM状态到句子的映射；（2）WFST如何优化解码效率；（3）在实际应用时，如何使用Lattice Rescore等方法适应不同的业务场景。
首先，我们会回顾一下语音识别的背景知识，介绍传统语音识别的架构和基本概念，以及发音词典和语言模型的原理。进而，介绍WFST的定义和基本操作，以及WFST在语音识别中发挥的作用。最后，我们将以实际场景为例，从解码图的角度介绍一些语音识别的优化方法。

语音识别简介
语音识别（Automatic Speech Recognition, ASR）语音

语音识别简介
语音识别（Automatic Speech Recognition, ASR）的目标是将人类的语音内容转换为相应的文字。系统的输入通常是一段完整的长录音（或语音流），录音需要先经过语音端点检测（Voice Activity Detection, VAD）将人声的片段截取出来，语音识别会将语音中的内容转写为文字，其中会包含大量口语、重复、语法错误等情况，且语音识别不会为句子添加标点。
这时，系统需要一个后处理模块，使用顺滑技术将明显的口语问题“整理”为通顺的句子，并为句子加上标点。同时，说话人分离、说话人识别、语音情绪识别等模块，会为每段语音打上说话人、性别、情绪等标签，与转写的文字一同作为下游NLP模块的输入，进而转化为意图、情感、槽位等可用信息。

语音识别系统通常分为基于HMM的传统系统和端到端系统。传统系统分为声学模型、发音词典、语言模型和解码器，其结构从最开始的GMM-HMM，过渡到DNN/GMM-HMM混合系统。端到端系统的输入为声学特征序列，输出对应的单词/字序列，以CTC和Seq2Seq两种结构为主。语言模型在两种系统中都起着很大的作用，而WFST则主要应用于传统的系统。本文内容将基于HMM的传统语音识别展开介绍。
语音识别问题通常可以用以下公式描述，其中W为单词序列，X为声学特征序列，如公式所示，语音识别的目的是在当前的声学特征序列下，找出让该条件概率最大的单词序列。

### Word Lattice Rescore  词网格

以“南京市长江大桥”为例

```
南|南京|南京市
京
市|市长
长|长江|长江大桥
江
大|大桥
桥
```

以每个字为中心可拆分成如上的词列表

构成词网
![lat image](/images/wordlat.png)

这样计算每条路径的分数就可以知道那条路径最优了

计算分数的方式可以使用Ngram模型

代码摘自HanLP（https://github.com/hankcs/HanLP）

#### 开源语音识别对比

![asr compare](/images/asr_compare.jpg)

https://cmusphinx.github.io/wiki/

基础知识介绍
https://blog.csdn.net/zouxy09/article/details/7941585

#### 算法总汇

![算法](/images/asr_algorithm.png)


#### 语音识别 应用与原理
https://speech.xmu.edu.cn/2020/0630/c18207a406063/page.htm
