---
title: "Build a blog with Jekyll on Github"
excerpt: Build a blog powered with Jekyll and Minimal mistake, hosted on Github page.
date: 2016-11-04 10:50
modified: 2016-11-06 01:50
categories: [Programmer]
published: true
---
{% include toc %}

本博客使用[Jekyll](https://jekyllrb.com/)静态博客系统构建，其特点是博客的内容不是数据库管理的，而是以markdown文件的方式存放在post目录下，不容易丢失，迁移也很容易。本博客主题使用[Minimal mistakes](https://mmistakes.github.io/minimal-mistakes/)，是一个响应式的两栏的布局，它提供了几种漂亮的布局和比较灵活的配置。

## 安装
Jekyll提供了一个处理markdown文件生成静态网站的基础框架，但是没有也不可能给出你的静态网站的设计。所以我们需要主题来设置网站的界面风格。通常，我们是通过查找合适的主题，然后在Github上fork这个项目来得到这个主题。minimal-mistakes给出了一个简洁的单页的风格，也提供了有全宽标题图片的页面，还提供了Feature文章的排版风格，非常适合博客。出于方便管理和升级的角度，Minimal mistakes 4.0以后提供了Gem包的方式，但是github pages不支持第三方插件，所以还是使用fork的方式。

Jekyll博客使用Gemfile管理依赖，所以我们使用Bundler安装所有需要的Jekyll和Jekyll的插件。当然我们需要先安装RVM或者ruby。我通常会使用RVM设置一个专门的gemset(2.3@Jekyll)给博客。

- Ruby: 2.3
- Gemset: Jekyll
- Jekyll: 3.3
- Minimal mistakes version: 4.0.4

[Minimal mistakes Quick Start Guide](https://mmistakes.github.io/minimal-mistakes/docs/quick-start-guide/)给出了安装这个主题的步骤。

- Fork minimal-mistakes repository
- Rename the repository to yourname.github.io
- Fill your Gemfile, use bundler to install the gems into Jekyll gemset.
- Remove the gh-pages branches and folders in demo site.

如果我们需要升级，可以添加远程上游仓库。由于会修改和定制一些内容，每次升级后需要解决冲突。

```
$ git remote add upstream https://github.com/mmistakes/minimal-mistakes.git
$ git pull upstream master
```

Jekyll的基本原理是将位于_posts目录和_pages目录下的文件，生成为_site目录下的静态文件。主题的仓库里面没有包含这些目录，我们需要生成或者将以前的文章迁移到这里。Jekyll默认有_draft和_post，但是没有_pages。在_config.yml中的include设置包含_pages，所以我们可以直接读取和使用_pages下的文章。

## 定制

 - 在`_config.yml`文件中设置站点和作者的信息，评论系统的设置。设置default front matter。
 - 修改_data/navigations.yml，改变站点的导航栏。每个url对应_pages下面的一个文件，可以是html或者markdown格式。
 - 创建assets/images存放图片，添加头像和缺省的文章图片，将favicon路径指向avatar.png。
 - 设置MathJax。在`_includes/head/custom.html`中引入MathJax脚本CDN路径，注意必须是https协议。由于Github支持https，在_config.yml中也配置了网站的url是使用https，所以要使用https的CDN。在kramdown的配置部分，要指定`math_engine: mathjax`。为了正确设置MathJax，不能使用Compress HTML的特性。因为MathJax的JavaScript需要保留换行。

```
<script type="text/javascript" async src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML"></script>
```

 - 在文章的YAML Front Matter，可以设置CSS class。这个提供了自定义界面风格的极大灵活性。

 ```
 layout: splash
 classes:
   - landing
   - dark-theme

<body class="layout-splash landing dark-theme">
```
 - minimal-mistakes原来的风格适合英文，而且在小屏幕上字体很合适。但是相同字号的中文有点大，而且我主要是想书写数学公式和程序代码，目标是通过桌面的大屏幕来阅读。调整CSS的设置，使得列表（包括toc)的文字大小一致，各个文字段落更加紧凑，调整标题的大小。设置Single布局使用全部宽度，不显示sidebar。
 - 语法高亮使用monoki风格。从github上找到Jekyll兼容的语法高亮CSS定义，不过缺少几项。对code的默认颜色设置为lime(亮绿色)，效果不错。具体的修改参考`_sass/_syntax.scss`文件。

## 运行

`jekyll build`编译生成站点，`jekyll serve`在本地启动一个服务器，通过`127.0.0.1:4000`访问。在使用过程中，可能遇到github api authentication问题，可以在github上建立一个personal token，打开public repo访问权限，设置环境变量JEKYLL_GITHUB_TOKEN，就不会给出警告了。
