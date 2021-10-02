---
title: "Changing Brother MFC Language"
date: 2021-10-02T14:50:19+02:00
draft: false
categories:
  - tech
tags:
  - Brother MFC-L2710DW
  - Reference
thumbnail: /2021/10/changing-brother-mfc-language/images/english.jpg
images:
  - /2021/10/changing-brother-mfc-language/images/english.jpg
---

I bought a **Brother MFC-L2710DW** multi-function laser printer and scanner. I bought it in Germany.
When I turned on the machine for the first time it asked me to pick my country. The only options were Germany and Austria.

<!--more-->

There was no option to change the language on the LCD panel away from German.
I guessed that the firmware was region-specific and I would have to load a different one.
Turns out I was wrong, but more on that later.

After much searching and I came across [a thread on printerforums.net](https://www.printerforums.net/threads/mfc-l2710dw-bricked-sort-of.68064/) which led me to
the solution: **Maintenance mode**.

I wanted to summarise the solution and include the region codes for reference.

### Procedure

1. Wake up the machine by pressing the <kbd>Stop</kbd> button.
2. Press: <kbd>Menu</kbd>, <kbd>Start</kbd>, <kbd>Up</kbd>, <kbd>Up</kbd>, <kbd>Up</kbd>, <kbd>Up</kbd>
   (or in icon speak: <kbd>🛠</kbd> <kbd>Start</kbd> <kbd>🠱</kbd><kbd>🠱</kbd><kbd>🠱</kbd><kbd>🠱</kbd>).
1. Now your machine should say **MAINTENANCE**.
2. Press <kbd>7</kbd><kbd>4</kbd> and then the existing code is displayed.
3. Enter the new code (see below).
4. Press <kbd>Start</kbd> to accept the change. **PARAMETER INIT** briefly displays.
5. Press <kbd>9</kbd><kbd>9</kbd> to apply changes and restart the machine.

If you accidentally erase the **A**, you can re-enter it using <kbd>#</kbd><kbd>1</kbd>.

{{< inline_items >}}
  {{< figure src="images/german.jpg" caption="Before" thumb="400" alt="LCD in German" >}}
  {{< figure src="images/english.jpg" caption="After" thumb="400" alt="LCD in English" >}}
{{< /inline_items >}}

### Codes

Region codes for the **MFC-L2710DW** only. Each machine model has its own
region codes. See the [archive on manualslib][codes] for other models.

{{<div "table table-slim">}}
| Country/Region | Code |
| ------         | ---- |
| Argentina      | 0A36 |
| Australia      | 0A06 |
| Austria        | 0A14 |
| Belgium        | 0A08 |
| Brazil         | 0A42 |
| Canada         | 0A02 |
| Chile          | 0A36 |
| Denmark        | 0A13 |
| Finland        | 0A12 |
| France         | 0A05 |
| German*        | 0A53 |
| Germany        | 0A03 |
| Iberia*        | 0A65 |
| Israel         | 0A17 |
| Mexico         | 0A46 |
| Netherlands    | 0A09 |
| Nordic*        | 0A57 |
| Portugal       | 0A18 |
| Spain          | 0A15 |
| Sweden         | 0A07 |
| Switzerland    | 0A10 |
| United Kingdom | 0A04 |
| United States  | 0A01 |
{{</div>}}

\* Picking this will prompt you for a more specific country when the machine resets.

## Dead end: changing the firmware

As mentioned, my first thought was that the firmware on the machine was region-specific
and I'd have to download one and shoe-horn it onto the printer.

I setup [mitmproxy] including trusting its SSL root certificate on my machine
that was running the Brother Firmware Updater. This allowed me to inspect the
traffic to their update server.

I was hoping there would be some obvious region marker in the request for the firmware
update or in the filename, such as `DE` for Germany. There was nothing obvious.

It was at this point I searched around more and found the proper solution above.
In case it's interesting for someone, I wanted to preserve my findings from the
firmware updater.

These are what the captured streams looked like:

```
POST https://firmverup.brother.co.jp/kne_bh7_update_nt_ssl/ifax2.asmx/verCheck
accept:           */*
content-type:     application/x-www-form-urlencoded
accept-encoding:  gzip;q=1.0, compress;q=0.5
user-agent:       Brother Firmware Update Tool/1.0 (jp.ne.rio.FirmwareUpdateTool; build:1; OS X 10.16.0) Alamofire/4.8.2
accept-language:  en-GB;q=1.0
content-length:   362

<?xml version="1.0" encoding="UTF-8"?>
<REQUESTINFO>
    <FIRMUPDATETOOLINFO>
        <FIRMCATEGORY>MAIN</FIRMCATEGORY>
        <OS>MAC_10.10</OS>
        <AREA>ALL</AREA>
        <INSPECTMODE>null</INSPECTMODE>
    </FIRMUPDATETOOLINFO>
    <FIRMUPDATEINFO>
        <MODELINFO>
            <NAME></NAME>
        </MODELINFO>
    </FIRMUPDATEINFO>
</REQUESTINFO>
```

This request then repeated again with `<NAME>MFC-L2710DW series</NAME>`.

Both times, the API responded with a list of every available model.

Next, the tool sent information about the device and received a response with a
firmware update file download URL:

```
POST https://firmverup.brother.co.jp/kne_bh7_update_nt_ssl/ifax2.asmx/fileUpdate
accept:           */*
content-type:     application/x-www-form-urlencoded
accept-encoding:  gzip;q=1.0, compress;q=0.5
user-agent:       Brother Firmware Update Tool/1.0 (jp.ne.rio.FirmwareUpdateTool; build:1; OS X 10.16.0) Alamofire/4.8.2
accept-language:  en-GB;q=1.0
content-length:   803

<?xml version="1.0" encoding="UTF-8"?>
<REQUESTINFO>
    <FIRMUPDATETOOLINFO>
        <FIRMCATEGORY>MAIN</FIRMCATEGORY>
        <OS>MAC_10.10</OS>
        <OSVERSION>10.16</OSVERSION>
        <INSPECTMODE>null</INSPECTMODE>
    </FIRMUPDATETOOLINFO>
    <FIRMUPDATEINFO>
        <MODELINFO>
            <SELIALNO>E78295G1N405094</SELIALNO>
            <NAME>MFC-L2710DW series</NAME>
            <SPEC>0A03</SPEC>
            <DRIVER>MFC-L2710DW series</DRIVER>
            <FIRMINFO><FIRM>
    <ID>MAIN</ID>
    <VERSION>U2104191922</VERSION>
</FIRM><FIRM>
    <ID>SUB5</ID>
    <VERSION>1.04</VERSION>
</FIRM></FIRMINFO>
        </MODELINFO>
        <DRIVERCNT>1</DRIVERCNT>
        <LOGNO>2</LOGNO>
        <ERRBIT></ERRBIT>
        <NEEDRESPONSE>1</NEEDRESPONSE>
    </FIRMUPDATEINFO>
</REQUESTINFO>
```

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<RESPONSEINFO>
  <FIRMUPDATEINFO>
    <VERSIONCHECK>0</VERSIONCHECK>
    <MEMORYVERSION>a</MEMORYVERSION>
    <FIRMID>MAIN</FIRMID>
    <LATESTVERSION>V2106151824</LATESTVERSION>
    <PATH>http://update-akamai.brother.co.jp/CS/D00L6U_V.djf</PATH>
    <DLTIME>65000</DLTIME>
  </FIRMUPDATEINFO>
</RESPONSEINFO>
```

With the benefit of hindsight I realise that the `<SPEC>0A03</SPEC>` value
was telling the server what region my device was. I tried re-running this request
with the UK region code `0A04` which responded with the same update file path,
strongly suggesting that the firmware is the same for all (or most) regions.

The firmware file name led me to a [list of all Brother firmware files](https://archive.is/kvO6S) on the Brother Germany website.

[mitmproxy]: https://mitmproxy.org/
[codes]: https://www.manualslib.com/manual/1582425/Brother-Dcp-7090.html?page=321#manual
