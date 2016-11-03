---
layout: post
title: "Essential Customization for Octopress Blog System"
date: 2013-09-01 21:33
comments: true
categories: [Octopress]
published: true
toc: true
---

## Nothing at all

在原生的Octopress博客系统中，连comment系统都没有，其他的像recent post, popular post也是一概都没有的。我们不得不用黑客的方式一一加上。那么列举一下那些几乎是必须的功能：

- Comments
- Recent posts
- Popular posts
- Categories
- Social
- Related posts

作为博客系统事实上的霸主，[Wordpress](wordpress.com)现在是越来越强大了，登录进去后，你可以看到详细的网站数据统计。看着那些每天的流量，曾经倦怠的心情也会充满动力。相对而言，我们不能在Octopress这样的静态博客系统上去构建这么复杂的系统。可是作为博客的基本功能还是应该提供的撒。没有Comments和Categories功能的博客是没法用的。所以我们可以参考[3rd party plugins](https://github.com/imathis/octopress/wiki/3rd-party-plugins)来设置你需要的功能。

<!-- more -->

## Plugins

### Comments
当然Octopress是支持Comments的，不过需要集成Disqus这种社会化留言系统。对于Disqus的支持已经具有，只差最后一步。到[Disqus](disqus.com)去注册一个账号，然后在`_config.yml`配置文件中设置。
``` yml Disqus configuration
disqus_short_name: yourname
disqus_show_comment_count: true
```

### Categories
在Octopress博客系统中，我们使用Markdown语法写post。在文件头中，我们指定post的元数据，包括category。也就是说Octopress已经支持category来分类每篇博客文章。

``` text Post header
---
layout: post
title: "Essential Customization for Octopress Blog System"
date: 2013-09-01 21:33
comments: true
categories: [Octopress]
---
```

问题是没有一个widget帮我们把这些category分类整理后放在边栏上。有两种常见的category组织形式：

- [category tree](https://github.com/matthiasbeyer/jekyll_category_tree)
- [category list](https://github.com/alswl/octopress-category-list)

Category tree是我想要的，但是我没有配置成功。Category list是中国人在原来category list的基础上的改进版本，我目前就使用这个。如果Blog的主题比较集中的话，用一个平行结构的category list也挺好。

### Recent posts
Recent posts功能是内置的，你首先可以感受到的边栏widget。在 `octopress/source/_includes/asides` 目录，我们可以看到有个 `recent_posts.html` 文件，这里面就是`recent posts`的模板。同理，我们也会在`asides`目录添加其他widget。实际上，我们定制的widget是放在`octopress/source/_includes/custom/asides`目录。

在我的`custom/asides`目录中的文件。不是每个文件都必须启用，我们可以在`_config.yml`配置一个列表来指定出现在边栏上的widget。
``` bash list of widgets in asides
about.html
category_cloud.html
category_list.html
popular_posts.html
related.html
weibo.html
```

### Popular posts
[Popular posts](https://github.com/octothemes/popular-posts) 基于page rank算法。这个插件通过Ruby gems发布，所以我们可以方便的安装。

``` bash install plugin
gem 'octopress-popular-posts'
bundle install
rake generate
```
在配置文件中，设置显示post的个数，设置popular posts在边栏的位置。

``` yml configure
popular_posts_count: 5      # Posts in the sidebar Popular Posts section
default_asides: [custom/asides/about.html, custom/asides/popular_posts.html, asides/recent_posts.html, asides/github.html]
```
插件会生成一个.page_ranks目录，因为里面都是cache文件，我们可以将这个目录添加到.gitignore中。

如果需要更新或者删除。

``` bash update or remove plugin
# update plugin
bundle exec octopress-popular-posts install
# remove plugin
bundle exec octopress-popular-posts remove
```

### Related posts
Related posts也是我喜欢的功能，在wordpress中通常也需要自己加插件达到这个功能。这个功能已经在Jekyll中提供了，我们可以参照 [https://github.com/jcftang/octopress-relatedposts]的说明设置。

``` yml Configuration mark:1
lsi: true
default_asides: [custom/asides/related.html, ...]
```

``` php related.html
<section>
    <h1>Related Posts</h1>
    <ul class="posts">
    {% for post in site.related_posts limit:5 %}
        <li class="related">
        <a href="{{ root_url }}{{ post.url }}">{{ post.title }}</a>
        </li>
    {% endfor %}
    </ul>
</section>
```

### Social
系统默认支持很多Social的button，但是作为活在墙里的人，我们的选择是微博 weibo。可以参考微博官方网站上的说明创建代码片段，然后作为文件weibo.html放到asides目录下。方法和其他plugin类似。

### TOC
采用JQuery TOC 插件的方式支持产生TOC。这篇Blog详细的说明了如何添加JS文件，修改head和after_footer HTML文件。重要的是还有CSS的配置，否则一个难看的目录放在前面也挺闹心的。

- http://brizzled.clapper.org/blog/2012/02/04/generating-a-table-of-contents-in-octopress/

### LaTeX
Octopress的默认markdown解释器rdiscount不支持LaTeX公式，Maruku是可以支持MathJax的，但是Maruku在解释Markdown的代码块的时候和现在github风格有些不兼容，过于严格了。我虽然努力的修改了Post里面的代码块，但是最后还是有个莫名的错误。只好放弃了，虽然LaTeX公式在Octopress里面渲染的很漂亮。

而且如果Maruku可行的话，可能也不用费力用JQuery来实现TOC，据说Maruku是支持TOC的标记的。

## Font size and style
我们可以在 sass/custom/目录中找到调整color, font, layout, style的SCSS配置文件。我将自定义的配置都放在了`_style.scss`文件中。主要的修改是针对Octopress原来theme中header的硕大的字体。

需要小心的是，我发现：修改css配置后可能导致博客系统不正常。例如，会将published:false的页面发布出来。Octopress系统给我的感觉是，即使修改一个很可能无关的地方，都可能导致行为异常。目前我的代码snippet功能的start和mark标记不被识别，不知道是upstream系统的问题，还是某个配置导致的奇怪行为。



