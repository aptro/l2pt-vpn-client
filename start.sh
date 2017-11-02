#!/bin/bash
echo "Enter VPN server address(ex:52.522.522.522): "
read VPN_SERVER_IP


echo 'Executing: `ip route`'
ip route

echo 'Enter value of X.X.X.X, from previous command.\n default via X.X.X.X ...'
read GATEWAY_IP

echo 'If your VPN client is a remote server, you must also exclude your local machine public IP from the new default route, to prevent your SSH session from being disconnected'

echo 'Enter your local machine public ip: '
read LOCAL_PUBLIC_IP

#start the service
ipsec up myvpn

echo "c myvpn" > /var/run/xl2tpd/l2tp-control

route add $VPN_SERVER_IP gw $GATEWAY_IP

if [ -z "${LOCAL_PUBLIC_IP}" ]; then
    route add LOCAL_PUBLIC_IP gw $GATEWAY_IP
fi

route add default dev ppp0

echo 'Verify that your traffic is being routed properly.\nwget -qO- http://ipv4.icanhazip.com; echo
\nThe bellow ip should be your VPN server IP.'
wget -qO- http://ipv4.icanhazip.com; echo

exit 0

