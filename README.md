## asus-v2ray-transparent-proxy

Transparent proxy on WiFi router with v2ray+dnsmasq+ipset. Tested on Asus RT-68U Merlin firmware (7.4).

### Internal Details

1. Chinese domain whitelist mode. We use [dnsmasq-china-list](https://github.com/felixonmars/dnsmasq-china-list) from @felixonmars and add to ipset white_list rules, so only domains in this list will be resolved via 119.29.29.29, everything else will be resolved via 202.141.162.123 (USTC LUG anti-pollution DNS).

2. Setup iptables to use ipset for direct connect and redirect everything else to local v2ray transparent proxy port.

3. Start v2ray on router opening two ports: 1080 as transparent proxy, 1081 as socks port. Requests from 1080 will be forwarded to 1081 as defined in v2ray config.

### Usage
Requirements: Asus Merlin firmware, jffs enabled, ssh connection, a working v2ray server

1. Download v2ray-linux-arm.zip from [v2ray release page](https://github.com/v2ray/v2ray-core/releases) and unzip to /jffs/v2ray/ via ssh

2. Clone this repo, cp everything to /jffs/ via ssh

3. On router: modify /jffs/config.json according to your proxy server and cp to /jffs/v2ray/config.json

4. On router: modify /jffs/nat-start.sh, change "YOUR_SERVER_IP" to your proxy server's ip

5. On router: run `sh /jffs/dnsmasq.sh && sh /jffs/start-all.sh` to setup dnsmasq/v2ray and start service

6. If everything goes well, connect to your WiFi and enjoy

7. If you want to enable this after router reboot, add /jffs/start-all.sh in NAT-START script (you can find it on router's admin web -> Tools -> Script)

## asus-v2ray-transparent-proxy

无线路由器上跑的透明代理，使用 v2ray+dnsmasq+ipset。 在 RT-68U Merlin (7.4) 固件上测试通过。

### 工作原理

1. 国内域名白名单模式，使用 @felixonmars 的 [dnsmasq-china-list](https://github.com/felixonmars/dnsmasq-china-list) 加入 ipset rules 白名单，名单内的域名将使用 119.29.29.29 来解析，剩下全部交给中科大防污染 DNS 202.141.162.123 解析。

2. 使用 iptables 做分流，ipset rule 中的直接访问，剩下的流量全部走 v2ray 本地透明代理端口。

3. 启动 v2ray 开放两个端口：1080 透明代理和 1081 socks 代理，由 v2ray 的配置程序指定所有发往 1080 端口的数据自动转发到 1081 上。

### 使用方法
前提要求：Asus 梅林固件，启用了 jffs 和 ssh, 以及一个可用的 v2ray 远程服务器

1. 从 [v2ray release page](https://github.com/v2ray/v2ray-core/releases) 下载 v2ray-linux-arm.zip， 解压缩后通过 ssh 上传至 /jffs/v2ray/ 目录

2. 下载本 repo 中的所有文件到本地，通过 ssh 上传至 /jffs 目录

3. 在路由器上修改 /jffs/config.json 将其中远程代理服务器替换为你自己使用的设置，复制到 /jffs/v2ray/cofig.json

4. 在路由器上修改 /jffs/nat-start.sh, 将 "YOUR_SERVER_IP" 修改为你的远程 v2ray 服务器 ip

5. 在路由器上运行 `sh /jffs/dnsmasq.sh && sh /jffs/start-all.sh` 来配置 dnsmasq/v2ray 并启动相关服务

6. 如果一切顺利，连上你的 WiFi 即可

7. 如果想在重启路由器后可以自动启动，可以将 /jffs/start-all.sh 加入 NAT-START 脚本，你可以在路由器管理界面的 Tools->Script 页面找到设置的地方
