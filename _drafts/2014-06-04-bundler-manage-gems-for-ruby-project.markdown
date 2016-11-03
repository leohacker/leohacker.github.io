---
layout: post
title: "Bundler - manage gems for Ruby project"
date: 2014-06-04 10:13
comments: true
categories: [Ruby]
toc: true
published: true
---

## Rationale
在开发项目的过程中，由于需要依赖和引入其他库，而通常这些库又会依赖其他库，所以我们常常会陷入一个依赖的泥潭。Bundler就是用来给Ruby项目管理依赖的工具，在JAVA的世界里的对应物就是Maven，而实际上Bundler还提供了一个Maven不具有的功能，`Gemfile.lock`。

我们在开发项目时，希望在不同的机器上，不同的环境中，都可以重复相同的编译调试运行。这也就要求我们的环境安装的库的版本是相同的。那么设想一下，如果我们采用指定每个库的具体的版本的方法可行吗？答案是否定的。首先，我们很难穷举所有依赖的库。我们只熟知我们直接使用的库，而这些库对其他库的依赖关系是我们无法控制的。其次，即使我们费劲九牛二虎之力，将所有库固定在具体的版本上，当我们需要升级其中某个库的版本的时候，我们不得不解决因这次升级导致的一系列不兼容问题，再次跳入依赖的泥潭，找到所有受影响的库的正确版本。

所以在开发工具中，通常有这么一个工具，帮助我们解决库的版本依赖问题。在Java中是Maven，它可以根据你列出的库，自动的解析和找到所有的依赖库，解决依赖的冲突。在Maven的依赖管理中，你指定了直接依赖的包的具体版本，所以最终解析出来的依赖树是唯一的，因为它们都引用相同远程仓库的元数据。

Bundler在管理Ruby项目的依赖时，是可以指定模糊的依赖版本的。例如：`gem 'nokogiri', '~> 1.4.2'`，这指定依赖`1.4`版本的所有高于1.4.2的小版本。这种方式相对更灵活一些。不过也导致在不同程序员的开发环境中，或者同一个程序员的不同时刻，解析依赖的结果不同。为了方便管理和统一开发环境，Bundler提供了锁定依赖关系的方式，Gemfile.lock。

## Gemfile
在Gemfile中，指定依赖的库的版本信息。

```
source 'http://rubygems.org'

gem 'rails', '3.0.0.rc'
gem 'rack-cache', :require => 'rack/cache'
gem 'nokogiri', '~> 1.4.2'
```

上面的例子展示了常用的几种指定版本的方式。

 - 给Rails指定固定的版本, 3.0.0.rc
 - 不指定rack-cache的版本，使用最近的版本。
 - 指定在源码中require rack-cache库的时候，使用rack/cache，而不是rack-cache。
 - 指定nokogiri的版本是1.4的版本，而且高于1.4.2。

## Install and Update
### Install
`bundle install`会读入Gemfile，解析库的依赖关系。如果是第一次运行install，会生成Gemfile.lock文件。Gemfile.lock文件中保存了这次解析的结果。如果Gemfile.lock文件在运行install时已经存在，bundler会判断当前的Gemfile.lock的解析结果是否能否满足Gemfile的设定。如果满足，就跳过解析步骤，即使远程仓库中已经更新了新版本的库。这样，可以将开发环境稳定在一个经过测试的，相对旧的版本依赖树上。

也就是说，其实Gemfile.lock是关键，当前程序的依赖树。所以我们要将Gemfile和Gemfile.lock都提交到版本仓库中，在开发团队中共享相同的依赖配置。

如果我们要更新项目的库，我们需要修改Gemfile，然后运行`bundle install`再次解析和生成Gemfile.lock。这次解析会更新在Gemfile中明确列出的库的版本。对于没有在Gemfile中列出的库，bundler采用保守的方式进行更新。如果隐性依赖的库现有的版本可以满足新版本库的依赖关系，就不更新。如果其他库对某个旧版本库有依赖，就不升级这个旧版本库。整个升级策略都以相对保守的方式保持项目开发的稳定性。通常我们都可以得到满意的结果，不过也存在可能会有解析失败和冲突的时候。如果只是隐性依赖受影响，bundler会默默的升级Gemfile.lock，满足Gemfile的需求。如果升级导致某个在Gemfile中声明的库依赖不满足，会报告冲突。

### Update
`bundle update`会给人误解，是用来更新项目的Gemfile的依赖关系的。其实它的作用是在不修改Gemfile的情况下，更新Gemfile.lock，通常也就是更新项目使用最新的库。不过这种更新要小心，尤其是在临近项目要部署和发布的时候。由于我们的开发和测试都是基于原来的Gemfile.lock设置的版本树，所以大范围的更新库不是好主意。当然，也可以使用`bundle update a-gem-name`的方式，仅更新一个库。请随即运行测试吧。

## Reference
在部署的时候，我们可以运行`bundle install --deployment`来设置环境。在bundler的命令手册页面，你还能发现像`bundle check`和`bundle exec`这样有用的命令。

 - [Bundler Rationale](http://bundler.io/v1.6/rationale.html)
 - [Bundler Commands](http://bundler.io/v1.6/commands.html)






