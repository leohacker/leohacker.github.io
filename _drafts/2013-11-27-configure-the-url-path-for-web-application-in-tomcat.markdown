---
layout: post
title: "Configure the URL path for web application in Tomcat"
date: 2013-11-27 20:26
comments: true
categories: [Java]
published: true
toc: true
---

在WebApplication开发的过程中，通常访问WebApplication的URL就是war包的名字。基于默认配置，Tomcat会将webapps目录下的*.war文件包展开和自动部署，而URL路径指定为文件名。

_问题是：如果我们想配置这个WebApplication的访问URL路径呢？_

在Tomcat的文档中，有描述说可以使用Context的属性来配置context path。不过事实上，目前我还没有找到正确的方式设置这个路径。在Tomcat的官方文档中，指出有几种方式设置context：

- 在server.xml中设置Context。但是需要Tomcat重启后，才能生效。
- 在WebApplication的META-INF文件夹中，创建context.xml，指定Context配置信息。

显然，推荐的方式是在WebApplication的目录中配置Context的信息。不过遗憾的是：**在Tomcat中，配置的context信息会被直接忽略掉**。由于默认机制的存在，依旧是使用war包的文件名来作为URL路径。

Reference: Official Tomcat Documentation

- [Context](http://tomcat.apache.org/tomcat-7.0-doc/config/context.html)
- [Automatic Application Deployment](http://tomcat.apache.org/tomcat-7.0-doc/config/host.html#Automatic_Application_Deployment)

根据官方文档，我们可能需要复杂的Host和Context配置来达成我们的目标。

目前比较简单的解决方案还是使用目录的名字作为URL路径。不过我们在Context页面可以看到，如果我们想支持 `localhost:8080/foo/bar`的路径，可以将war包的名称指定为 `foo#bar`。这种设置路径的方式可以用来部署和配置同一个WebApplication的多个版本，例如 `localhost:8080/service/v1/`和`localhost:8080/service/v2`，相应地文件名为 `service#v1.war`和`service#v2.war`。
