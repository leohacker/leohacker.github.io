---
title: "Essential apt and dpkg"
excerpt: Linux Debian包管理Apt和Dpkg的使用
date: 2014-11-24 00:03
modified: 2016-12-06 19:00
categories: [Linux]
published: true
---
{% include toc %}

## Debian package management
在Linux发行版中，Ubuntu拥有众多的用户。Ubuntu是基于Debian的派生，而且大大改进了兼容性和易用性。
Debian的哲学是仅包含开源的软件，这大大限制了它在一般用户中的推广。Ubuntu的出现改变了这一切，
于是更多的人从RedHat系的RPM/YUM转向了apt/dpkg。相对于YUM，apt包含多个命令行工具，
使用上要复杂一点。所以很需要一个CheatSheet记录那些有用的命令。由于其他图形化的工具都基于apt工具，
而apt又基于dpkg，而且使用这些工具的主要途径是命令行和脚本，所以本文不研究Aptitude或者其他图形化工具。

常用的APT系的命令行工具有：

 - apt-get 完成主要的软件包管理功能
 - dpkg 提供最底层的软件包管理功能
 - apt-cache 提供查询本地cache功能
 - apt-file  提供查询远端仓库的功能

### 阅读列表

 - [Debian FAQ](https://www.debian.org/doc/manuals/debian-faq)的第7,8小节基本就说明了Debian软件包
 的基本概念和常用工具。如果对软件包的依赖系统和远程仓库有所了解，这些概念就很好理解了。基本上阅读FAQ，使用时在查找
 manpage，就基本够用了。

 - [Debian Reference](https://www.debian.org/doc/manuals/debian-reference/)是一个面向Debian新用户的手册，
 第二章专门讲解包管理。其中用一节讲解使用Aptitude。[Advanced Package Management Operations](https://www.debian.org/doc/manuals/debian-reference/ch02.en.html#_advanced_package_management_operations)
 列出了一些高级用例，主要涉及配置软件包，编译软件源码包等高级主题。如果不是想学习Aptitude，可以不看。

 - [Debian Administrator's Handbook](https://www.debian.org/doc/manuals/debian-handbook/)是一个相当全面
 的用户手册。[APT source list](https://www.debian.org/doc/manuals/debian-handbook/apt.en.html#sect.apt-sources.list)
 讲解其他两个文档没有说的仓库源的配置文件`/etc/apt/sources.list`和`/etc/apt/sources.list.d/*list`。

### Concepts
一个软件包可以看作是执行程序，库，配置文件，文档的集合。软件包管理就是下载和安装软件包，在安装过程中
正确配置软件，其中可能利用到preinst, postinst, prerm, postrm等脚步，设置包括系统设置，服务的设置，
用户权限等各种配置。在升级过程中，我们通常不希望我们修改过的软件配置被软件升级覆盖，所以我们要主要备份
conffile(config files)。我们可以通过`dpkg --status package`查看一个软件包的配置文件列表。

Debian的软件包的优先级可以分为: Required, Important, Standard, Optional, Extra。
Required是系统必须要有的(有些会标记为Essential)，Important也是很基础的，一般的Debian安装会包含Standard以上的
软件包。不过随着Docker这样的虚拟化技术对容器大小的要求，我怀疑很多important级别的软件包没有在容器中，
甚至有可能涉及Requried。例如，find all 'required' packages
`dpkg-query -W --showformat='${Package}\t${Priority}\n' | grep "required$"` 。

软件包的依赖关系可以有 Depends, Recommends, Suggests, Conflicts, Replaces, Breaks, Providers。
从名字上就很容易理解这些依赖关系。与Depends和Providers相关的有一个virtual package的概念，因为软件包
依赖的是一种能力，例如一个邮件发送服务，这时多个不同的具体的邮件发送实现可以提供这种服务，一个虚拟软件包
来填补依赖关系中的这个位置。

软件包可以有几种状态：unknown, install, remove, purge, hold。Remove 和 Purge 的区别在于，Remove没有
删除配置文件，purge则是彻底的清除。Hold表示软件固定在某个版本和状态上，`apt-mark hold package`，解开hold使用
`unhold`命令。

Debian也支持获取源码包: `apt-get source foo`，也提供有好的命令`apt-get build-dep foo`帮助编译。也可以参考
官方FAQ文档，编译得到deb的二进制包。

仓库源在文件`/etc/apt/sources.list`中指定，通常我们也将第三方的源放在目录`/etc/apt/sources.list.d`中。
系统中存放apt相关数据的文件夹：

 - /var/cache/apt/archives/ 存放下载的deb软件包
 - /var/lib/apt/lists/ 保存软件包的状态信息

## Tools

### apt
``` bash
# update, upgrade
apt update
apt upgrade
apt full-upgrade
# search packages and descriptions for search-string
apt search search-string
# show versions and priorities of available packages
apt show package
# show packages dependencies
apt show -a package
#  install, remove
apt install package
apt remove package
apt autoremove
# dependencies
apt depends package
apt rdepends package
```

### apt-get
``` bash
# 更新软件包的索引文件，这些索引文件的位置在`/etc/apt/sources.list`中指定。
$ apt-get update
# 升级所有已经安装的软件.upgrade不会在需要删除其他软件包，
# 或者缺少其他依赖包的情况下，执行升级操作，要升级的软件包版本会保持不变。
$ apt-get upgrade
# 大版本升级所有已经安装的软件。dist-grade可能会在升级的过程中删除其他软件包，
# 不过会尽可能小的影响其他软件包。
$ apt-get dist-upgrade
# 安装/升级指定软件包，可以指定版本。
$ apt-get install vsftpd
$ apt-get install vsftpd=2.3.5-3ubuntu1
# 现在apt-get install会默认安装recommends软件包。
# 在做Docker镜像的时候，我们通常不想安装推荐包。
$ apt-get --no-install-recommends install package
# 使用通配符安装多个软件包，注意需要用单引号，别让通配符在shell这层先解析掉了。
$ apt-get install '*name*'
# 删除，配置文件不删除。
$ apt-get remove
# 删除，配置文件也删除。
$ apt-get purge
# 删除软件包以及那些自动安装但现在不被需要的依赖包
$ apt-get autoremove vsftpd
# 将软件包package固定在目前的版本
$ apt-mark hold package
# 清除下载的deb文件。clean会删除所有在`/var/cache/apt/archives`里面的文件。
# autoclean仅会删除那些不再需要下载，过期版本的软件包。
$ apt-get clean
$ apt-get autoclean
# 下载软件源码包
$ apt-get source vsftpd
$ apt-get source --download-only vsftpd
# 获取编译foo源码包的编译依赖包
$ apt-get build-dep foo
# 下载软件二进制包
$ apt-get download vsftpd
# 查看changelog
$ apt-get changelog vsftpd
# 检查是否有Broken Dependencies.
$ apt-get check
```

### apt-cache
`apt-cache`是基于软件包数据库和软件包的元数据查找匹配结果。

```bash
# 查找软件包
$ apt-cache search pkg
$ apt-cache pkgnames pkg
# 查看软件包的基本信息，依赖关系
$ apt-cache show pkg
$ apt-cache showpkg pkg
# 查看软件包的依赖
$ apt-cache depends package
# 查看软件包的反向依赖，即谁依赖这个包
$ apt-cache showpkg package
```

### apt-file
`apt-file`是基于软件包数据库和软件包包含的文件列表来查找匹配结果。

```bash
# 更新软件包文件列表内容到本地
$ apt-file update
# 查找哪个软件包包含了这个文件路径(pattern)，但是不能查找目录。
$ apt-file search filepath
# 在查找的时候filepath作为fixed string，精确匹配。
$ apt-file search -F filepath
# 列出软件包的文件列表。软件包可以没有本地安装。
$ apt-file list pkg
# 找出所有匹配pkg的软件包名字
$ apt-file list -l pkg
# 如果你想精确匹配一个名字的话，考虑使用正则。
$ apt-file list --regexp ^pkg$
```

### dpkg
```bash
# 安装，删除，本地deb包
$ dpkg --install foo_version-release.deb
$ dpkg --remove foo_version-release.deb
$ dpkg --purge foo_version-release.deb
# 列出所有vi相关的软件包
$ dpkg -l '*vi*'
# 查看软件包pkg的安装状态 -s --status
$ dpkg -s pkg
# 列出所有安装的软件包 -l --list
$ dpkg -l
# 列出已安装软件包的文件列表 -L --listfiles
$ dpkg -L pkg
# 查找包含文件的软件包 -S --search
$ dpkg -S file

# 查看deb包信息
$ dpkg -I pkg.deb
# 列出deb包文件列表
$ dpkg -c pkg.deb

# query installed packages
dpkg-query -W --showformat='${Package}${Version}${Installed-Size}\n'

# 导出当前安装软件列表
dpkg --get-selections > file
# 导入当前安装软件列表
dpkg --set-selections < file
```
