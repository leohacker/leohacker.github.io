---
title: "Java Microbenchmark Tool"
excerpt: Microbenchmark
date: 2016-12-02 00:12:03
categories: [Java]
published: true
---

这篇博客只是一个简单的笔记，记录一个从前不了解的概念Microbenchmark，以及它在Java上的两个工具：JMH （Java Microbenchmark Harness) 和 Caliper 。

刚开始的时候，不清楚Microbenchmark的含义，不知道这个micro是什么东西micro。后来看了stackoverflow上的一个答案，原来就是指测试那些很小的操作，
小到你的测试计时代码都比它大，这时观察者已经开始影响被观察对象的观察结果了，有点薛定谔的猫的意思。所以需要专门的工具来为这种测试运行benchmark。

[JMH](http://openjdk.java.net/projects/code-tools/jmh/)是OpenJDK官方提供的运行Microbenchmark的工具，
你应该遵循官方说明构建工程，生成jar包，执行测试代码。Google也出过一个工具，Caliper，好像更早做出来。估计没什么机会用，但作为一种测试类型，
和相应的解决方案和工具，记录在这。

References:
 - https://adoptopenjdk.gitbooks.io/adoptopenjdk-getting-started-kit/content/en/openjdk-projects/jmh/jmh.html
 - http://nitschinger.at/Using-JMH-for-Java-Microbenchmarking/
 - [Caliper on Github](https://github.com/google/caliper)
