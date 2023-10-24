#!/bin/bash 

NET="enp4s0"
VPN="wg0"
VPN_IP="10.60.0.0/24"

start() {
    sysctl -w net.ipv4.ip_forward=1
    sysctl -w net.ipv6.conf.all.forwarding=1
    iptables -t nat -A POSTROUTING -s ${VPN_IP} -o ${NET} -j MASQUERADE
    iptables -t nat -A POSTROUTING -o ${NET} -j MASQUERADE
    iptables -A FORWARD -i ${VPN} -j ACCEPT
    iptables -A FORWARD -i ${VPN} -o ${NET} -m conntrack --ctstate NEW -j ACCEPT
    iptables -A FORWARD -i ${VPN} -o ${NET} -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
    iptables -A FORWARD -i ${NET} -o ${VPN} -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
    ip6tables -t nat -A POSTROUTING -o ${NET} -j MASQUERADE
    ip6tables -A FORWARD -i ${VPN} -j ACCEPT
    ip6tables -A FORWARD -i ${VPN} -o ${NET} -m conntrack --ctstate NEW -j ACCEPT
    ip6tables -A FORWARD -i ${VPN} -o ${NET} -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
    ip6tables -A FORWARD -i ${NET} -o ${VPN} -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
}

stop() {
    sysctl -w net.ipv4.ip_forward=0
    sysctl -w net.ipv6.conf.all.forwarding=0
    iptables -t nat -D POSTROUTING -s ${VPN_IP} -o ${NET} -j MASQUERADE
    iptables -t nat -D POSTROUTING -o ${NET} -j MASQUERADE
    iptables -D FORWARD -i ${VPN} -j ACCEPT
    iptables -D FORWARD -i ${VPN} -o ${NET} -m conntrack --ctstate NEW -j ACCEPT
    iptables -D FORWARD -i ${VPN} -o ${NET} -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
    iptables -D FORWARD -i ${NET} -o ${VPN} -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
    ip6tables -t nat -D POSTROUTING -o ${NET} -j MASQUERADE
    ip6tables -D FORWARD -i ${VPN} -j ACCEPT
    ip6tables -D FORWARD -i ${VPN} -o ${NET} -m conntrack --ctstate NEW -j ACCEPT
    ip6tables -D FORWARD -i ${VPN} -o ${NET} -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
    ip6tables -D FORWARD -i ${NET} -o ${VPN} -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
}

case $1 in
    "start")
        start
        exit 0
        ;;
     "stop")
        stop
        exit 0
        ;;
      *)
        echo "Usage: $0 start|stop"
        exit 1
        ;;
esac
