# 常见FTP服务器软件

- ftpd
- vsftpd
- proftpd
- pure-ftpd

<details>

```bash
tcy@ubuntu-base:~$ apt-cache show ftpd vsftpd proftpd-basic pure-ftpd | grep -A 7 Description-en
Description-en: File Transfer Protocol (FTP) server
 This is the netkit ftp server. You are recommended to use one of its
 alternatives, such as vsftpd, proftpd, or pure-ftpd.
 .
 This server supports IPv6, and can be used in standalone mode as well
 as in inetd-slave mode, but other servers have better long-term
 security screening.
 .
--
Description-en: lightweight, efficient FTP server written for security
 This package provides the "Very Secure FTP Daemon", written from
 the ground up with security in mind.
 .
 It supports both anonymous and non-anonymous FTP access, PAM authentication,
 bandwidth limiting, and the Linux sendfile() facility.
Description-md5: 81386f72ac91a5ea48f8db0b023f3f9b

--
Description-en: Versatile, virtual-hosting FTP daemon - binaries
 ProFTPD is a powerful modular FTP/SFTP/FTPS server. This File Transfer
 Protocol daemon supports also hidden directories, virtual hosts, and
 per-directory ".ftpaccess" files. It uses a single main configuration
 file, with a syntax similar to Apache.
 .
 Because of the advanced design, anonymous-FTP directories can have
 an arbitrary internal structure (bin, lib, etc, and special files are
--
Description-en: Secure and efficient FTP server
 Free, secure, production-quality and standard-conformant FTP server.
 Features include chrooted home directories,
 virtual domains, built-in 'ls', anti-warez system, configurable ports for
 passive downloads, FXP protocol, bandwidth throttling, ratios,
 fortune files, Apache-like log files, fast standalone mode, atomic uploads,
 text / HTML / XML real-time status report, virtual users, virtual quotas,
 privilege separation, SSL/TLS and more.
```

</details>

## 软件选型

- 需求
  - 有加密措施
  - 配置简单
  - 有状态报告

- 选型结果
  - pure-ftpd

## 手动安装记录

[Manual_installation.MD](Manual%20installation.MD)

## 完成脚本

[install-pure-ftp.sh](install-pure-ftp.sh)

### 脚本执行结果

<details>

```
tcy@ubuntu-base:~/workdir$ sudo bash ./install-pure-ftp.sh 
chinking os ...

You has been run this script already, do you want to run it anyway ?y
Hit:1 http://mirrors4.tuna.tsinghua.edu.cn/ubuntu focal InRelease
Hit:2 http://mirrors4.tuna.tsinghua.edu.cn/ubuntu focal-updates InRelease
Hit:3 http://mirrors4.tuna.tsinghua.edu.cn/ubuntu focal-backports InRelease
Hit:4 http://mirrors4.tuna.tsinghua.edu.cn/ubuntu focal-security InRelease
Hit:5 http://ppa.launchpad.net/jonathonf/vim/ubuntu focal InRelease
Reading package lists... Done
Building dependency tree       
Reading state information... Done
All packages are up to date.
Reading package lists... Done
Building dependency tree       
Reading state information... Done
pure-ftpd is already the newest version (1.0.49-4).
The following packages were automatically installed and are no longer required:
  fortunes-min librecode0
Use 'sudo apt autoremove' to remove them.
0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
Backup /etc/pure-ftpd/pure-ftpd.conf to /etc/pure-ftpd/pure-ftpd.conf.example_2021-06-27-08-05-07
Backup /etc/pure-ftpd/pureftpd-dir-aliases to /etc/pure-ftpd/pureftpd-dir-aliases.example_2021-06-27-08-05-07
Backup /etc/pure-ftpd/conf to /etc/pure-ftpd/conf.example_2021-06-27-08-05-07
Do you want to config pure-ftp by yourself? (y/n)n
configing LDAPConfigFile, and the value is /etc/pureftpd-ldap.conf
configing PGSQLConfigFile, and the value is /etc/pureftpd-pgsql.conf
configing PureDB, and the value is /etc/pureftpd.pdb
configing MySQLConfigFile, and the value is /etc/pureftpd-mysql.conf
configing VerboseLog, and the value is no
configing PAMAuthentication, and the value is yes
configing AltLog, and the value is clf:/var/log/pureftpd.log
configing AnonymousCantUpload, and the value is yes
configing LimitRecursion, and the value is 2000 8
configing MaxDiskUsage, and the value is 95
configing DontResolve, and the value is yes
configing CustomerProof, and the value is yes
configing AnonymousBandwidth, and the value is 1024
configing DisplayDotFiles, and the value is no
pure-ftpd.service is not a native service, redirecting to systemd-sysv-install.
Executing: /lib/systemd/systemd-sysv-install enable pure-ftpd
● pure-ftpd.service
     Loaded: loaded (/etc/init.d/pure-ftpd; generated)
     Active: active (running) since Sun 2021-06-27 08:05:25 UTC; 15ms ago
       Docs: man:systemd-sysv-generator(8)
    Process: 107382 ExecStart=/etc/init.d/pure-ftpd start (code=exited, status=0/SUCCESS)
      Tasks: 1 (limit: 1071)
     Memory: 1.1M
     CGroup: /system.slice/pure-ftpd.service
             └─107402 /usr/sbin/pure-ftpd -l pam -H -Z -k 95 -i -O clf:/var/log/pureftpd.log -L 2000:8 -t 1024 -B -g /var/run/pure-ftpd/pure-ftpd.pid

Jun 27 08:05:24 ubuntu-base systemd[1]: pure-ftpd.service: Succeeded.
Jun 27 08:05:24 ubuntu-base systemd[1]: Stopped pure-ftpd.service.
Jun 27 08:05:24 ubuntu-base systemd[1]: Starting pure-ftpd.service...
Jun 27 08:05:25 ubuntu-base pure-ftpd[107382]: Starting ftp server:
Jun 27 08:05:25 ubuntu-base pure-ftpd[107391]: Running: /usr/sbin/pure-ftpd -l pam -H -Z -k 95 -i -O clf:/var/log/pureftpd.log -L 2000:8 -t 1024 -B
Jun 27 08:05:25 ubuntu-base systemd[1]: Started pure-ftpd.service.
Congratulations config done!
```

</details>

## 实现功能

- [x] 检查操作系统兼容性
- [x] 检测运行用户
- [x] 更新并安装需要依赖
- [x] 备份原始配置文件
- [x] 检测脚本是否时第一次执行，避免覆盖默认文件
- [x] 支持自动化部署（使用脚本调优后的参数，不支持SSL）
- [x] 默认采用 PAM 认证、具有密码认证功能
- [x] 支持交互式高级自主配置、给出详细参数介绍（支持SSL配置、限额配置、分量率配置等等。。。）