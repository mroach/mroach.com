---
date: 2018-03-30T00:00:00Z
title: Active Directory, DNS, and a Ubiquiti EdgeRouter
categories:
  - Tech
  - Guides
tags:
  - Ubiquiti
  - Active Directory
  - DNS
aliases:
  - /2018/03/30/active-directory-dns-ubiquiti-edgerouter/
---

You've got a Ubiquiti EdgeRouter and an Active Directory domain. Here's how you make them play nicely together.

<!--more-->

I love enterprise solutions for the home. Working alongside my EdgeRouter-X in the core of my network is a [Synology DS218+] NAS as my Active Directory server, among other roles.

Active Directory works its magic through DNS. Without appropriate DNS records setup, clients can't find the domain controller. Microsoft would tell you that your domain controllers should be the DNS and DHCP servers for your LAN. I don't like that since it means if your domain controllers are down, you can't even access the internet.

Turns out, AD really only needs a few records to work:

```plain
SRV _ldap._tcp.pdc._msdcs.<DnsDomainName>
SRV _ldap._tcp.gc._msdcs.<DnsForestName>
SRV _kerberos._tcp.dc._msdcs.<DnsDomainName>
SRV _ldap._tcp.dc._msdcs.<DnsDomainName>
A   <DomainControllerFQDN>
```

And if you have clients that can't lookup SRV, you need these, although I've yet to find a situation requiring this so I've ignored it for the rest of the post.

```plain
A     gc._msdcs.<DnsForestName>
CNAME <DsaGUID>._msdcs.<DnsForestName>
```

There are at least three ways you can solve this. Throughout the example our AD domain will be called `derpanet.lan` and our AD server will be `dc.derpanet.lan` with IP `10.65.49.10`.

## DNS server: dnsmasq

I'm using *dnsmasq* for my DHCP server rather than the default *ISC DHCPD* simply because it allows for easy resolution of DHCP hosts. This guide is for *dnsmasq*. If you want to use it, enable it:

```shell
configure
set service dhcp-server use-dnsmasq enable
commit
```

## Option 1: Forward all DNS to Active Directory

This is the quick and easy one-liner of configuration change that has your router forward all DNS queries to you Active Directory controller.

```shell
configure
set service dns forwarding name-server 10.65.49.10
commit
```

There are two significant downsides to this approach:

1. You'll lose DNS resolution for DHCP clients.
2. If your AD server is down, your whole internet is down.

So I'm not using that option.


## Option 2: Forward only the AD domain

```shell
configure
set service dns forwarding options server=/derpanet.lan/10.65.49.10
commit
```

This one-liner tells the router to forward all DNS requests for the domain `derpanet.lan` to the Active Directory server. This cleanly avoids both problems noted in Option 1 above.

The downside to this approach is that the domains for your router's DHCP and Active Directory have to be different. If that isn't a problem, this is a good solution.

You can change your DHCP domain like so:

```shell
configure

set service dhcp-server shared-network-name LAN subnet 10.65.49.0/24 domain-name dhcp.derpanet.lan
set system domain-name dhcp.derpanet.lan

commit
```


## Option 3: Setup the required DNS records statically

This option will avoid the downsides in the first two options. The only downside it introduces is that if your domain setup changes, such as adding a secondary domain controller, you have to manually update your DNS records.

Here's how to do it using the nice shortcut of editing a node (`service dns forwarding`) to shorten commands:

```shell
configure
edit service dns forwarding

set options address=/dc.derpanet.lan/10.65.49.10
set options srv-host=_ldap._tcp.pdc._msdcs.derpanet.lan,dc.derpanet.lan,389,0,100
set options srv-host=_kerberos._tcp.dc._msdcs.derpanet.lan,dc.derpanet.lan,88,0,100
set options srv-host=_ldap._tcp.dc._msdcs.derpanet.lan,dc.derpanet.lan,389,0,100
set options srv-host=_ldap._tcp.gc._msdcs.derpanet.lan,dc.derpanet.lan,3268,0,100

commit
```

What we're doing there is adding an `A` record for the domain controller, and then adding four `SRV` records. The bits after the hostname are the port, priority, and weight. If you had more domain controllers in your forest you'd adjust these accordingly.

## Checking

Whichever option you pick, it's time to verify that it's working.

### Linux or macOS

The `host` command does the job nicely

```plain
domain=derpanet.lan
host -t SRV _ldap._tcp.gc._msdcs.${domain}
host -t SRV _ldap._tcp.pdc._msdcs.${domain}
host -t SRV _kerberos._tcp.dc._msdcs.${domain}
host -t SRV _ldap._tcp.dc._msdcs.${domain}
```

If everything was configured properly, you should have output looking like this:

```plain
_ldap._tcp.gc._msdcs.derpanet.lan has SRV record 0 100 3268 dc.derpanet.lan.
_ldap._tcp.pdc._msdcs.derpanet.lan has SRV record 0 100 389 dc.derpanet.lan.
_kerberos._tcp.dc._msdcs.derpanet.lan has SRV record 0 100 88 dc.derpanet.lan.
_ldap._tcp.dc._msdcs.derpanet.lan has SRV record 0 100 389 dc.derpanet.lan.
```

I like to run-run the `host` commands with another argument at the end: the IP of the AD server. That way you query it directly for DNS records and you can ensure that they're the same!

```plain
domain=derpanet.lan
host -t SRV _ldap._tcp.gc._msdcs.${domain} 10.65.49.10
host -t SRV _ldap._tcp.pdc._msdcs.${domain} 10.65.49.10
host -t SRV _kerberos._tcp.dc._msdcs.${domain} 10.65.49.10
host -t SRV _ldap._tcp.dc._msdcs.${domain} 10.65.49.10
```

### Windows

Open the command prompt and run `nslookup`, type in `set type=all` and hit enter, then type each hostname bits and hit enter. You should get answers with `SRV service location:` and all the configuration we added above:

```cmd
nslookup

> set type=all
> _ldap._tcp.gc._msdcs
> _ldap._tcp.pdc._msdcs
> _kerberos._tcp.dc._msdcs
> _ldap._tcp.dc._msdcs
```
## References

* [DNS Records that are required for proper functionality of Active Directory](https://blogs.msdn.microsoft.com/servergeeks/2014/07/12/dns-records-that-are-required-for-proper-functionality-of-active-directory/)

[Synology DS218+]: https://amzn.to/2uArAfS
