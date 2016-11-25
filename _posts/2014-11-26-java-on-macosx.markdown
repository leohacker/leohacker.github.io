---
title: "Java on MacOSX"
excerpt: 当多个版本Java在MacOSX上的时候
date: 2014-11-26 11:19
categories: [MacOSX, Java]
published: true
---

## Java on MacOSX
从某个版本起，MacOSX就不再默认安装Java的虚拟机了，自然也没有JDK。Apple官方发布的Java即使是2014版本也仅包含Java1.6，估计以后官方都不会发布新版本了吧。

所以我们需要安装Oracle版本的JDK。而对于管理MacOSX上的多版本Java，我曾经有痛苦的经历，大量的符号链接，多个不同位置的Library。对于不做MacOS开发的人，不了解系统的`/System/Library/Frameworks` `/System/Libraray/Java` `/Library/Java/JavaVirtualMachine`的含义，简直就是泥潭，很难理顺其中的关系。

最近升级Yosemite后，再次查看Java的环境，真的是干净了。由于系统清除了过去Apple安装和保持在系统中多个低版本符号链接，目前在`/System/Library/Frameworks/JavaVM.framework`中仅保留了我升级后的Java1.8。Frameworks在MacOSX中的作用就类似共享库，不过其中也可以包含文档，资源文件等非代码的文件。每个Framework可以包含多个版本，以前在这里就有很多低版本的Java指向`Versions/CurrentJDK`目录，使用当前版本的虚拟机环境。来自Oracle的JDK1.8和原来的Java1.6都安装在`/Library/Java/JavaVirtualMachine`目录里面。而`/System/Library/Java`里面没有什么东西。

## Library on MacOSX
参考这篇官方文档[File System Programming Guide](https://developer.apple.com/library/mac/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/FileSystemOverview/FileSystemOverview.html)，Library可以有多个不同级别的存储位置。在每个用户的目录下，有一个Library，这里面存放用户相关的数据，例如Preferences。JDK存放在`/Library/Java/JavaVirtualMachine`和`/System/Library/Framework`中，不同的是在`/System/Library/Framework`中存放的是framework，而`/Library/Java/JavaVirtualMachine`中存放的是JDK1.8本身。

    The Library directory is where apps and other code modules store their custom data files. Regardless of whether you are writing code for iOS or OS X, understanding the structure of the Library directory is important. You use this directory to store data files, caches, resources, preferences, and even user data in some specific situations.

    There are several Library directories throughout the system but only a few that your code should ever need to access:

    Library in the current home directory—This is the version of the directory you use the most because it is the one that contains all user-specific files. In iOS, Library is placed inside the apps data bundle. In OS X, it is the app’s sandbox directory or the current user’s home directory (if the app is not in a sandbox).
    /Library (OS X only)—Apps that share resources between users store those resources in this version of the Library directory. Sandboxed apps are not permitted to use this directory.
    /System/Library (OS X only)—This directory is reserved for use by Apple.

## Intellij IDEA still use JDK1.6
在升级系统JDK后发现一个问题，Intellij IDEA无法启动，原因是它还坚持使用JDK1.6。stackoverflow给出了两个方法：修改plist或者安装JDK1.6。

当某个应用程序需要使用某个指定版本的Java时，我们可以在`/Applications/the-application.app/Contents`中找到Info.plist，修改其中指定`JVMVersion`的版本即可。

我们可以下载Apple官方的JDK1.6 [Java for OSX 2014-001](http://support.apple.com/kb/dl1572)，也可以下载Oracle的官方版本 [Oracle JDK1.6 Download](http://www.oracle.com/technetwork/java/javase/downloads/java-archive-downloads-javase6-419409.html)。安装完Apple JDK 1.6以后，在`/System/Library/Frameworks/JavaVM.framework/Versions`就是这个样子：

``` bash
lrwxr-xr-x  1 root  wheel    10B Nov 26 14:45 1.4 -> CurrentJDK
lrwxr-xr-x  1 root  wheel    10B Nov 26 14:45 1.4.2 -> CurrentJDK
lrwxr-xr-x  1 root  wheel    10B Nov 26 14:45 1.5 -> CurrentJDK
lrwxr-xr-x  1 root  wheel    10B Nov 26 14:45 1.5.0 -> CurrentJDK
lrwxr-xr-x  1 root  wheel    10B Nov 26 14:45 1.6 -> CurrentJDK
lrwxr-xr-x  1 root  wheel    10B Nov 26 14:45 1.6.0 -> CurrentJDK
drwxr-xr-x  7 root  wheel   238B Nov 26 14:45 A
lrwxr-xr-x  1 root  wheel     1B Nov 26 14:45 Current -> A
lrwxr-xr-x  1 root  wheel    59B Nov 26 14:45 CurrentJDK -> /System/Library/Java/JavaVirtualMachines/1.6.0.jdk/Contents
```

那些符号链接都回来了，不过这次我们有经验了，能够很好地分辨JDK1.6和JDK1.8。于是我们可以总结出Apple和Oracle的JDK安装方式：

 - `/System/Library/Java/JavaVirtualMachines/1.6.0.jdk` Apple安装在系统级Library目录下。
 - `/Library/Java/JavaVirtualMachines/jdk1.8.0_25.jdk` Oracle安装在应用程序级Library目录下。
 - `/System/Library/Frameworks/JavaVM.framework/Versions` 包含两个版本的framework支持。

我们还是可以用/usr/libexec/java_home来找出系统默认的JDK的HOME目录。Eclipse等工具也会在系统中查找到多个版本的JDK。
