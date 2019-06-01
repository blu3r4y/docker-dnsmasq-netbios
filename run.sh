#!/bin/sh

echo "Starting netbios scanner in the background ..."
nohup /home/netbios_scanner.sh &

echo "Starting dnsmasq..."
exec dnsmasq
