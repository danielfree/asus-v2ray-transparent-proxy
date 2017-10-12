#!/bin/sh
jobexist=`cru l|grep v2raycheck`
if [ -z "$jobexist" ]
then
   cru a v2raycheck "*/10 * * * * /bin/sh /jffs/check.sh"
fi
/jffs/nat-start.sh
sleep 2
/jffs/v2ray-start.sh