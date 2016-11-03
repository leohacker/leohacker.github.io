---
layout: post
title: "Access Github via SSH or HTTPS"
date: 2014-04-17 16:45
comments: true
categories: [Git]
published: true
---

## SSH or HTTPS
访问GitHub仓库有两种方式：通过git协议和HTTPS协议。GitHub官方推荐使用HTTPS协议方式，原因是通过HTTPS你可以透过防火墙访问仓库，而SSH方式会被屏蔽。一个典型的应用场景就是公司很可能封闭了git协议使用的端口，但是一般都会开放HTTPS协议端口。如果你在防火墙后面，还是想使用SSH方式的话，可以参考`Using SSH over the HTTPS port`。

SSH方式很简单，创建和配置好SSH Key就可以使用了。遵循`Generating ssh keys`中的步骤，就可以轻易的配置好SSH Key。建议先特别为自己创建一个SSH Key，然后在其他所有需要SSH Key的服务程序上都配置相同的秘钥，以方便管理。

## Caching the password
使用HTTPS方式，我们在每次操作的时候，会被提示要求输入密码，不胜其烦。在Mac系统上，我们可以使用一个Credential Helper程序osxkeychain将密码存储在mac系统中。参考`Caching you GitHub password in git`。

那么在Linux系统上，有什么办法吗？
 - `git config --global credential.helper 'cache --timeout 3600'`
 - .netrc
 - gnome-keyring

据说gnome-keyring并不好用，所以不做研究。根据[这篇文章](https://confluence.atlassian.com/display/STASH/Permanently+authenticating+with+Git+repositories) `.netrc`的方式可以用，不过要小心。git使用cURL来访问仓库，系统中的其他程序也可能会用到cURL，那么它们也可能用到你在`.netrc`中的认证信息，就可能出错了。所以在Linux上比较靠谱的方法，还是尽可能的用SSH方式访问仓库。

## References
 - [Which remote url should I use](https://help.github.com/articles/which-remote-url-should-i-use/)
 - [Generating ssh keys](https://help.github.com/articles/generating-ssh-keys/)
 - [Caching you GitHub password in git](https://help.github.com/articles/caching-your-github-password-in-git/)
