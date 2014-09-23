#!/bin/sh

/bin/echo `/bin/date +"%F %T"` $* >> /tmp/dnsmasq.script.log

if [ "$1" == "add" ] && ! grep -iq $2 /etc/config/dhcp; then
  echo -e "Subject: New MAC on `uci get system.@system[0].hostname`.`uci get dhcp.@dnsmasq[0].domain`\\n\\n`/bin/date +"%F %T"` $*" | sendmail martin.stiborsky@gmail.com
fi
