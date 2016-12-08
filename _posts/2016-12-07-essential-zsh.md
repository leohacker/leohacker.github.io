---
title: "Essential zsh"
excerpt:
date: 2016-12-07 14:29:17
modified: 2016-12-08
categories: [Linux]
published: false
---
{% include toc %}

## Zsh features
ZSH作为用户终端Shell，吸引用户的主要是帮助用户更简洁的输入，改变用户交互的方式，提供更多有效的
信息。本质上，ZSH改变只是输入过程，实际传递给Shell编程接口解释和执行的还是真正的命令，所以很多
功能都是发挥TAB的作用，让你快捷地输入或扩展参数。

### Completion
ZSH提供比Bash更好的补全功能。在Bash中，我们可以用TAB补齐命令，当前目录和文件。ZSH的补齐则支持
命令，参数选项(option)，路径，而且键入两次TAB后，光标在多个候选之间游历，用户可以直接回车选择。
如果输入部分string，zsh会缩小匹配的范围。而且匹配不要求必须是前缀，可以是任意位置开始的substring，
所以非常的智能。另外，zsh还支持匹配远程服务器上的路径，amazing!

例如这篇博客的文件是 2016-12-07-essential-zsh.md，我用编辑器打开的时候可以输入`atom zsh`，
然后TAB，ZSH会帮我匹配这个文件的全名。

### Path
在ZSH中，输入路径的时候可以不用一级一级的TAB扩展。如果你准确的知道路径，可以只输入首字母或
可以区分的前缀。例如`ls /u/l/b`，想匹配`/usr/local/bin`，不过由于`/usr/lib`的存在，要输入
`/u/lo/b`，然后TAB，缩写路径就会扩展为匹配的实际路径。

autocd功能，你不需要输入命令cd，而是直接输入目录名字，回车，done! 同时也提供了`...`这样的alias，
让你可以快速移动。在配合Z这样的插件，迅速进入常用目录。让盯着你屏幕看的人lost吧，太爽了。

甚至还有一个更意想不到的功能，path replacement。假设你想进入/usr/locale/share目录，但是你
手指把你带到了`cd /u/lo/b`，这是当前目录已经是`/usr/local/bin`，你可以`cd bin share`来修正
路径。而且可以不是当前目录层，例如
```
cd  /srv/www/site1/current/log
cd site1 site2
pwd => /srv/www/site2/current/log
```
好吧，实在是太强大了。

### Globb
在zsh中甚至可以不使用find命令，而用`ls **/filename`代替。这个特殊`**`表示匹配任意层目录，而`*`
表示仅匹配一层。这种globbing匹配方式本质在命令上展开所有匹配的文件路径，所以如果其他命令可以接受
多个参数，也是适用的。例如`wc -l **/*.md`，计算博客文章的行数。

### Command
Ctrl-R是我常用的历史回溯命令，方便我找到用过的命令。在ZSH中，可以输入开头的几个字符，然后就可以
用光标键在历史记录的命令中回溯。ZSH的历史记录与bash不同，是所有session共享的，这点也很方便。

ZSH会自动帮助我们做检查，发现输入的命令错误，提示正确的候选命令。

如果是输入很长的命令，C-x C-e会打开$EDITOR编辑器，让你编辑当前命令。

### Environment
在ZSH中可以用TAB扩展环境变量，这样就不需要`echo $ENV`。`vared`命令可以编辑环境变量。

### Kill Completion
ZSH的kill命令也得到改进，你可以输入kill <TAB>，就会试图匹配所有进程，不过需要列出的进程太多。
类似其他补齐，你可以输入启动进程的命令的开头几个字符，就会缩小范围，也类似补齐当前文件目录一样，
可以在多个候选中遍历。这对于要手动杀死进程的时候，实在是太方便了。

### Name the tab with running process
### Alt + / to nav the arguments

### Alias
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
```

## Oh-my-zsh
通常长时间不关闭MBP，所以很难有机会让Oh-my-zsh更新。这时我们可以手动更新: `upgrade_oh_my_zsh`。


### Z
jump to your favorite folder

zsh-syntax-highlighting

autocd

zmv

alias zcp='noglob zmv -C'
alias zln='noglob zmv -L'
alias zmv='noglob zmv'
