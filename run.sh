#!/bin/sh

CONF_DIR="/etc/dnsmasq"

if [ -d "$CONF_DIR" ]
then
    if [ "$(ls -A $CONF_DIR)" ]; then

        echo -n "found configuration files in $CONF_DIR: "
        ls -A $CONF_DIR

        echo "starting netbios scanner in the background ..."
        nohup ./netbios_scanner.sh >/dev/null 2>&1 &

        echo "starting dnsmasq in the foreground ..."
        exec dnsmasq -k

    else
        echo "error: configuration directory $CONF_DIR is empty - did you map a volume?"
    fi
else
    echo "error: configuration directory $CONF_DIR is missing - did you map a volume?"
fi

exit 1
