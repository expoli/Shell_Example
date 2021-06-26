# 实验目的

使用 `cloud-init` 方案，通过对安装方式的自定义，实现系统的无人值守安装。

## 1. 环境配置

### 1.1 镜像构建机

1. 安装依赖工具包

```bash
sudo apt update && sudo apt install cloud-init genisoimage -y
```

2. 将你修改后的 `meta-data` 与 `user-data` 放置到相应的文件夹

```bash
scp meta-data user-data username@192.168.231.8:/file/path
```

3. 创建无人值守安装镜像

```bash
genisoimage -input-charset utf-8 -output init-auto.iso -volid cidata -joliet -rock user-data meta-data
```

4. 新建虚拟机挂载镜像

![](img/virtual-box-hard-driver.png)


## 2. 注意

1. 因 `user-data` 已经定义了用户与主机名，所以 `meta-data` 中的配置被忽略
2. 可通过 `apt` 的 `uri` 配置、直接进行镜像源修改
3. `authorized-keys` 部分不需要添加引号
4. 密码为 cuc
