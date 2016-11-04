---
title: "Build a blog with Jekyll on Github"
excerpt: Build a blog powered with Jekyll and Minimal mistake, hosted on Github page.
date: 2016-11-04 10:50
categories: [Programmer]
published: true
---
{% include toc %}

本博客使用[Jekyll](https://jekyllrb.com/)静态博客系统构建，其特点是博客的内容不是数据库管理的，而是以markdown文件的方式存放在Post目录下，不容易丢失，迁移也很容易。本博客主题使用[Minimal mistakes](https://mmistakes.github.io/minimal-mistakes/)，是一个响应式的两栏的布局，提供了几种漂亮的布局和比较灵活的配置。

## 安装
Minimal mistakes 4.0以后提供了Gem包的方式，但是github pages不支持第三方插件，所以还是使用fork的方式。

- Ruby: 2.3
- Gemset: Jekyll
- Jekyll: 3.3
- Minimal mistakes version: 4.0.4

[Minimal mistakes Quick Start Guide](https://mmistakes.github.io/minimal-mistakes/docs/quick-start-guide/)给出了安装这个主题的步骤。

- Install rvm if not
- Install ruby and setup a gemset Jekyll for blog
- Use this gemset
- Fork minimal-mistakes repository
- Rename the repository to yourname.github.io
- Fill your Gemfile, use bundler to install the gems into Jekyll gemset.
- Remove the gh-pages branches and folders in demo site.

如果我们需要升级，可以添加远程上游仓库。由于会修改和定制一些内容，每次升级后需要解决冲突。

```
$ git remote add upstream https://github.com/mmistakes/minimal-mistakes.git
$ git pull upstream master
```
