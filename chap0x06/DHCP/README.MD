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

1. 安装 `isc-dhcp-serve`

```bash
sudo apt update && sudo apt install isc-dhcp-server

# 安装日志输出，生成了默认配置文件，和systemd相关服务配置文件

# Generating /etc/default/isc-dhcp-server...
# Created symlink /etc/systemd/system/multi-user.target.wants/isc-dhcp-server.service → /lib/systemd/system/isc-dhcp-server.service.
# Created symlink /etc/systemd/system/multi-user.target.wants/isc-dhcp-server6.service → /lib/systemd/system/isc-dhcp-server6.service.
```

2. 查看默认配置文件

1. [/etc/default/isc-dhcp-server](./conf/isc-dhcp-server)
2. [/etc/dhcp/dhcpd.conf](./conf/dhcpd.conf)
3. [/etc/dhcp/dhcpd6.conf](./conf/dhcpd6.conf)