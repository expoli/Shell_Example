# DHCP 安装 shell 脚本

## 1. 环境准备

### 新建两台虚拟机

- dhcp-server
    - 192.168.231.10
- dhcp-client
    - 192.168.231.11

### 网卡配置

- server
1. 内部网络
2. NAT 网络
3. 仅主机

- client
1. 内部网络
2. NAT 网络
3. 仅主机

使用内部网络作为实验网络

## 2. 开始配置

### 1. 安装 `isc-dhcp-serve`

```bash
sudo apt update && sudo apt install isc-dhcp-server

# 安装日志输出，生成了默认配置文件，和systemd相关服务配置文件

# Generating /etc/default/isc-dhcp-server...
# Created symlink /etc/systemd/system/multi-user.target.wants/isc-dhcp-server.service → /lib/systemd/system/isc-dhcp-server.service.
# Created symlink /etc/systemd/system/multi-user.target.wants/isc-dhcp-server6.service → /lib/systemd/system/isc-dhcp-server6.service.
```

### 2. 查看默认配置文件

1. [/etc/default/isc-dhcp-server](./conf/isc-dhcp-server)
2. [/etc/dhcp/dhcpd.conf](./conf/dhcpd.conf)
3. [/etc/dhcp/dhcpd6.conf](./conf/dhcpd6.conf)

### 3. 查看软件包安装文件

<details>

```log
tcy@dhcp-server:~/Shell_Example$ sudo dpkg -L isc-dhcp-server
[sudo] password for tcy: 
/.
/etc
/etc/apparmor.d
/etc/apparmor.d/dhcpd.d
/etc/apparmor.d/usr.sbin.dhcpd
/etc/dhcp
/etc/dhcp/dhcpd.conf
/etc/dhcp/dhcpd6.conf
/etc/init.d
/etc/init.d/isc-dhcp-server
/etc/logcheck
/etc/logcheck/ignore.d.server
/etc/logcheck/ignore.d.server/isc-dhcp-server
/lib
/lib/systemd
/lib/systemd/system
/lib/systemd/system/isc-dhcp-server.service
/lib/systemd/system/isc-dhcp-server6.service
/usr
/usr/bin
/usr/bin/omshell
/usr/sbin
/usr/sbin/dhcp-lease-list
/usr/sbin/dhcpd
/usr/share
/usr/share/apport
/usr/share/apport/package-hooks
/usr/share/apport/package-hooks/isc-dhcp-server.py
/usr/share/doc
/usr/share/doc/isc-dhcp-server
/usr/share/doc/isc-dhcp-server/NEWS.Debian.gz
/usr/share/doc/isc-dhcp-server/README.Debian
/usr/share/doc/isc-dhcp-server/README.gz
/usr/share/doc/isc-dhcp-server/TODO.Debian
/usr/share/doc/isc-dhcp-server/changelog.Debian.gz
/usr/share/doc/isc-dhcp-server/copyright
/usr/share/doc/isc-dhcp-server/examples
/usr/share/doc/isc-dhcp-server/examples/dhcpd.conf.example
/usr/share/man
/usr/share/man/man1
/usr/share/man/man1/omshell.1.gz
/usr/share/man/man5
/usr/share/man/man5/dhcpd.conf.5.gz
/usr/share/man/man5/dhcpd.leases.5.gz
/usr/share/man/man8
/usr/share/man/man8/dhcp-lease-list.8.gz
/usr/share/man/man8/dhcpd.8.gz
/var
/var/lib
/var/lib/dhcp
```

</details>

### 4. man 手册

1. 一种示例文件

```conf
subnet 10.0.0.0 netmask 255.255.255.0 {
  option routers 10.0.0.254;

  # Unknown clients get this pool.
  pool {
    option domain-name-servers bogus.example.com;
    max-lease-time 300;
    range 10.0.0.200 10.0.0.253;
    allow unknown-clients;
  }

  # Known clients get this pool.
  pool {
    option domain-name-servers ns1.example.com, ns2.example.com;
    max-lease-time 28800;
    range 10.0.0.5 10.0.0.199;
    deny unknown-clients;
  }
}
```

2. 最简配置文件

### 5. 修改配置文件

1. 查看网卡名称

```bsh
# 查看所有网卡名称
ip a | grep -e ^[0-9]: | awk -F : '{printf $2}'
# 查看相应的 ip 地址
ip a show <<< $(ip a | grep -e ^[0-9]: | awk -F : '{printf $2}')
```

2. 修改 `/etc/default/isc-dhcp-server`

```diff
tcy@dhcp-server:~/Shell_Example$ sudo cp  /etc/default/isc-dhcp-server /etc/default/isc-dhcp-server.example
tcy@dhcp-server:~/Shell_Example$ sudo vim /etc/default/isc-dhcp-server
tcy@dhcp-server:~/Shell_Example$ diff /etc/default/isc-dhcp-server /etc/default/isc-dhcp-server.example 
17c17
< INTERFACESv4="enp0s9"
---
> INTERFACESv4=""
tcy@dhcp-server:~/Shell_Example$ 
```

3. 修改 `/etc/dhcp/dhcpd.conf`
- 修改网卡配置，设置静态IP
```diff
tcy@dhcp-server:~/Shell_Example$ sudo cp /etc/netplan/00-installer-config.yaml  /etc/netplan/00-installer-config.yaml.example
tcy@dhcp-server:~/Shell_Example$ sudo vim /etc/netplan/00-installer-config.yaml 
tcy@dhcp-server:~/Shell_Example$ diff /etc/netplan/00-installer-config.yaml /etc/netplan/00-installer-config.yaml.example 
10,17d9
<   ethernets:
<     enp0s9:
<       dhcp4: no
<       addresses:
<         - 192.168.233.1/24
< #      gateway4: 192.168.233.1
<       nameservers:
<           addresses: [8.8.8.8, 1.1.1.1]
tcy@dhcp-server:~/Shell_Example$ 
```
- 修改dhcp-server配置
```diff
tcy@dhcp-server:~/Shell_Example$ diff /etc/dhcp/dhcpd.conf.example /etc/dhcp/dhcpd.conf
10,11c10,11
< option domain-name "example.org";
< option domain-name-servers ns1.example.org, ns2.example.org;
---
> #option domain-name "example.org";
> option domain-name-servers 8.8.8.8, 1.0.0.1;
15a16,19
> subnet 192.168.233.0 netmask 255.255.255.0 {
>     range 192.168.233.20 192.168.233.200;
> }
> 
20c24
< ddns-update-style none;
---
> #ddns-update-style none;
111a116,117
> #
> 
```

4. 查看并配置网卡
- 查看网卡状态
```log
tcy@dhcp-server:~/Shell_Example$ sudo networkctl 
IDX LINK   TYPE     OPERATIONAL SETUP     
  1 lo     loopback carrier     unmanaged 
  2 enp0s3 ether    routable    configured
  3 enp0s8 ether    routable    configured
  4 enp0s9 ether    off         unmanaged 

4 links listed.
```
- 生效配置
```log
tcy@dhcp-server:~/Shell_Example$ sudo netplan apply 
tcy@dhcp-server:~/Shell_Example$ sudo networkctl 
IDX LINK   TYPE     OPERATIONAL SETUP     
  1 lo     loopback carrier     unmanaged 
  2 enp0s3 ether    routable    configured
  3 enp0s8 ether    routable    configured
  4 enp0s9 ether    routable    configured

4 links listed.
```

5. 启动 dhcp 服务器

```log
tcy@dhcp-server:~/Shell_Example$ sudo systemctl restart isc-dhcp-server
tcy@dhcp-server:~/Shell_Example$ sudo systemctl status isc-dhcp-server
● isc-dhcp-server.service - ISC DHCP IPv4 server
     Loaded: loaded (/lib/systemd/system/isc-dhcp-server.service; enabled; vendor preset: enabled)
     Active: active (running) since Mon 2021-06-28 06:28:51 UTC; 2s ago
       Docs: man:dhcpd(8)
   Main PID: 7988 (dhcpd)
      Tasks: 4 (limit: 1071)
     Memory: 5.0M
     CGroup: /system.slice/isc-dhcp-server.service
             └─7988 dhcpd -user dhcpd -group dhcpd -f -4 -pf /run/dhcp-server/dhcpd.pid -cf /etc/dhcp/dhcpd.conf enp0s9

Jun 28 06:28:51 dhcp-server sh[7988]: PID file: /run/dhcp-server/dhcpd.pid
Jun 28 06:28:51 dhcp-server dhcpd[7988]: Wrote 0 leases to leases file.
Jun 28 06:28:51 dhcp-server sh[7988]: Wrote 0 leases to leases file.
Jun 28 06:28:51 dhcp-server dhcpd[7988]: Listening on LPF/enp0s9/08:00:27:43:bd:d7/192.168.233.0/24
Jun 28 06:28:51 dhcp-server sh[7988]: Listening on LPF/enp0s9/08:00:27:43:bd:d7/192.168.233.0/24
Jun 28 06:28:51 dhcp-server sh[7988]: Sending on   LPF/enp0s9/08:00:27:43:bd:d7/192.168.233.0/24
Jun 28 06:28:51 dhcp-server sh[7988]: Sending on   Socket/fallback/fallback-net
Jun 28 06:28:51 dhcp-server dhcpd[7988]: Sending on   LPF/enp0s9/08:00:27:43:bd:d7/192.168.233.0/24
Jun 28 06:28:51 dhcp-server dhcpd[7988]: Sending on   Socket/fallback/fallback-net
Jun 28 06:28:51 dhcp-server dhcpd[7988]: Server starting service.
```

6. 配置客户端

- 配置客户端网卡为 DHCP 

```diff
tcy@dhcp-client:~$ diff /etc/netplan/00-installer-config.yaml.example  /etc/netplan/00-installer-config.yaml
8a9,11
>   ethernets:
>     enp0s9:
>       dhcp4: true
```

- 生效配置

```log
tcy@dhcp-client:~$ sudo netplan apply 
tcy@dhcp-client:~$ sudo networkctl
IDX LINK   TYPE     OPERATIONAL SETUP     
  1 lo     loopback carrier     unmanaged 
  2 enp0s3 ether    routable    configured
  3 enp0s8 ether    routable    configured
  4 enp0s9 ether    routable    configured

4 links listed.
tcy@dhcp-client:~$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:a9:12:3a brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic enp0s3
       valid_lft 86391sec preferred_lft 86391sec
    inet6 fe80::a00:27ff:fea9:123a/64 scope link 
       valid_lft forever preferred_lft forever
3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:ac:74:0d brd ff:ff:ff:ff:ff:ff
    inet 192.168.231.10/24 brd 192.168.231.255 scope global dynamic enp0s8
       valid_lft 591sec preferred_lft 591sec
    inet6 fe80::a00:27ff:feac:740d/64 scope link 
       valid_lft forever preferred_lft forever
4: enp0s9: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:ce:9c:46 brd ff:ff:ff:ff:ff:ff
    inet 192.168.233.20/24 brd 192.168.233.255 scope global dynamic enp0s9
       valid_lft 592sec preferred_lft 592sec
    inet6 fe80::a00:27ff:fece:9c46/64 scope link 
       valid_lft forever preferred_lft forever
```

- 检测成果

```log
tcy@dhcp-client:~$ ping 192.168.233.1
PING 192.168.233.1 (192.168.233.1) 56(84) bytes of data.
64 bytes from 192.168.233.1: icmp_seq=1 ttl=64 time=0.288 ms
64 bytes from 192.168.233.1: icmp_seq=2 ttl=64 time=0.315 ms
^C
--- 192.168.233.1 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1002ms
rtt min/avg/max/mdev = 0.288/0.301/0.315/0.013 ms
```
