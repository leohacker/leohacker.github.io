---
title: "apt and dpkg"
excerpt: Linux Debian包管理Apt和Dpkg的使用
date: 2014-11-24 00:03
categories: [Linux]
published: true
---
{% include toc %}

## apt and dpkg
在Linux发行版中，Ubuntu拥有众多的用户。Ubuntu是基于Debian的派生，而且大大改进了兼容性和易用性。Debian的哲学是仅包含开源的软件，这大大限制了它在一般用户中的推广。Ubuntu的出现改变了这一切，于是更多的人从RedHat系的RPM/YUM转向了APT/dpkg。相对于YUM，APT包含多个命令行工具，使用上要复杂一点。所以很需要一个CheatSheet记录那些有用的命令。

常用的APT系的命令行工具有：

 - apt-get 完成主要的软件包管理功能
 - apt-cache 提供查询本地cache功能
 - apt-file  提供查询远端仓库的功能
 - dpkg 提供最底层的软件包管理功能

系统中存放apt相关数据的文件夹：

 - /var/cache/apt/archives/ 存放下载的deb软件包
 - /var/lib/apt/lists/ 保存软件包的状态信息

**Reference**

https://www.debian.org/doc/manuals/debian-reference/ch02.en.html

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
# 安装/升级指定软件包，可以指定版本
$ apt-get install vsftpd
$ apt-get install vsftpd=2.3.5-3ubuntu1
# 使用通配符安装多个软件包，注意需要用单引号，别让通配符在shell这层先解析掉了。
$ apt-get install '*name*'
# 删除，配置文件不删除。
$ apt-get remove
# 删除，配置文件也删除。
$ apt-get purge
# 删除软件包以及那些自动安装但现在不被需要的依赖包
$ apt-get autoremove vsftpd
# 清除下载的deb文件。clean会删除所有在`/var/cache/apt/archives`里面的文件。
# autoclean仅会删除那些不再需要下载，过期版本的软件包。
$ apt-get clean
$ apt-get autoclean
# 下载软件源码包
$ apt-get source vsftpd
$ apt-get source --download-only vsftpd
# 下载软件二进制包
$ apt-get download vsftpd
# 查看changelog
$ apt-get changelog vsftpd
# 检查是否有Broken Dependencies.
$ apt-get check
```
<!-- more -->

### apt-cache and apt-file
`apt-cache`是基于软件包数据库和软件包的元数据查找匹配结果，而`apt-file`是基于软件包数据库和软件包包含的文件列表来查找匹配结果。
```bash
# 查找软件包
$ apt-cache search pkg
$ apt-cache pkgnames pkg
# 查看软件包的基本信息，依赖关系
$ apt-cache show pkg
$ apt-cache showpkg pkg
```

```bash
# 更新软件包文件列表内容到本地
$ apt-file update
# 查找哪个软件包包含了这个文件，但是不能查找目录。
$ apt-file search filepath
# 列出软件包的文件列表。软件包可以没有本地安装。
$ apt-file list pkg
# 找出所有匹配pkg的软件包名字
$ apt-file list -l pkg
# 如果你想精确匹配一个名字的话，考虑使用正则。
$ apt-file list --regexp ^pkg$
```

### dpkg

```bash
# 查看软件包pkg的安装状态
$ dpkg -l pkg
# 列出所有安装的软件包
$ dpkg -l
$ dpkg --get-selections | cut -f 1
# 列出所有vi相关的软件包
$ dpkg -l '*vi*'
# 列出已安装软件包的文件列表
$ dpkg -L pkg
# 查找包含文件的软件包
$ dpkg -S file
```
