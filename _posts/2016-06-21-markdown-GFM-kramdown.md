---
title: "Markdown, GFM and Kramdown in Jekyll"
excerpt: 记录Markdown的标准语法，GFM的扩展语法，Kramdown语法，以及在Jekyll里面写作用的Liquid标记。
date: 2016-06-22 22:45
categories: [Programmer]
published: true
---
{% include toc %}

本文中多数语法的示例能被Kramdown支持的，都采用实际显示的方式展示，具体的语法书写可以查看源码。

## Markdown Syntax
一篇文章的基本单元是章节，段落，引用，列表，程序员常用的代码块，多数文章中还会嵌入链接，图片，适当的排版。Markdown的主要特性包括:

 - inline HTML
 - automatic paragraphs
 - headers
 - blockquotes
 - lists
 - code block
 - links
 - images

### Header
Header是用多个`#`来表示。段落依靠连续两个回车来分割，类似Latex语法，一个回车不会对段落的分割起作用。
如果你确实想要一个硬回车，而且不产生一个新段落，在行尾输入两个空格，然后一个回车。

### Blockquotes
引用使用`<`作段落的前缀，可以给每一行加前缀，也可以只给第一行加。引用可以嵌套，即使用多个`<`做段落的前缀。
在引用的文字中，支持Markdown语法，也可以有Header, 列表，代码块。

### List
列表有无序和有序的，无序的用`*+-`这几个符号，有序的用数字。列表也支持多段落，某一项可以是多个段落。
列表项中可以使用引用和代码块等语法。

### Code block
递进4个空格就是代码块了，Markdown语法在代码块中是无效的。

### Link
链接在Markdown中有两种形式，inline和reference，链接可以是相对路径。

 - `[Text](real link "optional title")`
 - `[Text][link definition]`
 - `[link definition]: real link "title"`

Link Definition仅仅用于方便Markdown文件的书写和处理，不会出现在HTML的输出中。Link Definition可以递进两个空格。
如果不提供文字作为Link Definition，就使用Text作为Link Definition。

如果想自动书写链接，可以用尖括号包围。

 - <http://www.google.com>
 - <username@example.com>

图片的语法和链接相似。

 - `![Text](/path/to/img) "optional title"`
 - `![Text](id)`
 - `[id]: /path/to/img "title"`

### Styling
Markdown也提供了基本的格式语法

 - 单个 `*` 或者 `_` 斜体 Italic
 - 两个 `*` 或者 `_` 粗体 Bold
 - 三个 Horizontal line
 - \` (backtick) 內联代码

### Inline HTML
Markdown和HTML语法是可以兼容的，可以直接书写HTML语句在一个Markdown文件中，当然不推荐。
Markdown会正确的处理特殊字符的转义问题，如果是`&copy;`会被保留`&`字符，从而在HTML中产生&copy;；
如果是 A & B，则会被转义为`&amp;`，从而正确现实为A & B。类似的特殊字符有`<`。

## GFM
GFM改进了代码块和链接，额外的提供了任务列表和表格，结合Github自己的特点，提供了Issue,  PR和Commit链接。不过GFM不支持footnote的。GFM在格式上改进包括用两个 `~` 表示删除。

### GFM Code block
在GFM中可以使用三个backtick来引用代码块，而且可以指定语言。参考GFM[支持的语言](https://github.com/github/linguist/blob/master/lib/linguist/languages.yml)

    ```bash
    git push
    ```

### GFM表格

| Left-aligned | Center-aligned | Right-aligned |
| :---         |     :---:      |          ---: |
| git status   | git status     | git status    |
| git diff     | git diff       | git diff      |

### GFM Autolink

Kramdown支持GFM输入，autolink特性似乎是不支持。

### Github专用
GFM也提供一些只在Github中使用的特性。在GFM中，不需要尖括号也可以自动链接。
例如直接写http://www.google.com。支持引用Issue，Pull Request，commit SHA，
或者@mention某个人或者组织。

 - `#number`
 - `username#number`
 - `username/Repository#number`
 - `username/REpository@SHA`
 - `@github/support`

任务列表

    - [ ] task description
    - [X] completed task

## Kramdown
在Atom编辑器中书写的时候，是采用Markdown Preview Plus来预览的。
Markdown Preview Plus是Atom自带的Markdown Preview的fork版本，不完全支持Kramdown的语法，
所以很多Kramdown特有的语法不能得到正确显示。

### Image
可以使用attributes指定图像的宽高。

```markdown
Here is an inline ![smiley](smiley.png){:height="36px" width="36px"}.

And here is a referenced ![smile]

[smile]: smile.png
{: height="36px" width="36px"}
```

### Table
从实际效果看，Github不支持。
|-----------------+------------+-----------------+----------------|
| Default aligned |Left aligned| Center aligned  | Right aligned  |
|-----------------|:-----------|:---------------:|---------------:|
| First body part |Second cell | Third cell      | fourth cell    |
| Second line     |foo         | **strong**      | baz            |
| Third line      |quux        | baz             | bar            |
|-----------------+------------+-----------------+----------------|
| Second body     |            |                 |                |
| 2 line          |            |                 |                |
|=================+============+=================+================|
| Footer row      |            |                 |                |
|-----------------+------------+-----------------+----------------|

### Math
写一个inline公式 $$a_i$$

$$
\begin{align*}
  & \phi(x,y) = \phi \left(\sum_{i=1}^n x_ie_i, \sum_{j=1}^n y_je_j \right)
  = \sum_{i=1}^n \sum_{j=1}^n x_i y_j \phi(e_i, e_j) = \\
  & (x_1, \ldots, x_n) \left( \begin{array}{ccc}
      \phi(e_1, e_1) & \cdots & \phi(e_1, e_n) \\
      \vdots & \ddots & \vdots \\
      \phi(e_n, e_1) & \cdots & \phi(e_n, e_n)
    \end{array} \right)
  \left( \begin{array}{c}
      y_1 \\
      \vdots \\
      y_n
    \end{array} \right)
\end{align*}
$$

由于MathJax对于产生的HTML有格式上的要求(CDATA中的换行)，不能使用HTML压缩。所以在设计和使用Jekyll主题的时候，不能使用Jekyll-Compress-HTML。

### Footnotes
This is some text.[^1]. Other text.[^footnote].

[^1]: First footnote
[^footnote]: Second footnote

### Definition List
效果如下：

ES6/ES2015
:   The new version of the popular JavaScript language

### Abbreviations
This is some text not written in HTML but in another language!

*[another language]: It's called Markdown
*[HTML]: HyperTextMarkupLanguage

## Jekyll Theme -- Minimal Mistake

### Teaser Image
在_config.yml里面可以设置缺省的`teaser: "500x300.png"`，在Front Matter里面可以设置

```
header:
  teaser: my-awesome-post-teaser.jpg
```

### Utility Classes
https://mmistakes.github.io/minimal-mistakes/docs/utility-classes/

## Customization TODO

 - FancyBox 显示图片 http://fancyapps.com/fancybox/
 - Github Syntax Highlight https://github.com/mojombo/tpw/blob/master/css/syntax.css
