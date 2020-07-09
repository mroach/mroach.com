---
date: 2019-09-16T00:00:00Z
title: Sun Ultra 24
categories:
  - tech
tags:
  - sun microsystems
draft: false
aliases:
  - /2019/09/16/sun-ultra-24/
---

My favourite workstation is the Ultra 24 by Sun Microsystems.

{{< figure src="images/sun_ultra_24.jpg" alt="Sun Ultra 24" >}}

<!--more-->

It's hard to pinpoint when I started having such an interest in Sun Microsystems.
It certainly wasn't when they still existed. Back then I was surely aware of their
existence but I never put much thought into them. They were just that big
company that made big expensive enterprise UNIX systems and the creator of Java.
Their systems were expensive and didn't run games played or any software I
used, so they basically didn't exist to me.

Recently I started taking an interest in their history and started appreciating
their contribution to computer technology. As the company was sadly purchased
by Oracle and essentially stripped down to its patents, I wanted to own at
least one piece of Sun hardware while it's still not too hard to acquire.

As I searched I came across a beautiful piece of hardware: the Sun Ultra 24.
By some measures it's not a "real" Sun system since it's x86-based, but
there is still plenty about this system that is uniquely Sun.

The main specs are:


| |  |
| ---- | ---- |
| Processor | Intel Core 2 Quad Q9300 @ 2.5 GHz |
| Memory | 8GB DDR2 |
| Storage | 512GB Samsung 840 Pro SSD |
| Graphics | NVIDIA Quadro FX580 |
| Storage | Samsung 840 Pro SSD |


I left most of the system hardware as-is and just made a couple changes.

### Storage

The system came with a 250 GB SATA HDD. This was an original part as it is
Sun-branded. I installed a Samsung 840 Pro SSD I had going spare. The system
uses hot-swap drive trays and expects 3.5" drives, not 2.5" like an SSD.
I bought an adapter that was designed for hot-swapping which means the power
and data plugs are in the same place as a larger 3.5" drive so they line up
with the backplane correctly.

## Graphics

The system a came with NVIDIA Quadro FX370. A fine card, but it only had DVI
connections and my Dell U2715H doesn't have DVI input. The display is 2560x1440
which wouldn't work with a passive DVI to HDMI adapter. The Ultra 24 was
configurable with a number of cards in its day. One such card is the Quadro FX580
which has DVI and DisplayPort. I found one for a reasonable price on eBay.

## Device Listing

```plain
System:    Host: sun-ultra Kernel: 5.2.0-2-amd64 x86_64 bits: 64 compiler: gcc v: 8.3.0 Desktop: Xfce 4.14.1
           Distro: Debian GNU/Linux bullseye/sid
Machine:   Type: Portable System: Sun Microsystems product: Ultra 24 v: 0.00.01
           Mobo: Sun Microsystems model: Ultra 24 v: 50, BIOS: American Megatrends v: 1.50
           date: 09/04/2008
CPU:       Topology: Quad Core model: Intel Core2 Quad Q9300 bits: 64 type: MCP arch: Penryn rev: 7 L2 cache: 3072 KiB
           flags: lm nx pae sse sse2 sse3 sse4_1 ssse3 vmx bogomips: 20000
           Speed: 2013 MHz min/max: 2003/2499 MHz Core speeds (MHz): 1: 2000 2: 2000 3: 2000 4: 2000
Graphics:  Device-1: NVIDIA G96CGL [Quadro FX 580] driver: nouveau v: kernel bus ID: 02:00.0
           Display: x11 server: X.Org 1.20.4 driver: modesetting unloaded: fbdev,vesa
           resolution: 1280x1024~60Hz, 2560x1440~60Hz
           OpenGL: renderer: NV96 v: 3.3 Mesa 19.1.4 direct render: Yes
Audio:     Device-1: Intel 82801I HD Audio vendor: Oracle/SUN driver: snd_hda_intel v: kernel bus ID: 0:1b.0
           Sound Server: ALSA v: k5.2.0-2-amd64
Network:   Device-1: Intel 82566DM-2 Gigabit Network vendor: Oracle/SUN driver: e1000e v: 3.2.6-k port: dc00 bus ID: 00:19.0
           IF: enp0s25 state: up speed: 1000 Mbps duplex
Drives:    Local Storage: total: 709.82 GiB used: 24.70 GiB (3.5%)
           ID-1: /dev/sda vendor: Samsung model: SSD 840 PRO Series size: 476.94 GiB
           ID-2: /dev/sdb vendor: Seagate model: ST32500NSSUN250G 0833B8648F size: 232.88 GiB temp: 37 C
Partition: ID-1: / size: 186.17 GiB used: 24.70 GiB (13.3%) fs: xfs dev: /dev/sda1
Sensors:   System Temperatures: cpu: 44.0 C mobo: N/A gpu: nouveau temp: 55 C
           Fan Speeds (RPM): N/A gpu: nouveau fan: 0
Info:      Processes: 198 Uptime: 1d 5h 15m Memory: 7.73 GiB used: 3.24 GiB (41.9%) Init: systemd runlevel: 5 Compilers:
           gcc: 9.2.1 Shell: fish v: 3.0.2 inxi: 3.0.36
```

## Use

For a 12 year old system, it's quite capable as a development system. I'm
running Debian, Xfce, Docker, Sublime Text, and doing Elixir development.
There are certain operations that feel a little sluggish like large compilations,
or visiting websites crushed under the weight of JavaScript, but in general
it's a great system.

Since the system has a few PCI slots, it's also handy for working with older
hardware like a PCI SCSI controller.

## BIOS Update

It took a while of searching, but I got my hands on the latest BIOS update,
provided on the *Sun Ultra 24 Workstation Tools and Drivers* DVD. This was harder
to find than expected since Oracle now makes you sign up for a paid support
contract to download it.

I uploaded it to archive.org so it may live on forever:

[Sun Ultra 24 Workstation Tools and Drivers v1.6 DVD](https://archive.org/details/tools_and_drivers-1.6.0-Sun_Ultra_24)

## Future

Eventually the dated hardware will no longer be useful. I love the case, and
since it's ATX, the upgrade options are plentiful. I'm considering building
[Raptor Blackbird POWER9]({% post_url 2019-05-14-blackbird-power9 %}) workstation
and I'd do that in this case. Since the firmware is open, you can easily
customise things like the boot logo so I could even make it look similar!
