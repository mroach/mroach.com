---
date: 2019-05-14T00:00:00Z
title: Spec'ing out a Blackbird POWER9
categories:
  - tech
---

{{< figure src="images/blackbird-board.jpg" alt="Raptor Blackbird Board" >}}

Recently I've been intrigued by non-x86 developments in tech. Over the past few
years as [Moore's Law] has been breaking down, each new generation of x86 processors
has been delivering smaller performance gains. Apple is rumoured to be building
ARM-based MacBooks, Amazon is deploying ARM servers, Qualcomm is soon delivering
the Snapdragon 8cx ARM processor for laptops. The performance is fantastic and
power consumption will allow for laptops with all-day battery life. I'm excited.

<!--more-->

While watching a video about ARM-based servers on [Level1Techs], I came across
an [interview with Raptor Systems] about their fully open source POWER9 systems.
Most of the systems are high end server and workstation-grade with a price tag
to match, but soon they'll be shipping relatively lower end barebones kit with
just the motherboard and CPU. I'm tempted to build one. Level1Techs said they'll
be buying one and doing a build, so I'll wait until they do since I'm sure it won't
be as straight-forward or familiar as doing an x86 build. A lot of things we take
for granted or as norms likely won't exist or be the same on another architecture,
most especially the boot and OS install process.

Here's the hardware list I've put together for how I'd build the system:

### [Blackbird 8-Core Bundle]


This includes

* micro-ATX motherboard
* 8-core POWER9 CPU
* Heatsink + Fan

The 4-core bundle is several hundred less, but doesn't include the heatsink which
costs another $110 separately, so may as well go for the larger kit. Plus 8
cores should really shine with compiling code and running Dockerized apps.

Price: **$1,604**

### 16 GB Micron ECC Registered (1xRDIMM)

The type of work I do isn't so memory intensive, so 16 GB is plenty for me to
start with. The motherboard only has slots for 2 RDIMMs, so I want to leave one
free for expansion. It's hard to tell from the docs if POWER9 has any benefit from
going with memory pairs or not. If it does, I'll just go for 32GB.

Price: **$125**

### Samsung 960 EVO Plus NVMe 500 GB

Nothing special here! Standard NVMe should work just fine on the board.

Price: **$125**

**Update**: It was [pointed out to me on Twitter](https://twitter.com/RobinBa40108750/status/1128399031179403265)
that the board doesn't have an M.2 slot for NVMe. Raptor themselves said they can
vouch for the compatibility of this [PCIe to M.2/NGFF adapter](https://twitter.com/RobinBa40108750/status/1128399031179403265)
which is just **$21**.

### Power Supply

The hardware compatibility list published by Raptor currently doesn't have
information on the power supply size you'd need to comfortably run these systems.

I imagine a 550W power supply would be ample especially as I don't do any high-end
graphics. The EVGA Supernova G3 550W is what Id' go with.

Price: **$88**

### Graphics

It seems like most PCIe GPUs work with some small caveats. I have some older
GeForce cards sitting around that I'd try out before spending money.

### Summary

| Component | Price |
| ---------- | ----: |
| [Blackbird 8-Core Bundle] | $1,604 |
| 16 GB RAM | $125 |
| NVMe SSD | $125 |
| PCIe to M.2 adapter | $21 |
| Power Supply | $88 |
| **Total** | **$1,963** |

Spending $2,000 on a fully open source system and piece of computing history
seems like a good deal to me.

[Moore's Law]: https://en.wikipedia.org/wiki/Moore%27s_law
[Level1Techs]: https://www.youtube.com/channel/UC4w1YQAJMWOz4qtxinq55LQ
[interview with Raptor Systems]: https://www.youtube.com/watch?v=o5Ihqg72T3c
[Blackbird 8-Core Bundle]: https://raptorcs.com/content/BK1B02/intro.html
