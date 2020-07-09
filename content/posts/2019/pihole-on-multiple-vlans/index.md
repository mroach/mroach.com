---
date: 2019-11-28T00:00:00+00:00
title: "Using PiHole on multiple VLANs"
categories:
  - tech
tags:
  - raspberry-pi
  - pihole
  - networking
aliases:
  - /2019/11/28/pihole-on-multiple-vlans/
---

Pi-hole has been working like a charm on my network for years blocking ads.
I also have it configured with DNS-over-HTTPS using `cloudflared` for extra
security and privacy. Pi-hole has a great [guide to setting-up DoH].

I recently reconfigured my home network with VLANs to separate the different
kinds of devices on my network. There's my primary/private LAN with the network
gear, servers, and my personal systems. Then there's a VLAN for scary IoT stuff
and one for medium-trust devices like Xbox, PlayStation, Apple TV; devices that
can access Plex for example but nothing more.

The quick and easy solution would have been allowing the all VLANs to access
Pi-hole. For extra privacy, I don't even want the IoT or medium trust devices
knowing they're on a VLAN or that the private network exists.

My solution was to join the Pi-hole to each VLAN and then configure the DHCP
settings for each VLAN to use the Pi-hole as the DNS server.

### Editing configuration on the Pi-hole

SSH into your Pi-hole. First, edit `/etc/network/interfaces` with `sudo`

For each VLAN, add a section like the following. In this example, the VLAN ID
is `10` and I'm assigning the Pi-hole to `172.16.10.3`

```plain
auto eth0.10
iface eth0.10 inet static
  address 172.16.10.3/24
```

Then run `sudo ifup eth0.10` and then running `ip addr` you should see this
interface up and running with the given IP. That's it!

You can add as many of these as you like. Here's my full `interfaces` config.
The first entry is the main/primary IP and I give it the `gateway` so when
it goes to access the internet, it's doing it via the main/private LAN.

```plain
auto eth0
iface eth0 inet static
  address 10.65.0.3/24
  gateway 10.65.0.1

auto eth0.2
iface eth0.2 inet static
  address 10.65.2.3/24

auto eth0.5
iface eth0.5 inet static
  address 10.65.5.3/24

auto eth0.7
iface eth0.7 inet static
  address 10.65.7.3/24

auto eth0.10
iface eth0.10 inet static
  address 172.16.10.3/24

auto eth0.20
iface eth0.20 inet static
  address 172.16.20.3/24

auto eth0.30
iface eth0.30 inet static
  address 172.16.30.3/24
```

### Block DNS queries to the WAN

With my DHCP settings pointing all devices to Pi-hole on all networks, the last
change I made was to my firewall to block all outbound port 53 traffic.
This prevents naughty devices from ignoring the DNS settings and talking directly
to DNS servers they have hardcoded. Chrome, Amazon Echo, smart TVs, and all
sorts of "smart" devices have been caught with hardcoded DNS.

### Securing Pi-hole with iptables

Now that the Pi-hole is joined to every VLAN, by default any host on any VLAN
would have access to the HTTP admin, SSH, or any other services you have
running on the host. Since it's joined directly to the VLAN and requests
won't go through your router, locking-down ports has to be done on the Pi-hole
using `iptables`.

In my case, my VLAN `2` is for management, so any traffic from that VLAN is
permitted. On all other VLANs, only port `53` traffic is accepted.

Here's what I did, using `sudo`:

```shell
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A INPUT -i eth0.2 -j ACCEPT
sudo iptables -A INPUT -i eth0.3 -p tcp --dport 53 -j ACCEPT
sudo iptables -A INPUT -i eth0.5 -p tcp --dport 53 -j ACCEPT
sudo iptables -A INPUT -i eth0.7 -p tcp --dport 53 -j ACCEPT
sudo iptables -A INPUT -i eth0.10 -p tcp --dport 53 -j ACCEPT
sudo iptables -A INPUT -i eth0.20 -p tcp --dport 53 -j ACCEPT
sudo iptables -A INPUT -i eth0.30 -p tcp --dport 53 -j ACCEPT
sudo iptables -P INPUT DROP
```

Bonus fun: if you have a lot of VLANs you can easily generate the `iptables` commands.

```shell
echo {3,5,7,10,20,30} | \
  xargs -n1 sh -c 'echo iptables -A INPUT -i eth0.$0 -p tcp --dport 53 -j ACCEPT'
```

Then once you're happy with how everything is working, save the configuration:

```shell
sudo iptables-save | sudo tee /etc/pihole/rules.v4
```


[guide to setting-up DoH]: https://docs.pi-hole.net/guides/dns-over-https/
