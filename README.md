# `dnsmasq` + `nbtscan` = ❤️

[![MIT License](https://img.shields.io/badge/License-MIT-yellow.svg?style=popout-square)](LICENSE.txt)
[![GitHub Latest Release](https://img.shields.io/github/v/release/blu3r4y/docker-dnsmasq-netbios?style=popout-square)](https://github.com/blu3r4y/docker-dnsmasq-netbios/releases/latest)
[![GitHub Workflow Status](https://img.shields.io/github/workflow/status/blu3r4y/docker-dnsmasq-netbios/build-container-images?style=popout-square)](https://github.com/blu3r4y/docker-dnsmasq-netbios/actions)
[![Docker Pulls](https://img.shields.io/docker/pulls/blu3r4y/dnsmasq-netbios.svg?style=popout-square)](https://hub.docker.com/r/blu3r4y/dnsmasq-netbios)
[![Docker Image Size](https://img.shields.io/docker/image-size/blu3r4y/dnsmasq-netbios?style=popout-square)](https://hub.docker.com/r/blu3r4y/dnsmasq-netbios)

This container bundles [`dnsmasq`](http://thekelleys.org.uk/dnsmasq/doc.html) and [`nbtscan`](http://www.unixwiz.net/tools/nbtscan.html), offering you a DNS server that also automatically registers [NetBIOS](https://en.wikipedia.org/wiki/NetBIOS) hostnames, which are usually advertised by Windows hosts on the local network.

💻 `dnsmasq` offers a simple, fully-configurable DNS (and DHCP) server  
🔍 `nbtscan` periodically scans and registers NetBIOS names as e.g. `WINDOWS-HOST.local` entries in `dnsmasq`

The image is built for `amd64`, `arm64`, `arm/v6` and `arm/v7` architectures, so you can also run it on your Raspberry Pi.

## Quick Start

1. Put your `*.conf` configuration files into some folder - or use the [`dnsmasq.sample.conf`](./dnsmasq/dnsmasq.sample.conf)
2. Start the container, with a volume mapped to your configuration folder and the target network set

```shell
docker run --detach \
    --name dnsmasq-netbios \
    --restart always \
    -p 53:53/udp --cap-add=NET_ADMIN \
    -e "NETBIOS_NETWORK=192.168.0.0/24" \
    -v /srv/dnsmasq:/etc/dnsmasq \
    blu3r4y/dnsmasq-netbios
```
        
You can also use the supplied [`docker-compose.yml`](docker-compose.yml)

    docker-compose up -d

After some minutes, your NetBIOS hostnames will be available with a `.local` suffix - customize this with `NETBIOS_NAME_SUFFIX`.
By default, your network is scanned for NetBIOS names every ten minutes - customize this with `NETBIOS_SCAN_INTERVAL`.

    nslookup WINDOWS-HOST.local

### Troubleshooting

If your container misbehaves, observe the logs

    docker logs dnsmasq-netbios

If you think that your NetBIOS devices are not scanned, this could be a networking issue.
Try adding the `--net=host` argument and removing the `-p 53:53/udp` argument so that Docker does not isolate the network stack.

## Why would I need this container?

This container acts as a standard `dnsmasq` DNS (and DHCP) server with a twist.

A `nbtscan` script automatically discovers and dynamically registers [NetBIOS](https://en.wikipedia.org/wiki/NetBIOS) names as entries within this name server.
Thus, Linux hosts can easily resolve Windows hostnames, e.g. `ping WINDOWS-HOST.local` just works, since it is resolved reliably by this name server on the [Network Layer](https://en.wikipedia.org/wiki/Network_layer) instead of the NetBIOS protocol on the [Data Link Layer](https://en.wikipedia.org/wiki/Data_link_layer).

This solves two problems: Hosts or applications, which do not utilize the NetBIOS protocol or do not want to, can resolve NetBIOS names dynamically through the name server instead. Additionally, since NetBIOS acts on the Data Link Layer, hosts would not be able to resolve NetBIOS names which are not within their broadcast domain, i.e. in a routed network situation, e.g. if you try to reach hosts hidden behind a WiFi Access Point.

## Advanced Configuration

Follow the official [`dnsmasq` manpage](http://thekelleys.org.uk/dnsmasq/docs/dnsmasq-man.html) for all available options.

You can add multiple configuration files (which must end in `.conf`) in the mapped volume.

You have to restart the container when making changes to the configuration.

    docker restart dnsmasq-netbios

### Available environment variables

| Environment Variable | Default Value | Description |
|-------------------------|------------------|--------------------------------------------------------------------------------------------------------------------------------------------|
| `NETBIOS_NETWORK` | `192.168.0.0/24` | The network to be scanned by `nbtscan`. This might be a list of IP addresses, DNS names, or address ranges. Ranges can be in `/nbits` notation (`192.168.12.0/24`) or with a range in the last octet (`192.168.12.64-97`). |
| `NETBIOS_NAME_SUFFIX` | `.local` | This suffix will be added to each NetBIOS name. E.g., the name `WINDOWS-PC` will be available as `WINDOWS-PC.local` in the DNS. |
| `NETBIOS_SCAN_INTERVAL` | `600` | The interval in seconds at which `nbtscan` scans the specified network for NetBIOS names. |
