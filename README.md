# `dnsmasq` + `nbtscan` = ❤️

[![MIT License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE.txt)

This container bundles [`dnsmasq`](http://thekelleys.org.uk/dnsmasq/doc.html) and [`nbtscan`](http://www.unixwiz.net/tools/nbtscan.html), offering you a DNS server which automatically registers Windows NetBIOS host names as well.

- `dnsmasq` offers a simple fully-configurable DNS (and DHCP) server
- `nbtscan` scans the local network for NetBIOS names (i.e. most-likely Windows hosts) and registers their names as `SOME-NETBIOS-NAME.local`

The image is available for `amd64` and `arm32` architectures (e.g. Raspberry Pis).

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
        blu3r4y/dnsmasq-netbios:latest

After a short amount of time, your NetBIOS host names will be available with a `.local` suffix, e.g. try `nslookup SOME-NETBIOS-NAME.local`.
By default, your network is scanned for NetBIOS names every five minutes.

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
| `NETBIOS_SCAN_INTERVAL` | `300` | The interval in seconds at which `nbtscan` scans the specified network for NetBIOS names. |

## Troubleshooting

Observe the logs if your container misbehaves.

    docker logs dnsmasq
