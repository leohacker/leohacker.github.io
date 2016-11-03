---
title: "Setup Linux Machine"
excerpt: 记录设置日常使用的Linux机器所需要的步骤
date: 2016-07-10 21:55
categories: [Linux]
published: false
---
{% include toc %}

## System

### Driver
打算经常使用的机器是Intel NUC5I7RYH，2015年11月制造，还挺新的。在安装Ubuntu 14.04的时候，没有设置正确的显卡驱动，导致启动后黑屏，无法进入系统。
在Ubuntu 16.04 LTS中已经正确集成了i915驱动。查看Intel的官方网站，已经说明不提供16.04上的驱动安装程序，只是为15.10和Fedora提供。

### Steps
  - 删除多余的软件包，例如OpenOffice，游戏。
  - 安装语言包，安装输入法。
    - 安装输入法参考拼音舟网站上的说明。
  - 修改用户的PATH环境变量。
    - Ubuntu系统默认的路径中包含`/usr/games`和`/usr/local/games`，这两个路径是在系统的`/etc/environment`中设置的。
  - 实现翻墙功能
    - 安装shadowsocks
    - 安装Firefox的代理扩展用来翻墙下载Chrome
    - 下载Chrome和ProxyOmega的离线安装包
    - 配置ProxyOmega实现浏览器翻墙
    - 安装proxy-chains实现命令行翻墙
  - 设置SSH Key和字体
    - SSH Key
    - 安装字体到.local/share/fonts
      - Powerline fonts https://github.com/powerline/fonts
      - Adobe Source Han Sans https://github.com/adobe-fonts/source-han-sans
  - 安装和配置zsh
    - zsh使用`.profile`

### Input Method

### GFW
//TODO write down the tuturial of tools.

## Software
  - Git
  - Vim
  - tmux
  - RVM

安装Git，克隆MagicBox仓库。vim, tmux, 拷贝配置文件就可以。
配置git需要运行`gitconfig.linux.sh`创建git的用户配置文件。

## zsh
https://www-s.acm.illinois.edu/workshops/zsh/toc.html

global alias
```
alias -g prc=~/.procmailrc
alias -m 'foo' # search an alias
unalias foo
disable -a foo  # disable temporarily
enable -a foo   # enable it back
\curl 		# use the real curl, not alias
```
ls -l array{5d,MYd,BIG}
touch logfile.9908{01..31}.tmp

## Atom
install font for zsh and atom


## RVM
In order to make rvm command as shell function, set the gnome-terminal to use login shell.
Edit > Profile Preferences > Command > Run command as a login shell

## Jekyll Blog

## Linux commands
 - whence
   return non-zero if failed, but no error msg.
