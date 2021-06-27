# 常见FTP服务器软件

- ftpd
- vsftpd
- proftpd
- pure-ftpd

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

## 软件选型

- 需求
  - 有加密措施
  - 配置简单
  - 有状态报告

- 选型结果
  - pure-ftpd
