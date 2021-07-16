#!/bin/sh

echo "Starting netbios scanner in the background ..."
nohup ./netbios_scanner.sh &

echo "Starting dnsmasq in the foreground ..."
exec dnsmasq -k
