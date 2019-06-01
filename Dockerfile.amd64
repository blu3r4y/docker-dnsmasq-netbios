FROM alpine:3.9

COPY run.sh netbios_scanner.sh /home/

RUN apk add --no-cache alpine-sdk && \
    cd /tmp && \
    wget http://www.unixwiz.net/tools/nbtscan-source-1.0.35.tgz && \
    tar zxvf nbtscan-source-1.0.35.tgz && \
    make && \
    export INSTDIR=/usr/bin && \
    make -f makefile all && \
    make -f makefile install && \
    apk del alpine-sdk && \
    rm -rf /tmp/* && \
    apk add --no-cache dnsmasq && \
    echo "addn-hosts=/etc/hosts.netbios" > /etc/dnsmasq.conf && \
    echo "conf-dir=/etc/dnsmasq,*.conf" >> /etc/dnsmasq.conf && \
    chmod 755 /home/run.sh && \
    chmod 755 /home/netbios_scanner.sh

VOLUME ["/etc/dnsmasq"]

EXPOSE 53/tcp 53/udp

CMD ["/home/run.sh"]
