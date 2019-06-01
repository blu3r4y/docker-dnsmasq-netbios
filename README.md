# `dnsmasq` + `nbtscan` = ❤️

[![MIT License](https://img.shields.io/badge/License-MIT-yellow.svg?style=popout-square)](LICENSE.txt)
[![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/blu3r4y/dnsmasq-netbios.svg?style=popout-square)](https://hub.docker.com/r/blu3r4y/dnsmasq-netbios)
[![Docker Pulls](https://img.shields.io/docker/pulls/blu3r4y/dnsmasq-netbios.svg?style=popout-square)](https://hub.docker.com/r/blu3r4y/dnsmasq-netbios)
[![MicroBadger Size](https://img.shields.io/microbadger/image-size/blu3r4y/dnsmasq-netbios.svg?style=popout-square)](https://hub.docker.com/r/blu3r4y/dnsmasq-netbios)

This container bundles [`dnsmasq`](http://thekelleys.org.uk/dnsmasq/doc.html) and [`nbtscan`](http://www.unixwiz.net/tools/nbtscan.html), offering you a DNS server that also automatically registers [NetBIOS](https://en.wikipedia.org/wiki/NetBIOS) hostnames, which are usually advertised by Windows hosts on the local network.

- `dnsmasq` offers a simple fully-configurable DNS (and DHCP) server
- `nbtscan` scans the local network for NetBIOS names (i.e. most-likely Windows hosts) and registers their names as `SOME-NETBIOS-NAME.local` entries in the name server

The image is available for `amd64` and `arm32` (Raspberry Pi) architectures.

    docker pull blu3r4y/dnsmasq-netbios:amd64
    docker pull blu3r4y/dnsmasq-netbios:arm32

### Why would I need this container?

This container acts as a standard `dnsmasq` DNS (and DHCP) server with a twist.

A `nbtscan` script automatically discovers and dynamically registers [NetBIOS](https://en.wikipedia.org/wiki/NetBIOS) names as entries within this name server.
Thus, Linux hosts can easily resolve Windows hostnames, e.g. `ping WINDOWS-HOST.local` just works, since it is resolved reliably by this name server on the [Network Layer](https://en.wikipedia.org/wiki/Network_layer) instead of the NetBIOS protocol on the [Data Link Layer](https://en.wikipedia.org/wiki/Data_link_layer).

This solves two problems: Hosts or applications, which do not utilize the NetBIOS protocol or do not want to, can resolve NetBIOS names dynamically through the name server instead. Additionally, since NetBIOS acts on the Data Link Layer, hosts would not be able to resolve NetBIOS names which are not within their broadcast domain, i.e. in a routed network situation, e.g. if you try to reach hosts hidden behind a WiFi Access Point.

## Quick Start

Put your `dnsmasq` configuration files into some folder - the default is `/srv/dnsmasq/dnsmasq.conf`.

    # dnsmasq.conf
    keep-in-foreground
    bogus-priv
    no-resolv
    no-hosts

    # upstream dns
    server=8.8.8.8
    server=8.8.4.4

    # read entries from this hosts file (optional)
    # addn-hosts=/etc/dnsmasq/hosts

    # override these names directly (optional)
    # address=/www.yourwebsite.com/192.168.0.1

Start the container, with configuration in volume `/srv/dnsmasq` and the network to be scanned being `192.168.0.0/24`.

    docker run --detach \
        --name dnsmasq \
        --restart always \
        --cap-add=NET_ADMIN --net=host \
        -e "NETBIOS_NETWORK=192.168.0.0/24" \
        --volume /srv/dnsmasq:/etc/dnsmasq \
        blu3r4y/dnsmasq-netbios:amd64
        
Use `blu3r4y/dnsmasq-netbios:arm32` for your Raspberry Pi.

After a short amount of time, your NetBIOS hostnames will be available with a `.local` suffix, e.g. try `nslookup SOME-NETBIOS-NAME.local`.
By default, your network is scanned for NetBIOS names every ten minutes (specify with `NETBIOS_SCAN_INTERVAL`).

## Advanced Configuration

Follow the official [`dnsmasq` manpage](http://thekelleys.org.uk/dnsmasq/docs/dnsmasq-man.html) for all available options.

You can add multiple configuration files (which must end in `.conf`) in the linked volume (default `/srv/dnsmasq`).

You have to restart the container when making changes to the configuration.

    docker restart dnsmasq

### Available environment variables

| Environment Variable | Default Value | Description |
|-------------------------|------------------|--------------------------------------------------------------------------------------------------------------------------------------------|
| `NETBIOS_NETWORK` | `192.168.0.0/24` | The network to be scanned by `nbtscan`. This might be a list of IP addresses, DNS names, or address ranges. Ranges can be in `/nbits` notation (`192.168.12.0/24`) or with a range in the last octet (`192.168.12.64-97`). |
| `NETBIOS_NAME_SUFFIX` | `.local` | This suffix will be added to each NetBIOS name. E.g., the name `WINDOWS-PC` will be available as `WINDOWS-PC.local` in the DNS. |
| `NETBIOS_SCAN_INTERVAL` | `600` | The interval in seconds at which `nbtscan` scans the specified network for NetBIOS names. |

## Troubleshooting

Observe the logs if your container misbehaves.

    docker logs dnsmasq
