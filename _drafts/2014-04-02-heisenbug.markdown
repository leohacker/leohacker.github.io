---
layout: post
title: "Heisenbug"
date: 2014-04-02 08:28
comments: true
categories: [Jargon]
published: true
---

偶然间遇到这个词，Heisenbug。它描述了一种你可能会遇到，而一旦遇到就极为头疼的bug：在正常的运行中程序会出错，但是如果你用Debug的各种手段，bug可能会消失。这无疑是会让人抓狂的一种bug。

Ref: Wiki: [Heisengbug](http://en.wikipedia.org/wiki/Heisenbug)

这个词来源于Werner Heisenbug的量子力学的测不准理论，你观测一个系统的行为会改变正在观测的系统的状态。Heisenbug就是借用了类似概念创造出来的一个双关语(pun)。

Heisenbug很多时候表现为，当你在程序中插入调试用的语句，或者将程序置于调试状态运行时，程序运行正常，而编译后运行时程序错误。一个常见的原因是使用了优化编译，导致程序行为与预想的不一致。在维基页面上举了几种可能

 - 一个浮点数在内存中和在寄存器中的精度问题而可能导致错误。
 - 在assert语句中的side effect使得程序可以正常运行。但是在优化后，assert语句被去除了，程序错误。
 - 使用了未初始化的变量或者指针。
 - 时间相关的情况。例如在多线程程序中，竞争条件(race condition)类型的bug。在调试时，单步运行较慢，运行不出错。而实际中可能引入竞争条件。

查找和解决Heisenbug的方法就是，查找系统中是否存在有副作用的语句，在系统中添加一些无副作用的调试语句，打印出当时的程序状态或者assert程序运行是否符合预期。不要忘了检查优化编译的选项。
