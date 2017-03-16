---
title: "Essential Z Shell and Oh My Zsh"
excerpt: 介绍ZShell和Oh My Zsh
date: 2016-12-07 14:29:17
modified: 2016-12-08
categories: [Linux]
published: true
---
{% include toc %}

Zsh作为用户终端Shell，吸引用户的主要是帮助用户更简洁的输入，改变用户交互的方式，提供更多有效的
信息。本质上，Zsh改变的只是输入过程，实际传递给Shell编程接口解释和执行的还是真正的命令，所以很多
功能都是发挥TAB的作用，让你快捷地输入或扩展参数。

虽然也存在其他Zsh配套的框架工具，不过Oh My Zsh大名顶顶，几乎就是zsh的代名词，使用也不复杂。
没有插件管理，不过似乎问题也不大。

References:

 - [Oh My Zsh](https://github.com/robbyrussell/oh-my-zsh/)
 - [Blog](http://reasoniamhere.com/2014/01/11/outrageously-useful-tips-to-master-your-z-shell/)
 - [Slide](http://www.slideshare.net/jaguardesignstudio/why-zsh-is-cooler-than-your-shell-16194692)

## Completion
ZSH提供比Bash更好的补全功能。在Bash中，我们可以用TAB补齐命令，当前目录和文件。ZSH的补齐则支持
命令，参数选项(option)，路径，而且键入两次TAB后，光标在多个候选之间游历，用户可以直接回车选择。
参数选项，子命令的补全通常是由各种软件对应的插件支持，插件一般也会提供一些alias。

### Hippie Complete
在Bash中我通常使用`Alt + .`来补全最后一个参数。Zsh则带给我们`Alt + /`补全，hippie completion，根据
你的输入历史补全当前部分输入的参数。这是一个更通用的补全策略。

### Path Complete
路径补全是最基础和最常用的。在Zsh中，如果输入部分string，zsh会缩小匹配的范围。而且匹配不要求必须是前缀，
可以是任意位置开始的substring，所以非常的智能。另外，zsh还支持匹配远程服务器上的路径，Amazing!
例如这篇博客的文件是 2016-12-07-essential-zsh.md，我用编辑器打开的时候可以输入`atom zsh`，
然后TAB，ZSH会帮我匹配这个文件的全名。

对于路径的补全，还支持路径扩展的概念，输入路径的时候可以不用一级一级的TAB扩展。如果你准确的知道路径，
可以只输入首字母或可以区分的前缀。例如`ls /u/l/b`，想匹配`/usr/local/bin`，不过由于`/usr/lib`的存在，
要输入`/u/lo/b`，然后TAB，缩写路径就会扩展为匹配的实际路径。

### Directory Navigation
Zsh中有directory stack的概念，你可以输入命令'd'显示最近访问的目录。目录栈里面的目录有数字序号，
可以直接输入序号切换目录。还有autocd功能，你不需要输入命令cd，而是直接输入目录名字，回车，done!
进一步也提供了`...`和`....`这样的alias，让你可以快速移动。觉得这还不够好，我们有autojump和z的插件，
迅速进入常用目录。让盯着你屏幕看的人lost吧，太爽了。

甚至还有一个更意想不到的功能，路径替换path replacement。假设你想进入/usr/locale/share目录，
但是你手指把你带到了`cd /u/lo/b`，这是当前目录已经是`/usr/local/bin`，你可以`cd bin share`
来修正路径。而且可以不是当前目录层，例如
```
cd  /srv/www/site1/current/log
cd site1 site2
pwd => /srv/www/site2/current/log
```
好吧，实在是太强大了。

## Command and Environment
`C-r`是我常用的历史回溯命令，方便我找到用过的命令。在ZSH中，可以输入开头的几个字符，然后就可以
用光标键在历史记录的命令中回溯。ZSH的历史记录与bash不同，是所有shell session共享的，这点也很方便。
zsh-history-substring-search提供了fish shell like历史查找功能。

也可以打开Auto Correction模式，ZSH会自动帮助我们做检查，发现输入的命令错误，提示正确的候选命令。

如果是输入很长的命令，C-x C-e会打开`$EDITOR`编辑器，让你编辑当前命令。

环境变量也可以用`vared`命令编辑。在ZSH中可以用TAB扩展环境变量，这样就不需要`echo $ENV`。

## Alias
```bash
# suffix alias 用指定的编辑器打开某种后缀的文件。
$ alias -s cpp=vim
$ alias -s log="less -MN"

$ test.cpp
$ dev.log

# global alias 在任何位置可以展开的alias，不仅仅是命令的开始位置
$ alias -g ...='../..'
$ cd ...

$ alias -g X='| xargs'
$ find . -name "*.pyc" -type f -print X /bin/rm -f

$ alias -g gp='| grep -i'
$ ps ax gp ruby

# Flag	Description
# L	print each alias in the form of calls to alias
# g	list or define global aliases
# m	print aliases matching specified pattern
# r	list or define regular aliases
# s	list or define suffix aliases
```

## Globbing
在zsh中甚至可以不使用find命令，而用`ls **/filename`代替。这个特殊`**`表示匹配任意层目录，而`*`
表示仅匹配一层。这种globbing匹配方式本质在命令上展开所有匹配的文件路径，所以如果其他命令可以接受
多个参数，也是适用的。例如`wc -l **/*.md`，计算博客文章的行数。

Zsh也支持带有正则特点的globbing。

```
# list text files that end in a number from 1 to 10
ls -l zsh_demo/**/*<1-10>.txt

# list text files that start with the letter a
ls -l zsh_demo/**/[a]*.txt

# list text files that start with either ab or bc
ls -l zsh_demo/**/(ab|bc)*.txt

# list text files that don't start with a lower or uppercase c
ls -l zsh_demo/**/[^cC]*.txt
```

Zsh Globbing有一种后缀的Globbing Qualifier，实现基于文件属性的过滤。

```

# show only directories
print -l zsh_demo/**/*(/)

# show only regular files
print -l zsh_demo/**/*(.)

# show empty files
ls -l zsh_demo/**/*(L0)

# show files greater than 3 KB
ls -l zsh_demo/**/*(Lk+3)

# show files modified in the last hour
print -l zsh_demo/**/*(mh-1)

# sort files from most to least recently modified and show the last 3
ls -l zsh_demo/**/*(om[1,3])
```

上面的例子来自[Blog](http://reasoniamhere.com/2014/01/11/outrageously-useful-tips-to-master-your-z-shell/)，
在这篇博客里面还介绍了参数扩展的modifier和flag，说实话这种记不住的东西没有用处。


## Kill Completion
ZSH的kill命令也得到改进，你可以输入kill <TAB>，就会试图匹配所有进程，不过需要列出的进程太多。
类似其他补齐，你可以输入启动进程的命令的开头几个字符，就会缩小范围，也类似补齐当前文件目录一样，
可以在多个候选中遍历。这对于要手动杀死进程的时候，实在是太方便了。

## Oh-my-zsh
Mac用户通常长时间不关闭MBP，所以很难有机会让Oh-my-zsh更新，我们可以手动更新: `upgrade_oh_my_zsh`。
如果要安装非Oh-my-zsh默认的插件，应该安装到zsh_custom/plugins目录。自己定制的主题放在zsh_custom/themes下面。

Plugins:
 - autoenv
 - z
 - docker
 - git
 - jira  https://github.com/robbyrussell/oh-my-zsh/tree/master/plugins/jira
 - mercurial https://github.com/robbyrussell/oh-my-zsh/tree/master/plugins/mercurial
 - zsh-autosuggestion
 - zsh-history-substring-search
 - zsh-syntax-highlighting

### zsh-syntax-highlighting
在`~/.oh-my-zsh/custom/plugins`目录克隆`https://github.com/zsh-users/zsh-syntax-highlighting.git`，
然后将zsh-syntax-highlighting添加为最后一个插件。此插件对zsh的其他部分有一个依赖，所以必须是最后一个插件。
