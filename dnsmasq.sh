#!/bin/sh
touch /jffs/configs/dnsmasq.conf.add
echo "server=/#/202.141.162.123" > /jffs/configs/dnsmasq.conf.add
cat accelerated-domains.china.conf >> /jffs/configs/dnsmasq.conf.add
service restart_dnsmasq