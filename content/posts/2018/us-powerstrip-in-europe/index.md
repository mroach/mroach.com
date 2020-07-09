---
date: 2018-04-09T00:00:00Z
title: "Power strip mod for US plugs in Europe"
categories:
  - diy
  - mods
tags:
 - electronics
 - plugs
 - international
 - mods
---

{{< figure src="images/uk_shaver_nema.jpg" alt="Chopped-off UK shaver and NEMA plugs" >}}

When I moved to Germany, I brought a bunch of electronics with me that I had acquired in Japan, Thailand, and the US. Fortunately they all had switching power supplies, so the voltage and frequency difference (110v @ 60 Hz vs 220v @ 50 Hz) wasn't an issue. The issue was the plugs themselves, so a solution was required.

<!--more-->

Devices like my Xbox One S and Synology NAS use standard IEC power connectors so I could replace the AC power cords with Europlug and Schuko plugs. But some devices like my Synology wireless access point, Amazon Echo, battery charger, shaver, etc., have the plug built-in which means I'd have to use an adapter. I don't like adapters. They take up space, don't usually make solid connections, and the cost of all the ones I need would add up.

Fortunately there was an easy solution: take a US power strip, cut the plug off, and replace it with a Schuko plug.

## Is that a good idea?

Now one may ask, is this safe? The short answer is: yes! The big safety issue to consider is can the power strip handle the load without melting the wires inside and catching fire. Wire designed to handle 110v and bringing it to a 220v source is safe, but going the other way isn't necessarily. Why? The **lower** the voltage, the **thicker** the cable needs to be.

If you opened up power strips from a 110v country and 220v country that were designed to carry the same load, say 1000W, you'd find the wire for the 220v country to be thinner. That's why load ratings on power strips will usually say something like "1000W at 110v". That also means 2000W at 220v. Strictly speaking then I could take the power strip I got in the US and run twice the load on it here in Europe.

## Picking a power strip

{{< figure src="images/powerstrip.jpg" alt="Powerstrip" >}}

I wanted to find the most basic power strip I could. It was harder than I imagined to find one that didn't have:

1. USB ports
2. Circuit breaker
3. Illuminated power switch or power/ground LED

I assumed all of these things would only work properly with 110v and would break or burn when plugged into 220v. No luck at Home Depot, but ended up finding one at Wal-Mart for $5 that had no fancy stuff at all. Just copper and a switch. It's also nice that it can be wall-mounted.

## Plug conversion

{{< figure src="images/tinning.jpg" alt="Plug wire tinning" >}}

First, I bought a plug. It was €2 at a hardware store. These are designed to easily put a new plug on whatever you want. You only need a screwdriver to clamp down the wires.

I chopped the US plug off the end of the power strip, cut the outer insulation back, and stripped the inner three wires. Each wire is made of many thin copper strands. The best thing to do here is twist them together then use a soldering iron and some solder to **tin** the wire. This just means melting some solder in there so the end of the wire is like a solid piece of metal. This makes it much easier to work with and prevents oxidation.

{{< figure src="images/schuko_inside.jpg" alt="Inside of a Schuko plug" >}}

Then I just opened up the plug and clamped down the wires. Schuko plugs are not polarised, so there's no positive or negative to consider. The only thing you need to get right is the grounding wire. This is easy since it's <span style="color: #0d0">green</span>. And if you want to double check, you can use a multimeter in continuity test mode and stick one end in a grounding hole and the other on the green wire. Voila!

{{< figure src="images/us_eu_plug_harmony.jpg" title="US and EU plugs together in Europe" >}}

Here's the power strip in its current home on the floor. Next step is to mount both power strips, my router, Hue bridge, and cable modem to something. Probably the back of an IKEA shelf or furniture to keep it tidy. But for now, all good! Got my NAS, access point, Xbox One, battery charger, and USB charger in the US power strip and my Hue lights, cable modem, router, and TV in the Schuko power strip. Perfect! This whole thing cost me less than $10 which is far cheaper than buying new equipment and cords. Plus it was my idea of a good time.
