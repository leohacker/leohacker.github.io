---
title: "Essential rsync"
excerpt: rsync的基本使用
date: 2016-11-26 16:12:47
categories: [Linux]
published: true
---
{% include toc %}

## 基础

### 原理
rsync是镜像同步和备份工具，主要的作用是在两个目录之间拷贝文件。rsync采用只传输变化部分的算法，
所以效率非常高。原理基本上就是，比较发送端和接收端的目录和文件，根据文件的大小和修改时间等判断文件
是否需要更新，然后比较文件的差异，传输差异部分的块(block)。

在应用场景上，设计时考虑了文件系统，符号链接，磁盘空间大小，网络连接带宽，中断的处理，大文件传输等问题。
在生成需要同步的拷贝文件列表后，用户可以指定过滤规则使得可以准确的传输要同步的文件。也提供了方便的删除
不需要的文件的选项。

从使用的角度，我们可以从一般同步本地和服务器目录的角度了解基本的时候方式，也可以从系统管理员的角度以备份
为目的来理解rsync的功能。原来有使用rsync来达到备份系统，恢复系统，同步多个系统的用法，不过现在DevOps
主要使用虚拟机，软件配置工具(puppet)，Docker，就没有必要在这些关键的领域使用rsync，毕竟rsync有同步失败，
非原子化，有状态不一致的可能。

### 语法
rsync的语法就是`rsync [options...] src... [dest]`，可以有多个源目录，不过通常只有一个。发送端
和接收端可以是服务器端`user@host:path`，但是不支持两个服务器同步，一定是一个本地，一个远程。

```bash
# copy the src/bar to /data/dest/bar, will create a new directory 'bar' in dest.
rsync -avz src/bar /data/dest

# copy the content of bar to /data/dest
rsync -avz src/bar/ /data/dest

# copy the content of bar into /data/dest/bar
rsycn -avz src/bar/ /data/dest/bar

# list files if no dest specified.
rsycn -avz somehost:
```

我们可以理解为将最后一个路径分隔字符后的目录和文件内容传输给接收端。如果不指定接收端，就列出所有文件。

## 选项（Options）
选项的设计满足了使用rsync的各种用户场景。首先让我们先说一个使用选项(option)时候需要注意的小技巧。
~符号如果是起始的字符，会被Shell转换为用户目录，但是如果是`--option=~/foo`就不会，
这种情况要使用`--option ~/foo`的形式。

下面主要根据选项的分类记录其用法，这里仅包括部分，特别常用的(vz)和比较偏门用法的没有列出。

### 一般选项

```
# General
-q, --quite
  静音模式，适合在cron任务的情况下使用

-n, --dry-run
  和verbose，itemize-changes一起使用，模拟实际运行。

-i, --itemize-changes
  列出所有变化的文件和信息。

--no-OPTION
  允许你在使用其他选项的同时，关闭某些选项，尤其在使用-a的情况下有用。例如 -a --no-o ，保留其他信息但不包括owner信息。
  在这里，顺序是重要的。

-M, --remote-option=OPTION
  rsync -av -M --log-file=foo -M--fake-super src/ dest/  最好多次指定需要在接收端使用的选项。
  rsync -av -x -M--no-x  src/ dest/ 有的选项是在两端都有作用的，在接收端指定nagtive的选项，可以让其只作用于发送端。

--log-file=FILE
  rsync -av --M=--log-file=/tmp/rlog src/ dest 在服务器端保存log，尤其是在调试rsync为什么会意外关闭的时候有用。
  还可以使用log-file-format来指定为每个更新的文件的log记录的格式。

--stats
  给出统计信息。
-h, --human-readable
  human readable数字格式。三个level，缺省是一个h，如果要以1000为单位就是 -hh ，以1024为单位就是 -hhh。
  如果要没有格式的数字，-no=h。
```

### 比较算法
```
-I, --ignore-times
  关闭快速比较算法的时间戳条件，即不跳过大小和时间匹配的文件，这导致所有文件都会被更新。

--size-only
  如果你使用了其他同步工具，而这个工具不能很好的保留修改时间戳，然后在使用rsync的时候，可以将快速比较算法改为只比较文件大小。

-c, --checksum
  你也可以让rsync在传输前使用checksum的方式比较文件，而不是使用快速比较算法。
  无论那种算法，rsync都会在传输完毕后使用checksum验证文件正确传输。rsync是使用MD5算法计算checksum。

-O, --omit-dir-times
  omit directories from --times
-J, --omit-dir-times
  omit symlinks from --times
```

### 传输方式
```
-a, --archive
  等价于 -rlptgoD, recursive, copy symlink, preserve permission, modification time,
  group, owner, copy devices and specials files. 相关的选项还有numeric-ids, usermap, groupmap,
  chown等

-r, --recursive
  rsync在版本3.0.0后使用incremental scan，在完成一些目录的扫描后就开始传输。有些选项要求知道所有的文件列表，例如--delete-before,
  --delete-after,  --prune-empty-dirs, --delay-updates。
  rsync默认只处理文件，目录会被忽略。如果在命令行上指定一个目录，需要使用-d, --dirs选项或者-r选项。
  类似recursive选项，不同的是dirs没有递归效果，也就是仅传递一层目录中的文件和子目录。

-R, --relative
  将命令行上的src的路径发送给server端，作为相对路径。
  rsync -avR /foo/bar/baz.c remote:/tmp/ 将得到 remote:/tmp/foo/bar/baz.c
  rsync -avR /foo/./bar/baz.c remote:/tmp/ 将得到 remote:/tmp/bar/baz.c， 重点是使用.来限定路径的起始位置。

  --no-implied-dirs
    在使用-R的时候，源路径是path/foo/bar，path和path/foo被成为implied directory。使用这个选项，implied directory的属性不会传输。
    如果目标端有这个目录，就使用现有的目录，如果没有，就用缺省的属性创建新的目录。如果目标端的目录path或者path是符号链接，正常情况下这个
    符号链接会被删除，然后创建目录path/foo。
    如果想保持目标端的现有的符号链接目录，就可以使用no-implied-dirs选项。类似的可以使用keep-dirlinks选项。

--skip-compress=LIST
  rsync默认不会压缩某些类型的文件，因为它们的格式是已经压缩过的，再次压缩没有效果。
  7z ace avi bz2 deb gpg gz iso jpeg jpg lz lzma lzo mov mp3 mp4 ogg png rar rpm rzip tbz tgz tlz txz xz z zip

-y, --fuzzy
  这个选项挺魔法的。当接收端没有某个文件的时候，通常是文件重新传递。不过考虑如果是有个文件在接收端改名的情况，就没有必要重新传递。于是fuzzy
  算法会智能的查找是否有相同大小，修改时间，相似名字的文件，来加速文件的传输和创建。

-S, --sparse
  某些文件里面含有大量的空字符，例如虚拟机文件中的未使用空间，这种稀疏文件应该使用这个选项，否则备份文件可能比源文件更大。

-T, --temp-dir=DIR
  指定临时文件的工作目录。
```

### 处理大文件
```
--inplace
  inplace的更新方式显然很危险，不过在处理大文件的时候，或者要保持硬链接的时候，或者在一个copy-on-write的文件系统上，有用。
--append
--append-verify
  传输文件的时候，假设文件开头的部分是相同的，只有尾部的数据是新添加的。显然只针对某些数据文件。verify版本的选项会在结束后校验，如果不同，
  就使用inplace的方式重新传输。

--max-size=SIZE
```

### 备份
```
-b, --backup
  对更新的文件做备份，可以使用backup-dir选项设置备份的目录，suffix设置备份的后缀。

-u, --update
  更新模式，如果目标端的文件比源文件还要新，就不传输。

--existing, --ignore-non-existing
  更新模式，仅更新目标端存在的文件。
--ignore-existing
  不更新目标端已经存在的文件。其作用是在一次rsync传输中断，再次重传。这个是搭配link-dest这样的模式来使用的。

--compare-dest=DIR
  设置用来比较的目录树。接收端存在一个旧版本的备份，现在得到一个需要更新的文件的目录树，于是将旧版本的目录树作为比较用的目录树，rsync命令的dest
  是生成的差异文件的目录树。目标目录中如果有相同文件的话，会被删除。
--copy-dest=DIR
  类似compare-dest，不过也会拷贝没有变化的文件。实际效果和拷贝整个目录没有区别，不过在拷贝没有变化的文件是采用拷贝本地文件的方式，会比较快。
  这个选项的目的是，拷贝得到一个新的备份目录，而不干扰原来的备份目录，在完成所有文件备份后才切换备份目录。
--link-dest=DIR
  相比copy-dest，更进一步的，使用硬链接的方式来拷贝相同的文件。
```

### 符号链接
```
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
```

### 删除多余文件
```
--delete
  在接收端删除发送端没有的文件。实际删除文件前，最好用dry run先查看会删除哪些文件。
--delete-before
  在传输前删除，可以腾出接收端的磁盘空间。
--delete-during, --del
  在传输每个目录前扫描和删除。
--deleted-excluded
  和--exclude一起使用，除了删除发送端不存在的文件，也删除被列出的excluded的文件。
```

### 拷贝文件列表
```
--files-from=FILE
  在文件中指定具体的文件列表。当使用这个选项的时候，--relative和--dirs是隐含的选项，可以和-a一起使用但是不包括-r的含义，需要显式使用-r选项。

  --ignore-missing-args
    如果某个列出的文件不存在，不生成出错信息，忽略这个文件。
  --delete-missing-args
    如果某个列出的文件不存在，在接收端删除这个文件。
  -m, --prune-empty-dirs
    从文件列表中删除空目录。当空目录从文件列表中删除了，如果同时使用delete选项，这个空目录也会从接收端删除。如果不想被删除，可以使用exclude
    将文件和目录从拷贝文件的列表中过滤出去，也就不受delete的影响。

--list-only
  列出源文件。

```

### 文件过滤
过滤规则使得我们可以选择哪些文件需要传输(include)和哪些文件排除(exclude)。当拷贝文件列表创建以后，rsync针对每个文件
或目录比对过滤规则，第一个匹配的规则生效。如果第一个匹配的是exclude模板，文件被排除，如果是include模板，文件不被排除，如果没有
匹配，文件不被排除。所以过滤规则在命令上的顺序很重要。

```
-C, --cvs-exclude
  忽略各种版本管理文件和目录，备份文件。
  RCS SCCS CVS CVS.adm RCSLOG cvslog.* tags TAGS .make.state .nse_depinfo *~ #* .#* ,* _$* *$ *.old *.bak *.BAK
  *.orig *.rej .del-* *.a *.olb *.o  *.obj *.so *.exe *.Z *.elc *.ln core .svn/ .git/ .hg/ .bzr/

--exclude=PATTERN
--exclude-from=FILE
--include=PATTERN
--include-from=FILE
```

当使用--filter的时候，可以指定Filter Rules。在用户手册中， FILTER RULES小节说明了如何指定这些规则。其中的修饰符可以实现，
指定需要传输的隐藏文件，保护文件不被删除，从其他文件中获得过滤规则，等等。INCLUDE/EXCLUDE PATTERN RULES小节说明了如何书写pattern。
常用的+-两个符号，不过可以有其他修饰符，所以pattern的书写是十分复杂的。

filter, include, exclude在命令上只能使用一次，如果想指定多个规则，请使用include-from/exclude-from选项。

例子：

```
# won't work as the parent directory "some" is excluded by the '*' rule.
+ /some/path/this-file-will-not-be-found
+ /file-is-included
- *

# workaround: list the parent directory first.
+ /some/
+ /some/path/
+ /some/path/this-file-is-found
+ /file-also-included
- *
```

```
"- *.o" would exclude all names matching *.o
"- /foo" would exclude a file (or directory) named foo in the transfer-root directory
"- foo/" would exclude any directory named foo
"- /foo/*/bar" would exclude any file named bar which is at two levels below a directory named foo in the transfer-root directory
"- /foo/**/bar" would exclude any file named bar two or more levels below a directory named foo in the transfer-root directory
The combination of "+ */", "+ *.c", and "- *" would include all directories and C source files but nothing else (see also the --prune-empty-dirs option)
The combination of "+ foo/", "+ foo/bar.c", and "- *" would include only the foo directory and foo/bar.c (the foo directory must be explicitly included or it would be excluded by the "*")
```
