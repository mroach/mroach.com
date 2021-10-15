---
title: "Sega Dreamcast Modernisation"
date: 2021-10-08T16:10:59+02:00
draft: false
---

## Shopping for a console

Shopping for a console on eBay was more difficult than anticipated since many
auctions were bundles with accessories and games that I didn't need or want.

Also, the plastic in the Dreamcast suffers from yellowing and as a result many
auctions had severely yellowed consoles. I was not in the mood for retrobrite.

Lastly, and most importantly, only a **VA1** console is compatible with the GDemu mod.
Fortunately it's easy to identify by spotting a **①** on the underside label next
to the **PAL** or **NTSC** indicator. (This method does not work for NTSC-J consoles).

I got lucky and found a console listed as "parts only" because the disc drive
was broken. Since I intended on ripping-out the disc drive anyway, this was perfect.

## CMOS battery replacement

The Dreamcast CMOS battery is a *rechargeable* 2032 coin cell. Like all rechargeable
batteries though, it eventually dies completely and can no longer hold a charge
and by these days, all original Dreamcast CMOS batteries are long dead.

The original battery is soldered onto the controller board. Fortunately it uses
a standard 3-pin PCB mount so it's easy to de-solder and replace.

I replaced mine with a battery *holder* so that from now on it will be easy to
replace the battery when it dies completely.

Following the advice on the [Dreamcast Wiki](https://dreamcast.wiki/Battery_replacement), I replaced it with an **ML2032** coin cell rather than a
**LIR2032** so that the voltage is correct.

## Power supply - 12V removal

The Dreamcast power supply was designed to have the GD-ROM drive present and
putting a load on the 12V rail. Without the drive's load, the power supply
heats up quite significantly. There are generally three solutions to this:

1. Replace the power supply with something like *PicoPSU* or *DreamPSU*
2. Add resistors to the 12V rail
3. Disable the 12V rail

During my search for *PicoPSU vs DreamPSU* I came across [this analysis on RetroRGB].
The takeaway was: the *DreamPSU* doesn't perform as well as the original especially
under load. PicoPSU was better, but that nothing beats the original.

The resistor solution looks pretty janky and generates heat itself, so I went
with the 12V removal option. I found [this post on Reddit] showing how to do it
for the PAL version. I just had to de-solder a regulator and resistor. Easy.

## Fan replacement

The original fans in many consoles get quite loud with age. Fortunately there's
a 3D-printable design of a bracket so you can fit a Noctua 40mm fan in the system.

The Noctua 5V fan doesn't draw enough power from the Dreamcast, to the point where
the system will think the fan isn't working and shut itself down to prevent overheating.

This is relatively easy to fix by soldering a 10KΩ resistor across the 5V and signal lines.
This post is great for reference: [Sega Dreamcast Noctua Fan Mod - raskulous.com].

[this analysis on RetroRGB]: https://www.retrorgb.com/dreamcast-replacement-psu-design-analysed.html
[this post on Reddit]: https://www.reddit.com/r/dreamcast/comments/461ohk/how_to_remove_12v_from_dreamcast_for_gdemu_and/
[Sega Dreamcast Noctua Fan Mod - raskulous.com]: https://raskulous.com/2021/05/sega-dreamcast-noctua-fan-mod/

## GDEMU

By far the easiest mod to install is the GDEMU itself. It's a drop-in replacement
for the GD-ROM drive. Remove the 3 screws securing the GD-ROM drive and just pop
the GDEMU right down on the interface. Done.

To make the SD card slot more accessible and make the inside prettier, I got one
one of the mounts/brackets to fill the hole left by the GD-ROM drive.


## Shopping list

{{<div "table table-slim">}}
| Item                         | Price |
| ---------------------------- | ----: |
| Sega Dreamcast PAL console   |   €45 |
| Dreamcast controller         |   €23 |
| Dreamcast VGA cable          |   €12 |
| GDEMU                        |   €47 |
| GDEMU bracket                |   €15 |
| SanDisk 32 GB SD card        |    €7 |
| Fan mod mount                |   €18 |
| Noctua fan (NF-A4X10-FLX 5V) |   €15 |
| Battery holder + ML2032      |    €9 |
{{</div>}}
