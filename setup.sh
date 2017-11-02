#!/bin/bash
echo -e "server address(ex:52.522.522.522): "
read VPN_SERVER_IP

echo -e "preshared key: "
read VPN_IPSEC_PSK

echo -e "username: "
read VPN_USER

echo -e "LDAP username: "
read VPN_PASSWORD

apt-get update
apt-get -y install strongswan xl2tpd


cat > /etc/ipsec.conf <<EOF
# ipsec.conf - strongSwan IPsec configuration file

# basic configuration

config setup
  # strictcrlpolicy=yes
  # uniqueids = no

# Add connections here.

# Sample VPN connections

conn %default
  ikelifetime=60m
  keylife=20m
  rekeymargin=3m
  keyingtries=1
  keyexchange=ikev1
  authby=secret
  ike=aes128-sha1-modp1024,3des-sha1-modp1024!
  esp=aes128-sha1-modp1024,3des-sha1-modp1024!

conn myvpn
  keyexchange=ikev1
  left=%defaultroute
  auto=add
  authby=secret
  type=transport
  leftprotoport=17/1701
  rightprotoport=17/1701
  right=$VPN_SERVER_IP
EOF

cat > /etc/ipsec.secrets <<EOF
: PSK "$VPN_IPSEC_PSK"
EOF

chmod 600 /etc/ipsec.secrets

cat > /etc/xl2tpd/xl2tpd.conf <<EOF
[lac myvpn]
lns = $VPN_SERVER_IP
ppp debug = yes
pppoptfile = /etc/ppp/options.l2tpd.client
length bit = yes
EOF

cat > /etc/ppp/options.l2tpd.client <<EOF
ipcp-accept-local
ipcp-accept-remote
refuse-eap
require-chap
noccp
noauth
mtu 1280
mru 1280
noipdefault
defaultroute
usepeerdns
connect-delay 5000
name $VPN_USER
password $VPN_PASSWORD
EOF

chmod 600 /etc/ppp/options.l2tpd.client

mkdir -p /var/run/xl2tpd
touch /var/run/xl2tpd/l2tp-control

service strongswan restart
service xl2tpd restart

echo -e 'executing: `ip route`'
ip route

echo -e 'enter value of X.X.X.X, from previous command.\n default via X.X.X.X ...'
read GATEWAY_IP

route add $VPN_SERVER_IP gw $GATEWAY_IP

echo -e 'Verify that your traffic is being routed properly.\nwget -qO- http://ipv4.icanhazip.com; echo
\nThe bellow ip should be your VPN server IP.'
wget -qO- http://ipv4.icanhazip.com; echo