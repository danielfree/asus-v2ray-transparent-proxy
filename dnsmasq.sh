#!/bin/sh
mkdir -p /jffs/configs/dnsmasq.d
echo "server=/#/202.141.162.123" > /jffs/configs/dnsmasq.d/vpn.conf
echo "conf-dir=/jffs/configs/dnsmasq.d" >> /etc/dnsmasq.conf
cp accelerated-domains.china.conf /jffs/configs/dnsmasq.d/accelerated-domains.china.conf
/sbin/service restart-dnsmasq