FROM alpine:3.14 AS builder

RUN apk add alpine-sdk && \
    wget http://www.unixwiz.net/tools/nbtscan-source-1.0.35.tgz && \
    tar zxvf nbtscan-source-1.0.35.tgz && \
    make

FROM alpine:3.14

WORKDIR /home

COPY --from=builder /nbtscan /usr/bin/nbtscan
COPY run.sh netbios_scanner.sh ./

RUN apk add --no-cache dnsmasq && \
    echo "addn-hosts=/etc/hosts.netbios" > /etc/dnsmasq.conf && \
    echo "conf-dir=/etc/dnsmasq,*.conf" >> /etc/dnsmasq.conf && \
    chmod 755 /usr/bin/nbtscan && \
    chmod 755 ./run.sh && \
    chmod 755 ./netbios_scanner.sh

VOLUME /etc/dnsmasq

EXPOSE 53/tcp 53/udp

CMD ["./run.sh"]
