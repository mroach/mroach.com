---
title: "Pi-hole and cloudflared with Docker"
date: 2020-08-04T00:00:00Z
draft: false
toc: true
categories:
  - Tech
  - Guide
tags:
  - Pi-hole
  - DNS
  - DNS over HTTPS
  - Docker
  - docker-compose
  - Networking
---

In this guide we'll setup cloudflare and Pi-hole together with docker-compose to create a portable and reproducible secure DNS solution.

<!--more-->

Pi-hole
-------

By now many are familiar with [Pi-hole]. It's a DNS server that subscribes to blocklists to block advertising and tracking services at the network level. So when a browser tries to resolve `ads.doubleclick.net`, Pi-hole says: "nope, doesn't exist".

## cloudflared

{{< figure src="images/cloudflare-logo.png" class="float-right" thumb="150" >}}

[cloudflared] provides another type of security with **DNS over HTTPS**. Traditional DNS is insecure and requests can easily be spied on or modified. **DNS over HTTPS** prevents this by doing what it sounds like: sending your DNS requests over a secure HTTPS connection. Since few devices support DoH, *cloudflared* acts as a proxy between traditional DNS requests and DNS over HTTPS.

[cloudflared]: https://developers.cloudflare.com/argo-tunnel/reference/doh/


Background and pre-configuration
--------------------------------

### Pi-hole and cloudflared relationship

When setting-up Pi-hole, it needs to be configured with the DNS servers it will use to resolve non-blocked requests. By default this is using Google DNS. We would rather not give more data to Google, and we want to use DoH. So, we'll configure Pi-hole to direct all requests to our running instance of cloudflared.

Since cloudflared is now a dependency of Pi-hole in our setup, we'll use [docker-compose] to orchestrate this.

[docker-compose]: https://docs.docker.com/compose/

### Docker `macvlan`

{{< figure src="images/docker-logo.png" class="float-right" thumb="150" >}}

Docker users are probably familiar with the concept of publishing ports. A port on the container can be published to a port on the host when using `docker run` or in a docker-compose configuration.

```shell
docker run --rm -p 80:80 nginx
```

Now we could visit http://localhost or another user on the network can visit http://machine-ip-or-hostname.

The problem here is that now the service is tied to the IP address of the Docker host. It also means only one service per port per Docker host. For HTTP, it's not a big deal to use other ports, like `8080`. This is a problem though with DNS since DNS has to be responding on port `53`.

With [macvlan], Docker can create a new network that generates MAC addresses for containers and lets them have routable IPs on our LAN. If we wanted to, we could have multiple Pi-hole instances running on the same machine, each with its own IP listening on port `53`.

In the examples to follow, we'll say our real network is `10.65.2.0/24` and our router is `10.65.2.1`. We can inform Docker of this topology in a network called `priv_lan` that the host is connected to on interface `eth0`.

We'll create it by hand so that this network is usable by any docker-compose setup and not just the one we'll create later:

```shell
docker network create -d macvlan \
  --subnet=10.65.2.0/24 \
  --gateway=10.65.2.1 \
  -o parent=eth0 priv_lan
```

**Note**: When attaching containers directly to a network, *port mapping has no effect* (i.e. `-p 53:53/udp` does nothing). Whatever services the container has exposed are exposed to our network as-is.

[macvlan]: https://docs.docker.com/network/macvlan/


### DNS over HTTP Servers

By default, cloudflared uses the DoH service of Cloudflare. This is fine, but for redundancy and diversity, we'll add the [Quad9 DoH] servers as well.

* Cloudflare: 1.1.1.1, 1.0.0.1
* Quad9: 9.9.9.9, 149.112.112.9

They both follow the convention of `http://<ip>/dns-query` for the lookup URL.

[Quad9 DoH]: https://www.quad9.net/doh-quad9-dns-servers/


Option 1: Hidden cloudflared
----------------------------

### Internal network

In this setup, we create another Docker network named `internal` that both the cloudflared and Pi-hole containers are connected to. This allows Pi-hole to talk to cloudflared without exposing cloudflared to the rest of the network.

This internal network will be `172.30.9.0/29`. The `/29` netmask provides 5 usable IP addresses (`.1` is the virtual router); plenty for this setup.

### cloudflared

`cloudflared` gets the IP `172.30.9.2` and responds to DNS queries on the unprivileged port `5053`. We bind the DNS service to `0.0.0.0` to so it listens on all interfaces.

### Pi-hole

Pi-hole is assigned the IP `172.30.9.2` on our internal network and gets attached to the real network with the IP `10.65.2.4`.

Pi-hole is configured to use the internal cloudflared as the exclusive DNS server.

### `pihole-compose.yml`

```yaml
version: "3.6"

services:
  cloudflared:
    container_name: cloudflared
    # Restart on crashes and on reboots
    restart: unless-stopped
    image: cloudflare/cloudflared
    command: proxy-dns
    environment:
      - "TUNNEL_DNS_UPSTREAM=https://1.1.1.1/dns-query,https://1.0.0.1/dns-query,https://9.9.9.9/dns-query,https://149.112.112.9/dns-query"

      # Listen on an unprivileged port
      - "TUNNEL_DNS_PORT=5053"

      # Listen on all interfaces
      - "TUNNEL_DNS_ADDRESS=0.0.0.0"

    # Attach cloudflared only to the private network
    networks:
      internal:
        ipv4_address: 172.30.9.2

  pihole:
    container_name: pihole
    restart: unless-stopped
    image: pihole/pihole
    environment:
      - "TZ=Europe/Berlin"
      - "WEBPASSWORD=admin"

      # Internal IP of the cloudflared container
      - "DNS1=172.30.9.2#5053"

      # Explicitly disable a second DNS server, otherwise Pi-hole uses Google
      - "DNS2=no"

    # Persist data and custom configuration to the host's storage
    volumes:
      - '/mnt/app-data/pihole/config:/etc/pihole/'
      - '/mnt/app-data/pihole/dnsmasq:/etc/dnsmasq.d/'

    # 1. Join the internal network so Pi-hole can talk to cloudflared
    # 2. Join the public network so it's reachable by systems on our LAN
    networks:
      internal:
        ipv4_address: 172.30.9.3
      priv_lan:
        ipv4_address: 10.65.2.4

    # Starts cloudflard before Pi-hole
    depends_on:
      - cloudflared

networks:
  # Create the internal network
  internal:
    ipam:
      config:
        - subnet: 172.30.9.0/29

  # The priv_lan network is already setup, so it is an 'external' network
  priv_lan:
    external:
      name: priv_lan
```

Now let's start our services!

```shell
docker-compose -f pihole-compose.yml -p pihole up -d
```

* `-f` specifies a file other than the default, `docker-compose.yml`
* `-p` names our "project" explicitly, otherwise it uses the current direcotyr name
* `-d` detaches after starting

### Testing

We can check the logs to make sure everything looks good:

```shell
docker logs cloudflared
docker logs pihole
```

And query the Pi-hole server

```shell
$ dig mroach.com @10.65.2.4

; <<>> DiG 9.11.5-P4-5.1+deb10u1-Debian <<>> mroach.com @10.65.2.4
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 9707
;; flags: qr rd ra; QUERY: 1, ANSWER: 3, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
;; QUESTION SECTION:
;mroach.com.			IN	A

;; ANSWER SECTION:
mroach.com.		300	IN	A	104.28.15.90
mroach.com.		300	IN	A	172.67.133.162
mroach.com.		300	IN	A	104.28.14.90

;; Query time: 38 msec
;; SERVER: 10.65.2.4#53(10.65.2.4)
;; WHEN: Tue Aug 04 20:29:25 CEST 2020
;; MSG SIZE  rcvd: 117
```

Looks good!


Option 2: Attach cloudflared to the LAN
---------------------------------------

Another option is to skip using the `internal` network and instead directly attach cloudflared to our real network. By doing this, we gain the ability to bypass Pi-hole if desired and still have the benefits of DNS over HTTPS. We also get access to the Prometheus metrics published by cloudflared.

We need to make some changes to the configuration for this setup to work.

### Assign cloudflared an ip

With the `internal` network removed, we need to bring `cloudflared` onto the real network `priv_lan` and assign it the IP address `10.65.2.14`.

### DNS port

If the goal is to make the `cloudflared` DNS service available to the LAN, we want it on the standard port `53`. The problem is the `cloudflare/cloudflared` Docker image doesn't run as root so it won't have permission to bind to a privileged port (i.e. < 1024). We can fix this with a `sysctl` option `net.ipv4.ip_unprivileged_port_start=53`

### Metrics

The Prometheus metrics HTTP server apparently has a default behaviour of randomly generating a port to listen on. This is not helpful, so we can fix that by setting an environment variable `TUNNEL_METRICS=0.0.0.0:49312` to bind to all interfaces on port `49312`.

### `pihole-compose.yml`

Recap of the configuration changes:

* Assign an IP on our `priv_lan` to cloudflared
* Grant cloudflared permission to bind to a privileged port
* Configure cloudflared's Prometheus metrics (optional)
* Point Pi-hole to the new IP of cloudflared
* Remove the `internal` network

```yaml
version: "3.6"

services:
  cloudflared:
    container_name: cloudflared
    restart: unless-stopped
    image: cloudflare/cloudflared
    command: proxy-dns
    environment:
      - "TUNNEL_DNS_UPSTREAM=https://1.1.1.1/dns-query,https://1.0.0.1/dns-query,https://9.9.9.9/dns-query,https://149.112.112.9/dns-query"
      - "TUNNEL_METRICS=0.0.0.0:49312"
      - "TUNNEL_DNS_ADDRESS=0.0.0.0"
      - "TUNNEL_DNS_PORT=53"
    sysctls:
      - net.ipv4.ip_unprivileged_port_start=53
    networks:
      priv_lan:
        ipv4_address: 10.65.2.14

  pihole:
    container_name: pihole
    restart: unless-stopped
    image: pihole/pihole
    environment:
      - "TZ=Europe/Berlin"
      - "DNS1=10.65.2.14#53"
      - "DNS2=no"
      - "WEBPASSWORD=admin"
    volumes:
      - '/mnt/app-data/pihole/config:/etc/pihole/'
      - '/mnt/app-data/pihole/dnsmasq:/etc/dnsmasq.d/'
    networks:
      priv_lan:
        ipv4_address: 10.65.2.4

networks:
  priv_lan:
    external:
      name: priv_lan
```

If you already ran the other `docker-compose up`, tear it down now:

```shell
docker-compose -f pihole-compose.yml down
```

Now we can fire-up the new setup:

```shell
docker-compose -f pihole-compose.yml -p pihole up -d
```

### Testing

Check that DNS still works properly:

```shell
dig mroach.com @10.65.2.4
```

And check that Prometheus metrics are working:

```shell
curl http://10.65.2.14:49312/metrics
```


Next steps
----------

This setup provides a portable Pi-hole with DNS over HTTPS configuration. For higher availability on a LAN, the setup could be deployed to multiple Docker hosts and the IPs of the Pi-hole servers added to the DHCP configuration on the LAN.

### Configuration sync

If any manual configuration is done to Pi-hole, that should probably be shared or synchronised between Pi-hole servers in a way that doesn't add points of failure (e.g. mounted share on a NAS). Deploying configuration with something like [Ansible] could be a good solution.

[Ansible]: https://www.ansible.com

### Blocking rogue DNS

Some software and devices have DNS servers (usually Google's `8.8.8.8`) hardcoded in them. Depending on the type of network, it may be viable to block outbound port `53` at the firewall level to prevent circumvention of Pi-hole. I've had this blocked for years without any problems.

### Adding blocklists

Pi-hole works by subscribing to various blocklists. There may be enhanced blocklists for your country.

You can also add custom blocklist rules. I added some to stop ads showing up on my LG smart TV.


### Joining VLANs

If you use VLANs on your network, `macvlan` supports binding to VLAN tagging. The [macvlan] documentation shows how.


Conclusion
----------

Pi-hole with cloudflared provides a powerful security and privacy enhancement to any network. Setting it up with docker-compose makes the setup portable.

If you love [Pi-hole], consider donating its ongoing development.

[Pi-hole]: https://pi-hole.net
