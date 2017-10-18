#!/bin/bash
#centos7.x中双网卡指定内外网卡设置,实现内外网多网卡共存

#内网网卡
###内网网卡配置静态IP时,不要配置默认GATEWAY
##eth0 : 172.20.0.2 GATEWAY : 172.20.0.1
##eth1 : 172.21.0.2 GATEWAY : 172.21.0.1
#外网网卡
##eth2 : 172.22.0.2 GATEWAY : 172.22.0.1

###设置默认网关为外网网卡网关,并且让这条路由位置靠最前
#route del default gw 172.22.0.1 eth2
#route add default gw 172.22.0.1 eth2

#然后单独设置内网网关
#route add -net 172.20.0.0/24 gw 172.20.0.1 eth0
#route add -net 172.21.1.0/24 gw 172.21.0.1 eth1

##将上面的命令添加到开机启动,并且设置为开机启动服务

tee /usr/local/bin/myroute.sh <<-'EOF'
#! /bin/bash
route add -net 172.20.0.0/24 gw 172.20.0.1 eth0&
route add -net 172.21.0.0/24 gw 172.21.0.1 eth1&
route del default gw 172.22.0.1 eth2&
route add default gw 172.22.0.1 eth2&
EOF

#修改权限为754
chmod 754 /usr/local/bin/myroute.sh

#新建开机启动服务

tee /usr/lib/systemd/system/myroute.service <<-'EOF'
[Unit]
Description=myroute
After=network.target

[Service]
Type=forking
ExecStart=/usr/local/bin/myroute.sh
ExecStop=/bin/kill -WINCH ${MAINPID}
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

#重启网路
echo "重启网络"
systemctl restart network
#启动服务
echo "start myroute"
systemctl daemon-reload
systemctl start myroute
#增加为开机自动启动
echo "enable myroute"
systemctl enable myroute
