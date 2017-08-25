#!/bin/bash


#配置hosts文件
tee /etc/hosts <<-"EOF"
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

#manaement network
172.16.0.2 deploy_host
172.16.0.3 controller
172.16.0.4 compute
172.16.0.5 ceph1
172.16.0.6 ceph2
172.16.0.7 ceph3
EOF
##添加yum源
tee /etc/yum.repos.d/CentOS-Base.repo <<-"EOF"
# CentOS-Base.repo
#
# The mirror system uses the connecting IP address of the client and the
# update status of each mirror to pick mirrors that are updated to and
# geographically close to the client.  You should use this for CentOS updates
# unless you are manually picking other mirrors.
#
# If the mirrorlist= does not work for you, as a fall back you can try the
# remarked out baseurl= line instead.
#
#

[base]
name=CentOS-$releasever - Base
baseurl=https://mirrors.njupt.edu.cn/centos/$releasever/os/$basearch/
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=os
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

#released updates
[updates]
name=CentOS-$releasever - Updates
baseurl=https://mirrors.njupt.edu.cn/centos/$releasever/updates/$basearch/
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=updates
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

#additional packages that may be useful
[extras]
name=CentOS-$releasever - Extras
baseurl=https://mirrors.njupt.edu.cn/centos/$releasever/extras/$basearch/
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=extras
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

#additional packages that extend functionality of existing packages
[centosplus]
name=CentOS-$releasever - Plus
baseurl=https://mirrors.njupt.edu.cn/centos/$releasever/centosplus/$basearch/
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=centosplus
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
EOF

yum install -y wget
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
#更新yum源
yum clean all
yum makecache
yum update -y
yum -y install  python-pip    \
                python-devel  \
                libffi-devel  \
                gcc           \
                openssl-devel \
                git           /

#下载最新版docker
curl -sSL https://get.docker.io | bash

#配置文件
mkdir -p /etc/systemd/system/docker.service.d
tee /etc/systemd/system/docker.service.d/kolla.conf <<-'EOF'
[Service]
MountFlags=shared
EOF

#restart docker
systemctl daemon-reload
systemctl restart docker

#添加豆瓣pip源
mkdir /root/.pip
tee /root/.pip/pip.conf <<-"EOF"
[global]
index-url =  https://pypi.doubanio.com/simple/
EOF
#更新pip
pip install -U pip
#跟新docker python库
pip install -U docker-py 

#设置docker开机自启动
systemctl enable docker 
#添加doker私有仓库地址
#使用^XXX$匹配一整行内容,防止多次运行脚本导致重复添加私有仓库地址
sed -i "s;^ExecStart=/usr/bin/dockerd$;dockerd --insecure-registry 172.16.0.2:4000;" /usr/lib/systemd/system/docker.service

##安装ntp服务
bash ntp_config.sh 
