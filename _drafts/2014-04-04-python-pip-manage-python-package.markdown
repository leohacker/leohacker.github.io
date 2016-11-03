---
layout: post
title: "Python pip - manage python package"
date: 2014-04-04 23:54
comments: true
categories: [Python]
published: true
toc: true
---

## PyPI and pip
Python语言的成功，很大程度上也源自大量的Library的支持。很多Python的标准系统库会随Python的解释器而一起发行。那么我们是否就要自己去下载和安装其他库程序呢？我们怎么知道有哪些库呢？作为一个成熟的语言和社区，已经拥有了一个软件仓库和相应的管理工具。

 - [PyPI](https://pypi.python.org/pypi)，就是针对管理Python应用程序和库的一个仓库。
 - [pip](https://pypi.python.org/pypi/pip)，就是访问这个仓库的工具。通过pip，就可以安装第三方的库到我们的Python环境。

在MacOSX系统上，我用Homebrew安装Python在/usr/local/Cellar目录，pip会随Python一起安装。通过pip安装的软件就会位于/usr/local/Cellar/python/2.7.6/Frameworks/Python.framework/Versions/Current/lib/python2.7/site-packages。安装pip，请参考[installing pip](http://pip.readthedocs.org/en/latest/installing.html)。

## Basic Usage
和其他，包管理软件一样，pip也提供了以下功能：查找你想要的软件包，安装和删除软件包，查看你都安装了哪些软件包，查看软件包的信息。pip还提供了一个生成你的python环境的软件包列表的命令。

### search
``` bash
pip search keyword
```
查找和keyword相关的软件包。

<!--more-->

### install
``` bash
python install package
python install -r requirements-file
```
严格的说，install命令的参数是requirement specifiers，也就是指定package的ID的同时，还可以指定版本的范围。Ref：[Requirement specifiers](https://pythonhosted.org/setuptools/pkg_resources.html#requirement-objects)

```
FooProject >= 1.2
Fizzy [foo, bar]
PickyThing<1.6,>1.9,!=1.9.6,<2.0a0,==2.4c1
SomethingWhoseVersionIDontCareAbout
```

使用-r选项，我们可以指定一个requirements文件。Requirement文件的每一行其实就是给install命令的参数，通常requirement文件是用pip freeze命令产生的一个软件包的列表。

``` bash
pip install package
# -U or --upgrade 更新软件包
pip install --upgrade package
# 由于PyPI不强制要求开发者在更新软件包的同时，一定更新软件包的版本号，所以存在需要强行重装软件包的情况。
pip install --force-reinstall package
```

### uninstall
``` bash
pip uninstall package
pip uninstall -r requirements
# 用 -y 省略对删除命令的确认
pip uninstall -y -r requirements
```

### list
``` bash
# 列出当前软件包列表
pip list
# 列出过期的软件包 -o or --outdated
pip list --outdated
# 列出最新的软件包 -u or --uptodate
pip list -u
# 列出安装在当前virtualenv的软件包 -l or --local
# 我们可以用选项 --system-site-packages 创建一个virtualenv，
# 此环境会继承当前Python安装目录中的site packages。
# 在这种env中，pip list会列出所有可用的packages。所以我们需要用--local指定来查看env内安装的软件包。
pip list --local
```

### show
``` bash
pip show package
# -f or --files 列出软件包的文件列表
pip show -f package
```

### freeze
``` bash
pip freeze > requirements.txt
# 使用原始的requirement的顺序和注释，来生成新的requirement文件 -r or --requirement
pip freeze -r orig.requirement.file > output.requirement.file
# 仅导出当前virtualenv中安装的软件包 -l or --local
pip freeze --local > output.requirements
```

## Advanced

### resolve the dependency conflict by requirements
我还没有试验过，而且下面的这段原文并没有将这个问题完全说明白。它是指，如果我在文件中指定了某个软件包的范围，pip就在安装时就会尊重这个范围限定？也就是说指定依赖的版本范围，那么我是否可以在命令行上得到同样地效果呢？

> Requirements files are used to force pip to properly resolve dependencies. As it is now, pip doesn’t have true dependency resolution, but instead simply uses the first specification it finds for a project. E.g if pkg1 requires pkg3>=1.0 and pkg2 requires pkg3>=1.0,<=2.0, and if pkg1 is resolved first, pip will only use pkg3>=1.0, and could easily end up installing a version of pkg3 that conflicts with the needs of pkg2. To solve this problem, you can place pkg3>=1.0,<=2.0 (i.e. the correct specification) into your requirements file directly along with the other top level requirements. Like so:

```
pkg1
pkg2
pkg3>=1.0,<=2.0
```

### fast and local install
如果你是想复制你的环境，使用本地安装的方式是一个很快速的方式。
``` bash
# 使用--download选项下载软件包到本地目录
$ pip install --download <DIR> -r requirements.txt
# --no-index 不使用官方的PyPI仓库, 用 --find-links 指定本地仓库
$ pip install --no-index --find-links=[file://]<DIR> -r requirements.txt
```

### non-recursive upgrade
可能的话，pip的执行升级时会将你指定的软件包的所有依赖包也升级。有时，这不是你想要的结果。我们可以用`--no-deps`的技巧来避免这个问题。

``` bash
# 升级SomePackage自身，但不包括依赖。
pip install --upgrade --no-deps SomePackage
# 由于上条命令不安装依赖，所以可能会有新的依赖没有安装。
# 再次安装Somepackage，会安装缺失的依赖。
pip install SomePackage
```

