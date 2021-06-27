# 手动安装（Manual installation）

1. 更新 `apt` 缓存，并安装 `pure-ftpd` 

```bash
sudo apt update && sudo apt install pure-ftpd -y
# 安装时创建了一个 systemd 的服务软连接
# Created symlink /etc/systemd/system/multi-user.target.wants/inetd.service → /lib/systemd/system/inetd.service.

# 其它依赖
# pure-ftpd/focal,now 1.0.49-4 amd64 [installed]
#   Secure and efficient FTP server

# pure-ftpd-ldap/focal 1.0.49-4 amd64
#   Secure and efficient FTP server with LDAP user authentication

# pure-ftpd-mysql/focal 1.0.49-4 amd64
#   Secure and efficient FTP server with MySQL user authentication

# pure-ftpd-postgresql/focal 1.0.49-4 amd64
#   Secure and efficient FTP server with PostgreSQL user authentication
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

5. 需要留意的参数

<details>
<summary>需要留意的参数</summary>

```
-2 cert_file[,key_file]
        When  using  TLS,  set the path to the certificate file. The certificate and its key can be be bundled into a single file, or the key can be in a distinct
        file.
-4     Listen only to IPv4 connections.

-6     Listen only to IPv6 connections.
-a gid Regular users will be chrooted to their home directories, unless they belong to the specified gid. Note that root is always trusted, and that chroot() oc‐
        curs only for anonymous ftp without this option.

-A     Chroot() everyone, but root.

-C max connection per ip
        Limit  the number of simultaneous connections coming from the same IP address. This is yet another very effective way to prevent stupid denial of services
        and bandwidth starvation by a single user.  It works only when the server is launched in standalone mode (if you use a super-server, it is supposed to  do
        that).  If  the  server is launched with -C 2 , it doesn't mean that the total number of connection is limited to 2.  But the same client, coming from the
        same machine (or at least the same IP), can't have more than two simultaneous connections. This features needs some memory to track IP addresses, but it's
        recommended to use it.

-f facility
        makes ftpd use facility for all syslog(3) messages.  facility defaults to ftp.  The facility names are normally listed in /usr/include/sys/syslog.h.  Note
        that if -f is not the first option on the command line, a couple of messages may be logged to local2 before the -f option is parsed.  Use -f none to  dis‐
        able logging.

-F fortunes file
        Display  a funny random message in the initial login banner. The random cookies are extracted from a text file, in the standard fortune format. If you in‐
        stalled the fortune package, you should have a directory (usually /usr/share/fortune ) with binary files ( xxxx.dat ) and text files (without the .dat ex‐
        tension).

-H     Don't  resolve host names ("192.0.34.166" will be logged instead of "www.example.com"). It can significantly speed up connections and reduce bandwidth us‐
        age on busy servers. Use it especially on public FTP sites.

-i     Disallow upload for anonymous users, whatever directory permissions are. This option is especially useful for virtual hosting, to avoid your users  create
        warez sites in their account.

-J ciphers
        Set the list of ciphers that will be accepted for TLS connections.

-k percentage
        Disallow upload if the partition is more than percentage full. Example: -k 95 will ensure that your disk will never get filled more than 95% by FTP users.
-l authentication:file
        Enable a new authentication method. It can be one of: -l unix For standard (/etc/passwd) authentication.  -l pam For  PAM  authentication.   -l  ldap:LDAP
        config  file  For  LDAP  directories.   -l  mysql:MySQL  config  file  For  MySQL  databases.   -l  pgsql:Postgres config file For Postgres databases.  -l
        puredb:PureDB database file For PureDB databases.  -l extauth:path to pure-authd socket For external authentication handlers.
        Different authentication methods can be mixed together. For instance  if  you  run  the  server  with  -lpuredb:/etc/pure-ftpd/pwd.pdb  -lmysql:/etc/pure-
        ftpd/my.cf  -lunix  Accounts  will  first  be authenticated from a PureDB database. If it fails, a MySQL server will be asked. If the account is still not
        found is the database, standard unix accounts will be scanned. Authentication methods are tried in the order you give the -l options, if you do  not  give
        -l, then the decision comes from configure, if PAM is built in, it is used, if not, then UNIX (/etc/passwd) is used by default.
        See the README.LDAP and README.MySQL files for info about the built-in LDAP and SQL directory support.

-m load
        Do not allow anonymous users to download files if the load is above load when the user connects. Uploads and file listings are still allowed, as are down‐
        loads by real users. The user is not told about this until he/she tries to download a file.
        
-n maxfiles:maxsize
        Enable  virtual  quotas  When virtual quotas are enabled, .ftpquota files are created, and the number of files for a user is restricted to 'maxfiles'. The
        max total size of his directory is also restricted to 'maxsize' Megabytes. Members of the trusted group aren't subject to quotas.


-N     NAT mode. Force active mode. If your FTP server is behind a NAT box that doesn't support applicative FTP proxying, or if you use port redirection  without
        a transparent FTP proxy, use this. Well... the previous sentence isn't very clear. Okay: if your network looks like this:
        FTP--NAT.gateway/router--Internet
        and  if  you want people coming from the internet to have access to your FTP server, please try without this option first. If Netscape clients can connect
        without any problem, your NAT gateway rulez. If Netscape doesn't display directory listings, your NAT gateway sucks. Use -N as a workaround.

-U umask files:umask dirs
        Change the mask for creation of new files and directories. The default are 133 (files are readable -but not writable- by other users) and 022 (same  thing
        for  directory, with the execute bit on).  If new files should only be readable by the user, use 177:077. If you want uploaded files to be executable, use
        022:022 (files will be readable by other people) or 077:077 (files will only be readable by their owner).

-V ip address
        Allow non-anonymous FTP access only on this specific local IP address. All other IP addresses are only anonymous. With that option, you  can  have  routed
        IPs  for  public  access, and a local IP (like 10.x.x.x) for administration. You can also have a routable trusted IP protected by firewall rules, and only
        that IP can be used to login as a non-anonymous user.

       -y per user max sessions:max anonymous sessions
              This switch enables per-user concurrency limits. Two values are separated by a column. The first one is the max number of concurrent sessions for a single
              login. The second one is the maximum number of anonoymous sessions.

-Y tls behavior
        -Y 0 (default) disables TLS security mechanisms.
        -Y 1 Accept both normal sessions and TLS ones.
        -Y 2 refuses connections that aren't using TLS security mechanisms, including anonymous ones.
        -Y 3 refuses connections that aren't using TLS security mechanisms, and refuse cleartext data channels as well.
        The server must have been compiled with TLS support and a valid certificate must be in place to accept encrypted sessions.

-Z     Add safe guards against common customer mistakes (like chmod 0 on their own files) .

```

</details>