#!/bin/bash
echo "Enter VPN server address(ex:52.522.522.522): "
read VPN_SERVER_IP

echo '\n'
echo 'Executing: `ip route`'
ip route
echo '\n'
echo 'Find this line in the output: default via X.X.X.X .... Write down this gateway IP'
read GATEWAY_IP
echo '\n'

echo 'If your VPN client is a remote server, you must also exclude your local machine public IP from the new default route, to prevent your SSH session from being disconnected'
echo "Enter your local machine's public ip: "
read LOCAL_PUBLIC_IP

mkdir -p /var/run/xl2tpd
touch /var/run/xl2tpd/l2tp-control

service strongswan restart
service xl2tpd restart

#sleep added to remove inconsistency
sleep 4s

#start the service
ipsec up myvpn

#sleep added to remove inconsistency
sleep 4s
echo "c myvpn" > /var/run/xl2tpd/l2tp-control

#sleep added to remove inconsistency
sleep 4s

route add $VPN_SERVER_IP gw $GATEWAY_IP

route add $LOCAL_PUBLIC_IP gw $GATEWAY_IP

route add default dev ppp0

echo 'Verify that your traffic is being routed properly. The below ip should be your VPN server IP.'
wget -qO- http://ipv4.icanhazip.com; echo

exit 0

