---
layout: post
title: "Sign @ and + in file permission on MacOSX"
date: 2014-03-29 19:20
comments: true
categories: [MacOSX]
published: true
---

在MacOSX系统里面，当你用`ls -l`列出文件和目录时，或许会注意到有的权限信息后面还有 @ 和 + 字符。例如

``` bash
drwxrwxr-x+ 66 root  admin     2244 Mar 26 18:27 Applications
drwxr-xr-x+ 65 root  wheel     2210 Mar 12 21:05 Library
drwxr-xr-x@  2 root  wheel       68 Aug 25  2013 Network
drwxr-xr-x+  4 root  wheel      136 Dec 22 04:57 System
drwxr-xr-x   5 root  admin      170 Dec 22 05:03 Users
drwxrwxrwt@  3 root  admin      102 Mar 28 20:24 Volumes
drwxr-xr-x@ 39 root  wheel     1326 Feb 27 10:21 bin
drwxrwxr-t@  2 root  admin       68 Aug 25  2013 cores
dr-xr-xr-x   3 root  wheel     4245 Mar 26 20:43 dev
lrwxr-xr-x@  1 root  wheel       11 Dec 22 04:45 etc -> private/etc
dr-xr-xr-x   2 root  wheel        1 Mar 28 01:11 home
-rwxr-xr-x@  1 root  wheel  8393408 Jan 17 11:40 mach_kernel
dr-xr-xr-x   2 root  wheel        1 Mar 28 01:11 net
drwxr-xr-x@  3 root  wheel      102 Dec 18  2009 opt
drwxr-xr-x@  7 root  wheel      238 Dec 22 05:12 private
drwxr-xr-x@ 62 root  wheel     2108 Feb 27 10:21 sbin
lrwxr-xr-x@  1 root  wheel       11 Dec 22 04:47 tmp -> private/tmp
drwxr-xr-x@ 12 root  wheel      408 Dec 22 23:30 usr
lrwxr-xr-x@  1 root  wheel       11 Dec 22 04:47 var -> private/var
```
参考网上的文章

 - @ 符号是指示文件有附加属性，可以用`xattr -l <file>`来查看。附加属性的一个典型例子是，记录此文件是否是从Internet下载来的文件。
 - \+ 符号是指示有ACL属性设置。Access Control List (ACL)是比传统的Unix文件权限更高级的权限系统，提供更加细粒度的权限。

不过从使用者的角度来看，我们通常不需要关心@和+符号。ACL是比较高级的权限管理，一般用户最好不要随便更改。我原来怀疑这两个符号和suid有关，看来不是这样的。

Ref:

 - http://blog.anselmbradford.com/2008/12/24/what-is-the-significance-of-plus-and-at-in-mac-os-x-file-permission-tables/
 - http://www.techrepublic.com/blog/apple-in-the-enterprise/introduction-to-os-x-access-control-lists-acls/1048/

