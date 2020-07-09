---
date: 2019-03-12T00:00:00Z
title: "Reducing Raspberry Pi power consumption"
categories:
  - tech
tags:
  - raspberry-pi
---

{{< figure src="images/rpi-power.png" title="USB Power Meter" >}}

<!--more-->

I'm currently working a project that will put my _Raspberry Pi 3 B_ to work as an
embedded system running primarily on battery power. Naturally one of my goals
became to reduce the power consumption of the Raspberry Pi as much as possible
to make the most of battery life. I saw tips for disabling the activity LEDs,
switching off HDMI, and a few other things, but none seemed to move the needle
at all on power consumption. It still used about **140 mA** (*0.7 W*) at idle.

Then I checked if you could disable the USB hub since I don't need it.
After disabling the USB hub the power consumption dropped to **20 mA** (*0.1 W*).
That's a *huge* power savings.

One caveat with this approach is that it also disables the Ethernet controller.
So if you need wired LAN, don't do this.

The quick way to disable the USB hub:

```shell
echo '1-1' | sudo tee /sys/bus/usb/drivers/usb/unbind
```

This won't persist across reboots, so I wrote a script to do it for me and set
it to run on startup via `/etc/rc.local`. In case I need to do some manual fixes
on the device with a keyboard and/or Ethernet, I have the script check if any
USB devices are plugged-in or if the Ethernet cable is connected. Only if nothing
is connected will it disable the USB hub. So if I need a keyboard, I just plug
it in and power cycle the Pi!

```bash
#!/bin/bash

# With no devices plugged-in, there will only be "devices" at "1" and "1.1"
# If any devices beyond that are detected, such as 1.2, don't disable USB.
cat /sys/bus/usb/devices/**/devpath | grep -Eq '^[1-9]+\.[2-9]'

if [ $? -eq 0 ]; then
  echo "USB devices attached. Aborting."
  exit 1
fi

# Disabling the USB controller also disables Ethernet, so don't do that
# if there's an Ethernet cable plugged-in.
if [ `cat /sys/class/net/eth0/carrier` != "0" ]; then
  echo "Ethernet cable is plugged-in. Aborting."
  exit 2
fi

echo "Disabling USB interface"
echo '1-1' > /sys/bus/usb/drivers/usb/unbind
```
