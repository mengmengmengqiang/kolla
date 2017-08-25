#!/bin/bash
#下载软件包
yum -y install ntp net-tools

#设置开机启动
systemctl enable ntpd

#启动服务
systemctl start ntpd.service

#查看端口
netstat -an | grep 123

#查看进程启动状态
ps -ef | grep ntpd

#####根据主机名来选择安装时间服务器模式还是客户端模式
if [ $HOSTNAME = "controller" ];then
    echo "安装时间同步服务器"
    #注释默认的时间服务器
    sed -i 's;server 0.centos.pool.ntp.org iburst;#server 0.centos.pool.ntp.org iburst;g' /etc/ntp.conf   
    sed -i 's;server 1.centos.pool.ntp.org iburst;#server 1.centos.pool.ntp.org iburst;g' /etc/ntp.conf
    sed -i 's;server 2.centos.pool.ntp.org iburst;#server 2.centos.pool.ntp.org iburst;g' /etc/ntp.conf
    #添加中国时间同步服务器
    sed -i 's;server 3.centos.pool.ntp.org iburst;server cn.pool.ntp.org iburst;g' /etc/ntp.conf
    #设置服务器访问权限
    sed -i 's;restrict default nomodify notrap nopeer noquery;restrict 192.168.100.0 mask 255.255.255.0 nomodify notrap;g' /etc/ntp.conf 
else
    echo "安装时间同步服务客户端"
    #注释默认的时间服务器
    sed -i 's;server 0.centos.pool.ntp.org iburst;#server 0.centos.pool.ntp.org iburst;g' /etc/ntp.conf
    sed -i 's;server 1.centos.pool.ntp.org iburst;#server 1.centos.pool.ntp.org iburst;g' /etc/ntp.conf
    sed -i 's;server 2.centos.pool.ntp.org iburst;#server 2.centos.pool.ntp.org iburst;g' /etc/ntp.conf

    #添加自建的时间服务器IP
    sed -i 's;server 3.centos.pool.ntp.org iburst;server controller iburst;g' /etc/ntp.conf
fi
#重启服务器
systemctl restart ntpd.service
echo "successfully!"

