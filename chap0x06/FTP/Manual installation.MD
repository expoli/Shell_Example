# 手动安装（Manual installation）

1. 更新 `apt` 缓存，并安装 `pure-ftpd` 

```bash
sudo apt update && sudo apt install pure-ftpd -y
# 安装时创建了一个 systemd 的服务软连接
# Created symlink /etc/systemd/system/multi-user.target.wants/inetd.service → /lib/systemd/system/inetd.service.
```

2. 查看软件都安装了哪些文件

```bash
tcy@ubuntu-base:~$ sudo dpkg -L pure-ftpd
/.
/etc
/etc/ftpusers
/etc/init.d
/etc/init.d/pure-ftpd
/usr
/usr/bin
/usr/bin/pure-pw
/usr/bin/pure-pwconvert
/usr/bin/pure-statsdecode
/usr/sbin
/usr/sbin/pure-authd
/usr/sbin/pure-ftpd
/usr/sbin/pure-ftpd-virtualchroot
/usr/sbin/pure-ftpwho
/usr/sbin/pure-mrtginfo
/usr/sbin/pure-quotacheck
/usr/sbin/pure-uploadscript
/usr/share
/usr/share/doc
/usr/share/lintian
/usr/share/lintian/overrides
/usr/share/lintian/overrides/pure-ftpd
/usr/share/man
/usr/share/man/man8
/usr/share/doc/pure-ftpd
/usr/share/man/man8/pure-ftpd-virtualchroot.8.gz
```

3. 一些文件的内容

- /etc/ftpusers 

```bash
tcy@ubuntu-base:~$ cat /etc/ftpusers 
# /etc/ftpusers: list of users disallowed FTP access.
root
daemon
bin
sys
sync
games
man
lp
mail
news
uucp
proxy
majordom
postgres
www-data
backup
msql
operator
list
irc
nobody
```
4. 查看 man 手册

[man手册](pure-ftpd-man.md)

