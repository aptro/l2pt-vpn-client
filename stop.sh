echo 'Stopping routing traffic via the VPN server.'
route del default dev ppp0

echo -e 'disconnecting.'
echo "d myvpn" > /var/run/xl2tpd/l2tp-control
ipsec down myvpn

exit 0