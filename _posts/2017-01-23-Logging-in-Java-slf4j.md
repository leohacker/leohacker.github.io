---
title: "Logging in Java slf4j"
excerpt:
date: 2017-01-23 23:04:58
modified: 2017-01-23
categories: [Java]
published: false
---
{% include toc %}

### SLF4J
Simple logging Facade for Java
TODO: read the source code of slf4j.

This form incurs the hidden cost of construction of an Object[] (object array) which is usually very small. The one and two argument variants do not incur this hidden cost and exist solely for this reason (efficiency). The slf4j-api would be smaller/cleaner with only the Object... variant.

SLF4J uses its own message formatting implementation which differs from that of the Java platform. This is justified by the fact that SLF4J's implementation performs about 10 times faster but at the cost of being non-standard and less flexible.

Static Binding
http://geekexplains.blogspot.jp/2008/06/dynamic-binding-vs-static-binding-in.html


slf4j static binding
https://remonstrate.wordpress.com/2013/09/01/java-%E7%9A%84-static-binding/

When I first read about compile-time binding, it seemed dubious:  How can a java library which can log using different frameworks rely on compile time binding?  The answer is  that the "compile-time" binding only refers to the fact that SLF4J is *compiled* against an implementation of an SLF4J logger... However, you can still use a different binding at runtime.

SLF4J doesn't use classloaders, instead, its very simple:  It loads org.slf4j.impl.StaticLoggerBinder.  Each implementation of SLF4J (i.e. the slf4j-log4j bindings) provides a class with this exact name.... So there is no confusion.  At run-time, the same thing happens: The class is picked up from the classpath directly, without any runtime magic.  What if no slf4j-* implementations are on the classpath?  Well... then no logging will occur.  

### Others
Java 日志终极指南
http://developer.51cto.com/art/201507/484646.htm

很有趣的一个项目，将system.out system.err重定向到slf4j。
http://projects.lidalia.org.uk/sysout-over-slf4j/
类似的，slf4j提供了其他的bridge

log4j faq
https://logging.apache.org/log4j/2.x/faq.html
articles
https://logging.apache.org/log4j/2.x/articles.html

log4j 2.6 garbage free
https://www.infoq.com/news/2016/05/log4j-garbage-free
