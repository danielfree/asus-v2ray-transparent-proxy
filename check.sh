#!/bin/sh
count=`ps|grep v2ray|grep -v grep`
if [ -z "$count" ]
then
  /jffs/v2ray-start.sh
fi