#! /usr/bin/sh

iptables -F
iptables -X
iptables -Z
iptables -t nat -F
iptables -t nat -X
iptables -t nat -Z

iptables -P INPUT DROP
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT

echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "1" > /proc/sys/net/ipv4/ip_forward

iptables -A INPUT -s 127.0.0.1 -d 127.0.0.1 -j ACCEPT
iptables -A INPUT -s 192.168.2.0/24 -d 192.168.2.1 -j ACCEPT
iptables -A INPUT -s 192.168.2.0/24 -d 192.168.2.11 -j ACCEPT
iptables -A INPUT -s 192.168.1.0/24 -i LAN -j ACCEPT
iptables -A INPUT -s 192.168.2.0/24 -i LAN -j ACCEPT
iptables -A INPUT -i WAN -j ACCEPT
iptables -A INPUT -i wlan0 -j ACCEPT

#iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -j MASQUERADE
#iptables -t nat -A POSTROUTING -s 192.168.2.0/24 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -o WAN -j MASQUERADE
iptables -t nat -A POSTROUTING -s 192.168.2.0/24 -o WAN -j MASQUERADE



#iptables --table nat --append POSTROUTING --jump MASQUERADE
#iptables -A INPUT -p udp --dport 500 -j ACCEPT
#iptables -t nat -A POSTROUTING -s 192.168.0.0/24 -j MASQUERADE
exit 0
