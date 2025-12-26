# chroot-container
用于制作轻量化容器

## 特点
1. 内置busybox
2. 内置wolfsshd提供简易sshd服务
3. 内置个人编写的se-boot提供初始化
4. 提供进入容器，退出容器，停止容器功能
5. 理论上适配各类发行版镜像与自编译嵌入式Linux环境
6. 支持运行于Android Chroot环境

## 运行
1. 直接在release页面下载已制作好的根文件系统压缩包，通过`tar -xf xxxxx`进行解压

2. 执行`./init.sh &`，初始化容器
3. 执行`./entrypoint.sh`，进入容器
4. 若需退出容器，执行 `exit`
5. 若需停止容器运行，执行`./container-exit.sh`

## 异常
若执行`./init.sh`时产生异常，或者意外退出，请在该文件路径下执行
```
umount ./proc
umount ./sys
umount ./tmp
umount ./dev/pts
umount ./dev
```

## 容器参数

- /etc/chroot-init/_environment.sh

用于配置`./entrypoint.sh`进入容器后的环境变量

- /etc/chroot-init/_config.sh
`./init.sh`容器配置

| 参数                    | 作用                                                                                                                                                                        |
| ----------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| HOST_NAME               | 初始化时将写入/etc/hostname, 用于配置主机名                                                                                                                                 |
| DNS                     | 初始化时将写入/etc/resolv.conf, 用于配置DNS, 若为空，则会复制宿主机的/etc/resolv.conf文件到容器中去，此时若宿主机不存在/etc/resolv.conf文件，则设置为'nameserver 223.5.5.5' |
| UNSHARE_NAMESPACES      | 在初始化途中会调用 unshare --fork $UNSHARE_NAMESPACES xxxxx来创建容器，该参数用于配置unshare                                                                                |
| NSENTER_NAMESPACES      | 进入容器时会调用nsenter $NSENTER_NAMESPACES xxxxx ,该参数用于配置nsenter                                                                                                    |
| PID_FILE                | 初始化后会将容器的宿主端pid号写入该路径                                                                                                                                     |
| CONTAINER_STOP_PID_FILE | 初始化后会将容器会fork个子进程监听容器停止信号，并将该进程的宿主端pid号写入该路径                                                                                           |
| USE_SUDO                | 在宿主环境下执行命令前是否添加sudo                                                                                                                                          |

## 已知BUG
在WSL执行`./entrypoint.sh`进入容器后执行`./container-exit.sh`停止容器会导致终端输出异常，此时只能敲`reset`命令重置终端

## 开发 (以ubuntu-22.04.1-amd64为例)

### 开发条件
确保宿主机编译用C库与目标容器匹配, ubuntu-22.04.1容器为glibc-2.35(通过ldd --version查看，若不是，则更换其他相匹配的根文件系统，或是采用交叉编译，亦或是在进入相匹配的容器环境下编译)

### 初始化环境

```
git clone https://github.com/hvhghv/chroot-container.git
git clone https://github.com/hvhghv/se-boot.git
git clone https://github.com/wolfSSL/wolfssh.git
git clone https://github.com/wolfSSL/wolfssl.git
git clone https://github.com/mirror/busybox.git -b 1_36_1
```

### 下载ubuntu base根文件系统

```
mkdir ubuntu-base
cd ubuntu-base
wget https://mirrors.aliyun.com/ubuntu-cdimage/ubuntu-base/releases/22.04.1/release/ubuntu-base-22.04.1-base-amd64.tar.gz
tar -xf ubuntu-base-22.04.1-base-amd64.tar.gz
rm ubuntu-base-22.04.1-base-amd64.tar.gz
```

### 编译busybox
```
cp chroot-container/ext/busybox/.config busybox
cd busybox
make -j12
```

### 编译wolfsshd
```
cd wolfssl
./autogen.sh
./configure --enable-ssh
make -j12
make install

cd ../wolfssh
./autogen.sh
./configure --enable-sshd --enable-sftp --enable-fwd --enable-certs
make -j12
```

### 编译se-boot
```
cd se-boot
./configure
make -j12
```

### 复制所需文件到根文件系统
```
cp busybox/busybox ubuntu-base/bin
cp wolfssh/apps/.libs/wolfsshd ubuntu-base/bin
cp se-boot/build/se-boot ubuntu-base/bin

cp wolfssl/src/.libs/libwolfssl.so.44.0.1 ubuntu-base/lib/libwolfssl.so.44
cp wolfssh/src/.libs/libwolfssh.so.18.0.0 ubuntu-base/lib/libwolfssh.so.18

cp -r chroot-container/src/* ubuntu-base
cp -r chroot-container/target/ubuntu/* ubuntu-base
cp -r chroot-container/ext/LinuxMirrors/* ubuntu-base
cp -r chroot-container/ext/wolfsshd/* ubuntu-base

mkdir ubuntu-base/etc/se_boot
cp chroot-container/ext/se-boot/etc/se_boot/02_01_wolfsshd.sh ubuntu-base/etc/se_boot
```
### 设置文件权限
```
chmod 755 ubuntu-base/bin/busybox
chmod 755 ubuntu-base/bin/wolfsshd
chmod 755 ubuntu-base/bin/se-boot
chmod 755 ubuntu-base/script/change_source.sh
chmod 755 ubuntu-base/init.sh
chmod 755 ubuntu-base/entrypoint.sh
chmod 755 ubuntu-base/container-exit.sh
chmod 755 ubuntu-base/etc/se_boot/*
chmod 755 ubuntu-base/etc/chroot-init/*
chmod 644 ubuntu-base/etc/passwd
chmod 640 ubuntu-base/etc/shadow
```

### 打包
```
cd ubuntu-base
tar -czf ../ubuntu-base-amd64.tar.gz *
```


## 引用
- [LinuxMirrors](https://github.com/SuperManito/LinuxMirrors) 
- [busybox](https://github.com/mirror/busybox)
- [wolfssh](https://github.com/wolfSSL/wolfssh)
- [wolfssl](https://github.com/wolfSSL/wolfssl)