---
layout: post
title: "How to uninstall mysql on MacOSX"
date: 2014-03-26 12:44
comments: true
categories: [MySQL, MacOSX]
published: true
---

在MySQL的官方网站上提供了MacOSX平台的安装Image，里面包含MySQL的主安装包，StartupIteam和PreferencePane的安装文件。StartupItem和PreferencePane包给我们控制MySQL的启停带来很大的便利。

不过官方没有Uninstall的教程，MacOSX系统布局很多人也不明白。实际上，在MacOSX中是以直接删除目录的方式删除软件的。

 1. 备份数据库中的数据
 2. 停止MySQL的运行
 3. sudo rm /usr/local/mysql
 4. sudo rm -rf /usr/local/mysql*
 5. sudo rm -rf /Library/StartupItems/MySQLCOM
 6. sudo rm -rf /Library/PreferencePanes/My*
 7. 在/etc/hostconfig中移除这行 MYSQLCOM=-YES-
 8. rm -rf ~/Library/PreferencePanes/My*
 9. sudo rm -rf /Library/Receipts/mysql*
 10. sudo rm -rf /Library/Receipts/MySQL*
 11. sudo rm -rf /private/var/db/receipts/*mysql*
 12. sudo rm -rf /etc/my.cnf
 13. 在/Library/Receipts/InstallHistory.plist中查找MySQL的相关项目删除之，正常的话应该已经没有了

第八步，可以通过在System Preferences Pane中右键移除MySQL Preference Pane达到相同的效果。
