---
title: "Read the JDK 9 source code in Intellij IDEA"
excerpt: 如何设置Intellij IDEA阅读JDK9模块化的代码
date: 2016-11-10 17：00
categories: [Java]
published: true
---
{% include toc %}

Intellij IDEA也是在JDK开发社区使用很广泛的编辑器，尤其是开发JDK本身不需要其他框架支持，
社区版就够用了。问题是JDK9是模块化的结构，而且在JDK的代码仓库比较多，不是很容易作为Intellij的模块打开。

JDK开发社区中，AdoptOpenJDK给出过一个脚本[BuildHelpers.sh](https://github.com/AdoptOpenJDK/BuildHelpers/blob/master/buildIntelliJModules.sh)。
在2015年的时候，Maurizio Cimadamore和Chris Hegarty给出了OpenJDK官方的[答案](https://bugs.openjdk.java.net/browse/JDK-8074716)。

使用方法也很简单:
```
# clone openjdk source code forest
hg clone http://hg.openjdk.java.net/jdk9/dev 9dev.src
cd 9dev.src
sh ./get_source.sh

# auto-configure, install the ant in appropriate position or default position.
# or you need to run this configur command with --with-ant-home <ANT_HOME>
bash configure

# run the script to build intellij project files.
sh common/bin/idea.sh

# output folder: the .idea hidden folder under the toplevel.
```

这个脚本在生成Intellij项目后，提供了几个Build命令。不过由于缺少BSF Manager(Javascript Engine Manager)，
无法通过build。目前我不了解Ant，只能放在一边了。

Intellij的项目生成后，我们可以打开这个项目，阅读各个类的代码，跳转都是好用的。Excellent!
