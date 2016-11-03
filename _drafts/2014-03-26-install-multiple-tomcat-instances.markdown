---
layout: post
title: "Install multiple tomcat instances"
date: 2014-03-26 08:32
comments: true
categories: [Java]
published: true
toc: true
---

## Why multiple tomcat instances
Tomcat是JavaWeb开发入门的服务器，通常我们都需要在自己的开发系统中部署一个作为日常开发调试使用。如果作为一般的使用，一个Tomcat服务器就够用了。但是如果你拥有一台强劲的服务器机器，你就可以考虑同时在这台机器上部署多个Tomcat服务器，一个用来跑Jenkins这样的开发工具，一个用来调试开发中的Web应用。这样的好处是，你不会重启Jenkins所在的服务器，而可以自由的选择是否重启开发Tomcat，或者任由其崩溃。

相比直接在系统中安装多个Tomcat目录，其实我们可以只安装一个Tomcat目录，但同时运行多个Tomcat实例。在Tomcat的官方文档中，没有明显的提及如何做，其实都已经在Tomcat安装目录下的RUNNING.txt中说明。诀窍就是CATALINA_BASE目录。

<!-- more -->

## Install on Linux
### Add user tomcat
首先我们要添加一个tomcat用户，用来运行Tomcat服务器。不推荐使用root用户来运行任何服务程序。

`adduser`是`useradd`这样的低级命令的前端命令，方便添加和删除用户和组。此命令的配置文件是`/etc/adduser.conf`，其控制`adduser`命令的运行效果。`adduser --system --group tomcat` 我们添加一个系统用户，同时添加一个同名的用户组。我没有禁止用户目录，因为我记得Nexus或者Jenkins服务器需要当前用户目录存放文件。

### 运行Tomcat相关的环境变量

 - JAVE_HOME 指示JDK安装位置，我们可以在系统级别的`/etc/environment`中指定。
 - CATALINA_HOME 指示Tomcat安装目录。
 - CATALINA_BASE 指示Tomcat instance的目录。
 - CATALINA_OPTS 指示启动Tomcat的参数，通常我们在这里指定JavaVM的内存限制相关的配置。
 - CATALINA_PID Tomcat实例的 pid 文件。

在Tomcat的实例目录中，我们可以在`bin/setenv.sh`文件中设置`CATALINA_OPTS`和`CATALINA_PID`变量。由于我们需要`CATALINA_HOME`和`CATALINA_BASE`定位Tomcat实例的位置，所以我们不能在这里指定。`CATALINA_HOME`和`JAVA_HOME`都可以在`/etc/environment`中设置，而`CATALINA_BASE`可以在启动脚本中指定。

### 创建Tomcat实例

 - 在`CATALINA_HOME`目录下，创建一个Tomcat实例目录，例如`devserver`。
 - 将除 bin 和 lib 目录以外的其他目录，移动到`devserver`目录。
 - 在实例目录下创建 bin 和 lib 目录。HOME目录下的lib目录，存放对Tomcat自身和所有Web应用都有效的库，而在实例目录下的lib目录存放仅对这个实例服务器有效的库。实际上，推荐在应用自己的目录下存放应用所需的所有库，所以BASE目录下的库目录是空的。bin目录中仅放`setenv.sh`和`tomcat-juli.jar`。由于我不关心tomcat自己的logging系统采用什么logging软件，所以我只是在这里放 setenv.sh 。
 - 在tomcat-user.xml中添加角色和用户。
 - 在`CATALINA_BASE/conf/server.xml`中修改Shutdown, HTTP Connector, AJP Connector, Redirect的端口。

``` xml tomcat-user.xml
<role rolename="manager-gui"/>
<role rolename="admin-gui"/>
<user username="admin" password="admin" roles="manager-gui, admin-gui"/>
```

``` bash setenv.sh
CATALINA_PID="$CATALINA_BASE/catalina_pid"
CATALINA_OPTS="-Xms1024m -Xmx1024m -Xmn256m -XX:PermSize=256m -XX:MaxPermSize=256m -Djava.awt.headless=true"
```

## Install on MacOSX
在MacOSX上，我直接将Tomcat软件安装在当前用户的`~/Application`目录下。所以我不需要特别的创建用户，环境变量`JAVA_HOME`和`CATALINA_HOME`都在bashrc中指定。其他就类似在Linux系统中一样。
