---
title: "Essential rsync"
excerpt: rsync的基本使用
date: 2016-11-26 16:12:47
categories: [Linux]
published: true
---
{% include toc %}


```
# copy the src/bar to /data/dest/bar, will create a new directory 'bar' in dest.
rsync -avz src/bar /data/dest

# copy the content of bar to /data/dest
rsync -avz src/bar/ /data/dest

# copy the content of bar into /data/dest/bar
rsycn -avz src/bar/ /data/dest/bar

# list files if no dest specified.
rsycn -avz somehost:
```

`~`符号如果是起始的字符，会被Shell转换为用户目录，但是如果是`--option=~/foo`就不会，这种情况要
使用`--option ~/foo`的形式。


### Options

```
-q, --quite
  静音模式，适合在cron任务的情况下使用

-I, --ignore-times
  关闭快速比较算法的时间戳条件，这导致所有文件都会被更新。

--size-only
  如果你使用了其他同步工具，而这个工具不能很好的保留修改时间戳，然后在使用rsync的时候，可以将快速比较算法改为只比较文件大小。

-c, --checksum
  你也可以让rsync在传输前使用checksum的方式比较文件，而不是使用快速比较算法。
  无论那种算法，rsync都会在传输完毕后使用checksum验证文件正确传输。rsync是使用MD5算法计算checksum。

-a, --archive
  等价于 -rlptgoD, recursive, copy symlink, preserve permission, modification time,
  group, owner, copy devices and specials files.

--no-OPTION
  允许你在使用其他选项的同时，关闭某些选项，尤其在使用-a的情况下有用。例如 -a --no-o ，保留其他信息但不包括owner信息。
  在这里，顺序是重要的。

-r, --recursive
  rsync在版本3.0.0后使用incremental scan，在完成一些目录的扫描后就开始传输。有些选项要求知道所有的文件列表，例如--delete-before,
  --delete-after,  --prune-empty-dirs, --delay-updates。

# Backup
-R, --relative
  将命令行上的src的路径发送给server端，作为相对路径。
  rsync -avR /foo/bar/baz.c remote:/tmp/ 将得到 remote:/tmp/foo/bar/baz.c
  rsync -avR /foo/./bar/baz.c remote:/tmp/ 将得到 remote:/tmp/bar/baz.c， 重点是使用.来限定路径的起始位置。

  --no-implied-dirs
    在使用-R的时候，源路径是path/foo/bar，path和path/foo被成为implied directory。使用这个选项，implied directory的属性不会传输。
    如果目标端有这个目录，就使用现有的目录，如果没有，就用缺省的属性创建新的目录。如果目标端的目录path或者path是符号链接，正常情况下这个
    符号链接会被删除，然后创建目录path/foo。
    如果想保持目标端的现有的符号链接目录，就可以使用no-implied-dirs选项。类似的可以使用keep-dirlinks选项。

-b, --backup
  对更新的文件做备份，可以使用backup-dir选项设置备份的目录，suffix设置备份的后缀。

-u, --update
  更新模式，如果目标端的文件更新，就不传输。

-n, --dry-run
  和verbose，itemize-changes一起使用，模拟实际运行。


# 处理大文件
--inplace
  inplace的更新方式显然很危险，不过在处理大文件的时候，或者要保持硬链接的时候，或者在一个copy-on-write的文件系统上，有用。
--append
--append-verify
  传输文件的时候，假设文件开头的部分是相同的，只有尾部的数据是新添加的。显然只针对某些数据文件。verify版本的选项会在结束后校验，如果不同，
  就使用inplace的方式重新传输。

--max-size=SIZE

# 符号链接
-l, --links
  保持符号链接。
-L, --copy-links,
  拷贝链接的目标文件，而不是链接。
--copy-unsafe-links
  拷贝符号链接，即使这些链接指向拷贝的目录书外面的文件。
--safe-links
  忽略unsafe links，所有的absolute symlink也忽略。不要将这个选项和relative一起使用。
--munge-links
  munge符号链接为一种不可用的状态，即指向一个不存在的目录。或者将一个处于munged存储状态的符号链接恢复。
  如果要对接收端使用这个功能，要使用--remote-option选项。
-k, --copy-dirlinks
  拷贝目录的符号链接。当发送方是符号链接的目录，而接收方是真实的目录，如果不使用这个选项，接收方的目录会被删除。
-K, --keep-dirlinks
  保持目录的符号链接。当发送方是真实目录，而接收方是符号链接目录，如果不使用这个选项，接收方的符号链接会被删除。

# 删除多余文件
--delete
  在接收端删除发送端没有的文件。实际删除文件前，最好用dry run先查看会删除哪些文件。
--delete-before
  在传输前删除，可以腾出接收端的磁盘空间。
--delete-during, --del
  在传输每个目录前扫描和删除。

# files-from
--ignore-missing-args
  如果某个列出的文件不存在，不生成出错信息，忽略这个文件。
--delete-missing-args
  如果某个列出的文件不存在，在接收端删除这个文件。

#
-M, --remote-option=OPTION
  rsync -av -M --log-file=foo -M--fake-super src/ dest/  最好多次指定需要在接收端使用的选项。
  rsync -av -x -M--no-x  src/ dest/ 有的选项是在两端都有作用的，在接收端指定nagtive的选项，可以让其只作用于发送端。

-C, --cvs-exclude
  忽略各种版本管理文件和目录，备份文件。
  RCS SCCS CVS CVS.adm RCSLOG cvslog.* tags TAGS .make.state .nse_depinfo *~ #* .#* ,* _$* *$ *.old *.bak *.BAK
  *.orig *.rej .del-* *.a *.olb *.o  *.obj *.so *.exe *.Z *.elc *.ln core .svn/ .git/ .hg/ .bzr/

```
