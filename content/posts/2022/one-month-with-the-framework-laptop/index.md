---
title: "First month with the Framework laptop"
date: 2022-01-18T09:08:00+07:00
categories:
  - Laptop
  - PC
tags:
  - Framework
  - Laptop
  - Linux
thumbnail: /2022/01/first-month-with-the-framework-laptop/images/laptop-counter.jpg
images:
  - /2022/01/first-month-with-the-framework-laptop/images/laptop-counter.jpg
---

A month ago I received my [Framework Laptop DIY Edition]. Since I first heard about this laptop,
I was eager to try it out as a Linux daily driver and to support the Framework effort to create
a repairable and upgradable laptop. I know buying into the first generation of a new product
is a gamble and there could be issues, but I dived in nonetheless.

<!--more-->

Installing the RAM and NVMe SSD were a piece of cake. The Wi-Fi card antennae were a bit tricky but I managed.
Installing the expansion cards is trivial. I got 2x USB-C, 1x USB-A, and 1x HDMI.

I had been daily-driving [Pop!_OS] on my desktop workstation for over a year and
had no issues with it, so I chose to install that.

{{< figure src="images/laptop-counter.jpg" alt="Framework laptop on the kitchen counter" class="center" thumb="800" >}}

### Hardware support

Out of the box, all the hardware worked except for the fingerprint reader which is a known issue in
many current distros that need to update [libfprint].

### Display

The display in the laptop is a 3:2 ratio 2256x1504 panel in 13.5".
With such a high DPI, it's a good candidate for fractional screen scaling, so I went
with 125% so that everything is easy enough to read. Fortunate Pop!_OS has a nice easy
GUI to configure this right out of the box and it works pretty well.

## The problems begin

### Pop!_OS upgrade

A few days after I installed the base OS, Pop!_OS released a major update.
I ran the update...and it hung. I can't remember the exact place where it hung,
but the process was un-killable and doing nothing. I rebooted and tried again, except
now apt was in a broken state. I tried to fix it to no avail. My system was in a half-upgraded
state. It was working, but stuck. I did see some HTTP 500 errors from Pop's apt service
which was probably the root cause of things starting to go wrong.

I decided this just isn't ok for a work laptop.

I had read that [Fedora] maintainers had put a fair bit of effort into getting it working
smoothly on the Framework laptop specifically, and that in general, Fedora has put
quite a bit of effort into making system upgrades safe so they can't end up in a botched
state like my Pop!_OS upgrade.

So after just a few days, I distro-hopped onto Fedora 35.

### Fedora issues

{{< figure src="images/neofetch.png" alt="neofetch output" class="center" >}}

The install was easy. Up and running quickly with all hardware working (mostly).

Fedora doesn't have fractional scaling enabled by default, so I force-enabled it.
It turns out they don't have it on for a good reason: out of the box, Fedora uses [Wayland] instead of X,
and Wayland support for fractional scaling is bad. In addition, not all apps support Wayland,
most notably web browsers masquerading as desktop applications (i.e. Electron) such as Slack,
so they run in XWayland which seems to compound the fractional scaling issues.

You can easily run X instead of Wayland, but then gestures are broken. I'm sure it's fixable,
but I don't want my work computer being that much of an administration project.

Ultimately I had to give up on fractional scaling, run at 100%, and increase font sizes where needed.

As for the asterisk up top. The fingerprint reader is detected and available, but
trying to enroll my finger doesn't work.

{{< figure src="images/broken-fingerprint-enroll.png" alt="Broken fingerprint enrollment" class="center" >}}

After this screen, I see an error:

> Failed to claim fingerprint device Goodix MOC Fingerprint Sensor: the device is already claimed by another process.

This sounds like a software issue to me and hopefully it gets fixed.

### Hardware issues

Unfortunately that wasn't the end of the issues.

I noticed that the battery was draining significantly in sleep mode. We're talking 50% loss overnight.

There are some long threads on the [Framework Community] forum about deep sleep issues especially on
Linux owing to the removal of S3idle in Tiger Lake (Intel 11th gen) and its replacement
sleep mode not being well-supported on Linux or on Windows.

That issue is somewhat mitigates by a Linux boot argument so that you can get deep sleep enabled:
```
$ cat /sys/power/mem_sleep 
s2idle [deep]
```

#### Expansion cards

Unfortunately, the problem is even worse than that. In another thread, users figured out an even bigger
cause of battery drain: expansion cards.

The expansion ports themselves are just USB-C, so all expansion cards except for
USB-C are actually USB-C adapters to something else. The problem here is that they
are *always* drawing power. So whether the laptop is on or in sleep mode, my USB-A and
HDMI ports were drawing significant power. One user calculated about 1W!

My sad mitigation has been to remove those two expansion cards and use my old MacBook-era
USB-C to HDMI+USB+Ethernet adapter when I need it.

{{< figure src="images/expansion-cards.jpg" caption="The expansion cards now sit in my travel case of cables and adapters. Sad." class="center" thumb="800" >}}

I'm hoping that Framework will release updated versions of the expansion cards that work around this issue.
One solution I can think of is a hardware switch inside the ports so that the port only activates
when a cable is plugged-in.

A solution for suspend mode might be a BIOS option to disable power draw on USB ports while
the laptop is sleeping. I'm not sure if this is a thing with USB-C, but it definitely was on
computers with USB-A ports.

This is by far the most disheartening problem since the expansion slots are a unique and exciting
feature of this laptop: getting to customise the ports as you like. If there's no long-term fix for this,
then the feature is essentially worthless and we're back to only USB-C ports and dongles.

## Quick hardware review

### Keyboard

I like it. My previous laptop was a 2017 MacBook Pro with the chicklet keyboard that I disliked quite a lot.
This one has nice actuation pressure, a nice snap to the keys, good travel, and is pretty quiet. The layout is normal
and you can even swap the left control and Fn keys in the BIOS if you're so inclined.

### Speakers

They're bad. Some reviews said they're average for a PC laptop, which is perhaps an indictment
of most PC laptop speakers. Coming from a MacBook, these downward-firing speakers are just bad.
Even at max volume, you'll struggle to enjoy a video.

This isn't a huge problem for me as I'm not often watching videos on the road, but it's a clear area for improvement.

### Battery life

In addition to the problems noted above, I'd say the battery life is...meh. I haven't done any
benchmarks, but I'd say doing my normal workload I get 4 or 5 hours.

Again, not a huge problem for me as I'm not often working long sessions on battery.

### Cooling

I notice the fans ramp-up when watching high-res (1440p and 4K) YouTube videos full-screen. This is unfortunate.

Aside from that, doing my normal work, I don't hear the fans at all and the laptop doesn't get too hot.

### Display

Nice! I like the 3:2 aspect ratio for my coding work and the high resolution is most welcomed.
After using it at 100% resolution for a couple weeks, I've got used to it and the screen real estate is nice.

The colours seem perfectly good to me, and I'm a bit of a display snob having only ever owned IPS displays.

### Trackpad

Quite good. Physically it's nice to touch and my fingers don't stick to it or slide around excessively.
It reminds me a lot of the MacBook Pro trackpad which is high praise.

The only thing I notice, and maybe this is a software thing, is it can be quite fickle
when you want slow, high-precision movements, like when you want to move the cursor to an
exact location on the screen, it might not register that you're trying to move it, and then it jumps.
This is a minor issue and I've only bumped on that a couple times.

### Portability

Coming from a 15" MacBook Pro, this is *so* much lighter. It weighs 500g less which makes an appreciable
difference when carrying it around in my backpack.

There is some screen flex which does give me a bit of concern for putting it in heavy carryon bags.
It has survived 5 flights so far in my backpack, but not yet in my big carryon. I may have to get
a small messenger bag for it to avoid doing that. I don't trust it, and I've seen some broken displays
on the community forum already.

## What I miss from the MacBook

Not a lot. I miss a few of the features of the Apple ecosystem, but of course I knew that coming in.

* AirPods Pro integration. It was nice being able to use them seamlessly between my phone and laptop.
  Now I need a second pair of headphones for use with the Framework.
* iMessage. It was handy being able to reply to messages on my laptop.
* AirPlay. Being able to easily share a video using [Beamer] is missed.
* AirDrop. Conveniently transferring files from an iPhone to the computer.

These are all pretty minor and don't get in my way enough for me to want to deal with the litany
of drawbacks of macOS.

In terms of hardware, there's nothing I miss about the 2017 MacBook Pro.

## Conclusion

I originally bought the Framework laptop for a two main reasons:

* Daily-drive Linux on my laptop
* Support Framework's mission to create repairable and upgradable laptops

I can say both of these goals have been satisfied. Despite the issues, on a day to day basis,
I'm productive with the laptop and I don't have any serious problems that get in my way of my job
which is what's important. I can get work done.

Now, as an experienced Linux user and hardware tinkerer and someone who went in eyes wide open to
purchase a first generation product from a new company, my threshold for these kinds of problems
is reasonably high. I think that puts me in the target market for daily driving Linux on this particular laptop.

At this time I wouldn't recommend the laptop as a Linux daily driver unless someone were
willing to do some troubleshooting and accept that this is a first revision product with some issues.

Longer term, I'm looking forward to seeing what Framework comes up with next, see improved power
management in Linux and in hardware, and see how the upgradeability promise gets fulfilled.

[Framework Laptop DIY Edition]: https://frame.work/products/laptop-diy-edition
[Pop!_OS]: https://pop.system76.com/
[libfprint]: https://fprint.freedesktop.org/
[Fedora]: https://getfedora.org/
[Wayland]: https://wayland.freedesktop.org/
[Framework Community]: https://community.frame.work/
[Beamer]: https://beamer-app.com/
