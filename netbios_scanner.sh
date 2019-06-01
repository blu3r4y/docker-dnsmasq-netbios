#!/bin/sh

NETBIOS_NETWORK=${NETBIOS_NETWORK:=192.168.0.0/24}
NETBIOS_NAME_SUFFIX=${NETBIOS_NAME_SUFFIX:=.local}
NETBIOS_SCAN_INTERVAL=${NETBIOS_SCAN_INTERVAL:=600}

while true; do

    # get dnsmasq pid
    DNSMASQ_PID=$(ps -e | awk '$4=="dnsmasq" {print $1}')

    # do a netbios scan, append suffix and save it to a file
    # nbtscan -t 30 -m 3 -eq $NETBIOS_NETWORK | sed -e 's/\s*$/'$NETBIOS_NAME_SUFFIX'/' > /tmp/hosts.netbios.tmp
    nbtscan -n -T 30 -w 200 -t 3 $NETBIOS_NETWORK 2>/dev/null | awk '{print $1, $2"'$NETBIOS_NAME_SUFFIX'"}' | sed -e 's/\S*\\//' > /tmp/hosts.netbios

    # update the hosts file
    mv /tmp/hosts.netbios /etc/hosts.netbios

    # send SIGHUP to dnsmasq to trigger reload
    kill -SIGHUP $DNSMASQ_PID

    # wait for next scan
    sleep $NETBIOS_SCAN_INTERVAL

done
