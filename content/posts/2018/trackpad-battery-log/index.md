---
date: 2018-07-31T00:00:00Z
title: "Keeping track of Magic Trackpad 2 battery life"
categories:
  - Tech
tags:
 - Electronics
 - Utilities
 - Scripts
 - macOS
 - Apple
aliases:
  - /2018/07/31/log-magic-trackpad-battery/
---

Fetching the **Magic Trackpad 2** battery level from the command line and logging it to a file!

<!--more-->

I've been curious about the battery life of the Magic Trackpad 2 and roughly how much battery I was using per day. Solution: create a cron job to log it! After some searching and tinkering I found the key was using `system_profiler` to dump the information and then `PlistBuddy` to parse it. Both binaries are included on macOS (at least in High Sierra) so there are no dependencies.

I have this script setup as a cron job to run once per hour to log the timestamp and battery percentage to a file in my home directory. I found that I'm using between 3% and 4% per 8 hour work day. It's brand new so I'm curious to see how this goes over time.

The `system_profile` output doesn't include the number of battery cycles, but as long as this logger keeps running I'll be able to figure that out on my own by crunching though this CSV.

```bash
#!/bin/bash

device="Magic Trackpad 2"
tmpfile="${TMPDIR}sys_bluetooth_$(date +%s).plist"

/usr/sbin/system_profiler -xml SPBluetoothDataType > "$tmpfile"

batt=`/usr/libexec/PlistBuddy "$tmpfile" -c "Print 0:_items:0:device_title:0:'$device':device_batteryPercent"`
status=$?

rm $tmpfile

if [ $status -ne 0 ]; then
  echo "Could not find battery status for $device. Is it connected?"
  exit 1
fi

batt=$(echo $batt | tr -d '%')
ts=$(date +"%F %T")

echo "$ts,$batt" >> ~/mtp.log
```
