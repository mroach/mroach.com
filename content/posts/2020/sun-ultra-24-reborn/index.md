---
title: "Sun Ultra 24 - Rebuilt"
date: 2020-08-01T00:00:00Z
draft: false
categories:
  - Tech
tags:
  - Sun Microsystems
  - System build
  - Noctua
---

When I first saw the Sun Ultra 24 online, I thought it was one of the most beautiful workstations I'd seen. I [got one in 2019]({{< ref "posts/2019/sun-ultra-24" >}}) and have made some use of it since. At this point, the hardware is just too old to be a daily driver. It's high time to upgrade the of this system.

## Background

The Sun Ultra 24 was one of the last workstations Sun Microsystems made. In their final years of making workstations they started offering x86-based systems with AMD Opteron or Intel Core 64-bit CPUs. Compared to UltraSPARC-based hardware of the past, these systems were pretty much bog-standard PCs. ATX motherboards, SATA drives, DVI and DisplayPort.

This starting point made this case exceptionally easy to use as a build base.

## Hardware

I didn't want to build a whole new system from scratch. I've had my gaming PC in a [DAN A4] mini-ITX case. It's cool being able to put your computer in your backpack, but the thermal situation isn't great and making any modifications to the system means a complete disassembly.

I stripped that system for parts and got a few new ones.

### Motherboard

It's hard finding a PC motherboard these days that isn't designed for gamers and isn't hugely expensive. Most boards today have 2 PCI-E 16x slots and then some 1x slots. Aside from a graphics card, I want to install my Mellanox ConnectX-3 NIC for 10 GbE and a SCSI controller, both of which are PCI-E 4x.

My requirements:

* Support my existing CPU, an **Intel Core i5-8400 (Coffee Lake)**
* At least one PCI-E 4x or 8x slot in addition to the standard 2 16x
* Dual M.2 NVMe slots

Nice to have:

* Onboard USB-C
* COM port headers
* No RGB or other gamer-targetted aesthetics.
* PS/2 port for hooking up retro keyboards

I found the perfect board. The [Gigabyte CU246-WU4]. This is marketed as a workstation board, which is perfect. It ticks all the boxes above and then some.

It maintains some of the cool features from Sun Ultra 24 board that are great for debugging and eventually for use as a test bench system:

* 32-bit PCI slot
* Onboard buttons for Power and Reset
* Onboard USB-A port, perfect for booting FreeNAS off a USB stick
* Segment display of boot status and diagnostic codes

It also has support for Xeon CPUs which would be a nice upgrade in the future.

### CPU and RAM

Nothing remarkable here. I took the Core i5-8400 and 2x8GB sticks of DDR4 RAM out of my gaming PC. I may add another 2x16GB sticks in the near future to support my prolific use of virtual machines. The board supports up to 128 GB.

### Cooling

#### CPU

The low-profile cooler from the mini-ITX case was a non-starter. I wanted something slightly over-dimensioned so it would be quiet. I bought a [Noctua NH-U14S] but I went too far with the over-dimensioned idea. It physically fit in the case, but it obstructed the top PCI-E slot. It may have been possible to squeeze a GPU in there but it would have been rubbing up against the cooler. Not good. I went down a size to the [Noctua NH-U12S Chromax].

#### Exhaust

The Ultra 24 had one 120mm exhaust fan. I would have kept it, but on this board it constantly ran at full blast. Despite having 4 wires maybe it's not a proper PWM fan? Another Sun Ultra 24 owner, Nathan Vaughn, reported the same problem with [his build][Nathan Vaughn build].

The rear fan mount is one of those deals where you snap a fan into a plastic holder attached to the case rather than just having holes for screws. Any fan that uses the standard boxy style will snap in just fine.

Noctua has new line of fans called the **Redux** which are a bit less expensive, but more importantly, have a grey colour scheme! Perfect to match this system. For the rear I got the [Noctua NF-S12B redux-1200 PWM]. This fan is optimised for moving large volumes of air versus having high static pressure that'd you would find in the **S12P**.

#### Intake

The system didn't come with an intake fan. In the front it has a space for a 92mm fan and what looks like holes for those plug mounts, probably for another plastic fan mount bracket which I didn't have. I picked up a [Noctua NF-B9 redux-1600 PWM] for this slot. I took some washers, "painted" them black with a permanent marker, and job done! If dust becomes a problem I'll put a screen over it.

{{< figure src="images/intake.jpg" alt="Front intake fan" caption="Front intake fan installed and running. Two of the washers fell under a filing cabinet I'm not moving, so, two are installed." thumb="400" class="center" >}}

### Graphics

The system board has dual DisplayPort outputs which is unique and appreciated. I still do some gaming though, so I moved my GPU into this system, an [EVGA 1660 Ti SC]. It's a good GPU for the games I play. My only complaint about it is the fan controller. It has no hysteresis by default which means you can hear the fan just clicking on and off at idle, and sometimes it has this pulsating sound as the fan revs up and down.

### Power

I'm glad I kept the power supply from the original ATX incarnation of my gaming PC. It's a pretty nice one. [EVGA SuperNOVA 550 G3]. It's *80 Plus Gold* rated and modular, helping make for a clutter-free inside of the case.

Installing it required a bit of force. It was a couple mm off from lining up with the screw holes, and the "eco" switch bumped up against the case. A little bending of metal tabs was required.

{{< figure src="images/psu-back.jpg" alt="PSU installed" caption="PSU Installed" thumb="400" class="center" >}}

### Storage

I'm dual booting the system between Linux and Windows. Windows is for gaming, Linux for everything else. Each OS gets its own [Samsung 970 EVO] M.2 NVMe. 512 GB for Windows, 256 GB for Linux.

One of the most Sun-like features of this system is drive cage with backplane for hot swapping SATA or SAS hard drives. I had two 4 TB drives lying around after my NAS upgrade, so I put them in there. I gave one to Windows for game data overflow (some games are > 100 GB now) and one to Linux for my excessive use of virtual machines and just general junk. Important stuff still goes on the NAS.

{{< figure src="images/hdd-cage.jpg" alt="HDD cage" caption="SATA hard drive cage with 2x 4 TB WD Red drives installed" thumb="400" class="center" >}}

## Front panel

The front panel of the system is a whole board you can remove from the system. It has:

* Power button
* Power LED
* 2x Firewire
* 2x USB
* Headphone and Mic

Using a multimeter for continuity testing I was able to see that the power button is wired up to 3 wires, oddly enough. White, yellow, and black. Black and white appear to both be wired to the same pin and yellow is on its own. So I just picked **yellow** and **white** to be my power buttons.

I traced the LED wires to **blue** and **green**. Not knowing which is positive or negative. I just tried it both ways. Green is positive.

| Colour | Purpose    |
| ------ | ---------  |
| Green  | PWR LED +  |
| Blue   | PWR LED -  |
| Yellow | PWR Switch |
| White  | PWR Switch |

The power button and LED were all together in a block-style connector you see like for USB2 and front-panel audio. Fortunately it's easy to pull the wires out. Then I borrowed some individual connectors from a breadboard kit and re-homed the connectors.

There are some other wires there. I don't know what they do. I couldn't find documentation. I assume grounding and maybe a power source for something?

The **USB** connection is standard and that fit right into my board.

The board doesn't have a **Firewire** header, I don't have a Firewire controller card, and I don't have any Firewire devices. So that remains disconnected.

The **front panel audio** cable is totally standard but is too short for my board. I'll have to make an extension.

{{< figure src="images/fp-wires.jpg" alt="Front panel wires" caption="Disassembled front panel wires with donor female connector insulators from the breadboard wires." thumb="400" class="center" >}}



[Gigabyte CU246-WU4]: https://www.gigabyte.com/eu/Server-Motherboard/C246-WU4-rev-10
[Noctua NH-U14S]: https://noctua.at/en/nh-u14s
[Noctua NH-U12S Chromax]: https://noctua.at/en/nh-u12s-chromax-black
[Noctua NF-S12B redux-1200 PWM]: https://noctua.at/en/nf-s12b-redux-1200-pwm
[Noctua NF-B9 redux-1600 PWM]: https://noctua.at/en/nf-b9-redux-1600-pwm
[EVGA 1660 Ti SC]: https://www.evga.com/products/product.aspx?pn=06G-P4-1665-KR
[EVGA SuperNOVA 550 G3]: https://www.evga.com/products/product.aspx?pn=220-G3-0550-Y1
[Samsung 970 EVO]: https://www.samsung.com/semiconductor/minisite/ssd/product/consumer/970evo/
[DAN A4]: https://www.dan-cases.com/dana4.php
[Nathan Vaughn build]: https://blog.nathanv.me/posts/sun-ultra-24-build/