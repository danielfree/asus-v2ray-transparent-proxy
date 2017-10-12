#!/bin/sh
alias echo_date='echo $(date +%Y年%m月%d日\ %X):'
#v2ray_ip=$1
v2ray_ip=YOUR_SERVER_IP

load_module(){
	xt=`lsmod | grep xt_set`
	OS=$(uname -r)
	if [ -f /lib/modules/${OS}/kernel/net/netfilter/xt_set.ko ] && [ -z "$xt" ];then
		echo_date "加载xt_set.ko内核模块！"
		insmod /lib/modules/${OS}/kernel/net/netfilter/xt_set.ko
	fi
}

add_white_ip(){
	# white ip/cidr
	ip1=$(nvram get wan0_ipaddr | cut -d"." -f1,2)
	SERVER_IP=$v2ray_ip
	ip_lan="0.0.0.0/8 10.0.0.0/8 100.64.0.0/10 127.0.0.0/8 169.254.0.0/16 172.16.0.0/12 192.168.0.0/16 224.0.0.0/4 240.0.0.0/4 $ip1.0.0/16 $SERVER_IP 223.5.5.5 223.6.6.6 114.114.114.114 114.114.115.115 1.2.4.8 210.2.4.8 112.124.47.27 114.215.126.16 180.76.76.76 119.29.29.29 202.141.162.123"
	for ip in $ip_lan
	do
		iptables -t nat -A V2RAY -d $ip -j RETURN
	done
}

apply_nat(){
    iptables -t nat -N V2RAY
    add_white_ip
    iptables -t nat -A V2RAY -p tcp -m set --match-set white_list dst -j RETURN

    #for hulu.com
    iptables -t nat -A V2RAY -p tcp --dport 1935 -j REDIRECT --to-ports 1080
    iptables -t nat -A V2RAY -p udp --dport 1935 -j REDIRECT --to-ports 1080

    # for Chrome browser and youtube.com
    iptables -t nat -A V2RAY -p udp --dport 443 -j REDIRECT --to-ports 1080
    iptables -t nat -A V2RAY -p tcp -j REDIRECT --to-port 1080

    #load_tproxy
    #/usr/sbin/ip rule add fwmark 0x01/0x01 table 310 pref 789
    #/usr/sbin/ip route add local 0.0.0.0/0 dev lo table 310
    #iptables -t mangle -N V2RAY
    #iptables -t mangle -A V2RAY -p udp -m set --match-set white_list dst -j RETURN
    #iptables -t mangle -A V2RAY -p udp -j TPROXY --on-port 1080 --tproxy-mark 0x01/0x01

    iptables -t nat -A PREROUTING -p tcp -j V2RAY
    #iptables -t mangle -A PREROUTING -p udp -j V2RAY
}


flush_nat(){
	echo_date 尝试先清除已存在的iptables规则，防止重复添加
	# flush rules and set if any
	iptables -t nat -D PREROUTING -p tcp -j V2RAY >/dev/null 2>&1
	sleep 1
	iptables -t nat -F V2RAY > /dev/null 2>&1 && iptables -t nat -X V2RAY > /dev/null 2>&1
	iptables -t mangle -D PREROUTING -p udp -j V2RAY >/dev/null 2>&1
	iptables -t mangle -F V2RAY >/dev/null 2>&1 && iptables -t mangle -X V2RAY >/dev/null 2>&1
}

flush_ipset(){
	echo_date 先清空已存在的ipset名单，防止重复添加
	ipset -F white_list >/dev/null 2>&1 && ipset -X white_list >/dev/null 2>&1
}

remove_redundant_rule(){
	ip_rule_exist=`/usr/sbin/ip rule show | grep "fwmark 0x1/0x1 lookup 310" | grep -c 310`
	#ip_rule_exist=`ip rule show | grep "fwmark 0x1/0x1 lookup 310" | grep -c 300`
	if [ ! -z "ip_rule_exist" ];then
		echo_date 清除重复的ip rule规则.
		until [ "$ip_rule_exist" = 0 ]
		do
			#ip rule del fwmark 0x01/0x01 table 310
			/usr/sbin/ip rule del fwmark 0x01/0x01 table 310 pref 789
			ip_rule_exist=`expr $ip_rule_exist - 1`
		done
	fi
}

remove_route_table(){
	echo_date 删除ip route规则.
	/usr/sbin/ip route del local 0.0.0.0/0 dev lo table 310 >/dev/null 2>&1
}

load_tproxy(){
	MODULES="nf_tproxy_core xt_TPROXY xt_socket xt_comment"
	OS=$(uname -r)
	# load Kernel Modules
	echo_date 加载TPROXY模块，用于udp转发...
	checkmoduleisloaded(){
		if lsmod | grep $MODULE &> /dev/null; then return 0; else return 1; fi;
	}

	for MODULE in $MODULES; do
		if ! checkmoduleisloaded; then
			insmod /lib/modules/${OS}/kernel/net/netfilter/${MODULE}.ko
		fi
	done

	modules_loaded=0

	for MODULE in $MODULES; do
		if checkmoduleisloaded; then
			modules_loaded=$(( i++ ));
		fi
	done

	if [ $modules_loaded -ne 3 ]; then
		echo "One or more modules are missing, only $(( modules_loaded+1 )) are loaded. Can't start.";
		exit 1;
	fi
}

# creat ipset rules
creat_ipset(){
	echo_date 创建ipset名单
	ipset -! create white_list nethash && ipset flush white_list
}

load_module
flush_ipset
flush_nat
remove_redundant_rule
remove_route_table
creat_ipset
apply_nat