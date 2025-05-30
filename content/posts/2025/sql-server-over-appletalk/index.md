---
title: "SQL Server over AppleTalk"
date: 2025-04-17T14:01:35+02:00
categories:
  - Tech
tags:
  - SQL Server
  - Windows 2000
  - Windows NT
  - AppleTalk
  - GlobalTalk
  - Homelab
  - Wireshark
thumbnail: /2025/04/sql-server-over-appletalk/images/sql-network-appletalk.png
images:
  - /2025/04/sql-server-over-appletalk/images/sql-network-appletalk.png-
---

If you're looking for an instruction guide to *successfully* connect to
SQL Server from a Mac using AppleTalk, I'm afraid this isn't it. This is
documentation of efforts made to get it to work and the dead-end result.

<!--more-->

## Origin

{{< figure
    src="images/sql-server-2000-installer.png"
    alt="SQL Server 2000 installer with the option for AppleTalk ADSP"
    class="float-right"
    thumb="300"
>}}

I was installing SQL Server 2000 and I noticed an option that I hadn't noticed
before, despite having installed SQL Server dozens of times before: **AppleTalk ADSP**.

Maybe it's because I had just watched another [MARCHintosh] go by on Mastodon
where users have established a global AppleTalk network called **GlobalTalk**
to share files, printers, and whatever else.
I don't have any classic Macs, so I haven't joined in yet.

I was aware that Windows NT had some degree of support for AppleTalk, but I never
looked into it much since I didn't have Macs to test it out with.

At any rate, this was exciting, and now I had a reason to try to get onto GlobalTalk!

## Router

One of the bumps for me was not having a Mac to act as an *AppleTalk Internet Router*.
There are good disk images for QEMU out there for emulating MacOS 8 to act
as an AIR, but I didn't give it a serious try.

I heard about [jrouter] on Mastodon which is an implementation of AIR written in
Go, so it can easily be run on Linux. Setting that up is a piece of cake and it works well.
That's the router problem sorted!

## Windows and SQL Server Setup

Setting-up AppleTalk on Windows is a fairly easy, especially if an AppleTalk Zone
is already setup on your network. If you haven't setup AppleTalk yet, check out
[Windows 2000 and AppleTalk](/2025/04/windows-2000-and-appletalk).

AppleTalk is supported natively by:

* Windows NT 3.1 Advanced Server
* Windows NT 3.51 (All Editions)
* Windows NT 4.0 (All Editions)
* Windows 2000*
* Windows Server 2003

\* Windows 2000 Professional can't be a Zone router or seed a new Zone.

SQL Server support for AppleTalk is limited to:
* SQL Server 6.0
* SQL Server 6.5
* SQL Server 7.0
* SQL Server 2000

During the setup for all these versions of SQL Server you're given the option
to enable AppleTalk support and set a service/device name which defaults to
the hostname. For the sake of debugging, I found it easier to set this to
a unique name. For example my hostname might be `SQL1` but the AppleTalk
name would be `SQL2000` to indicate it's the SQL Server 2000 instance.

Having distinct DNS and AppleTalk names allows quick debugging with `isql`.
If it connects using the AppleTalk name, then it's working.

SQL Server 7 and 2000 can tell you what protocol your session is with the query:

```sql
select net_library from sysprocesses where spid = @@spid
```

SQL Server 7 will tell you the DLL name instead.
`SSMSSO70.DLL` is TCP/IP and `SSMSAD70.DLL` is AppleTalk.

{{< figure
    src="images/isql.png"
    alt="Screenshot of the isql utility connecting over AppleTalk and TCP/IP"
>}}

From a machine running SQL Server 2000, I was able to use `isql` to connect to
SQL Server 6.0 and 2000 over AppleTalk, but not 7.0. I never figured out why.

### Reconfigure

You can change AppleTalk settings after installation. The only settings are
whether or not it's enabled and the AppleTalk object name

#### SQL Server 7 and 2000

Open **Start > Programs > Microsoft SQL Server > Server Network Utility**

You can select **AppleTalk** and click **Properties** to change the object name


{{< figure
    src="images/sql-network-appletalk.png"
    alt="SQL Server Network Utility"
>}}


#### SQL Server 6.5

* **Start > Programs > SQL Server 6.0 > Setup**
* Click **Continue** twice
* Select **Change Network Support**, and **Continue** through the menus to reconfigure


## Connecting from a Mac

This is where things stop going so smoothly. Now, the only client I've tried
is **Office 98** on **MacOS 9.2**. This is the only version of Office for Mac
that ships with an ODBC driver. The documentation for Office 2001 even says
you should install the ODBC driver from Office 98 if you need it.

After installing Office 98 you can open up **Microsoft Query** from the Office folder.

The button in the upper left allows you to create a new query which will
prompt you to create a new data source, as in connection to a server.

The driver to pick is the **ODBC SQL Server Driver PPC**.

{{< figure src="images/odbc-setup-1.png" >}}

Next to the **Server** input there's a selection menu. If AppleTalk is working
properly you'll see your SQL Server instances here! This is where I got prematurely
excited thinking it was going to work.

{{< figure src="images/odbc-setup-2.png" >}}

Nope. Trying to pick a **Database** or clicking **OK** fail every time with this error.

```
SQLState: '08001'
MS SQL Server Error: -1
[Visigenic][ODBC MS SQL Server 6 Driver] Unable to connect to data source
```

{{< figure src="images/odbc-setup-3.png" >}}

I banged my head against the wall for *hours*. I setup new SQL instances,
tried using different computers as the AppleTalk router and nothing changed.

## Broken ODBC Driver?

Something I should have done much earlier on was get a look at what was actually
happening on the network with Wireshark. Of course that revealed the problem immediately.

Here's the capture log of what happened as I clicked the **Server** dropdown to
search for servers and then tried to connect.

{{< figure src="images/wireshark.png" >}}

You may see the problem already.

First the grey-coloured log lines: those are AppleTalk activity to `GetLocalZones` and discover the servers.

But then all those blue lines? That's TCP/IP. It's trying to resolve an IP address
based on the AppleTalk name using DNS. That doesn't make any sense.

To verify, I added a `CNAME` for my server e.g. `sql60 CNAME ntsrv2.rlab.mroach.com`
and boom, it connected and worked immediately. But according to Wireshark, this
was all happening over TCP/IP which is not the point of this and that
would never work for anyone on GlobalTalk trying to connect to my server.

I tried disabling TCP/IP connectivity entirely on my SQL Server but this just
resulted in TCP errors in Wireshark. The driver really wants to use TCP/IP.

Unless I'm really missing something big here, I can only conclude that this driver is broken.

I searched the internet far and wide for an ODBC driver for MacOS that supports AppleTalk,
but no luck.

## Results

I was only able to connect to SQL Server 6.0 over TCP/IP from the Mac. None of the other server versions worked.
This isn't too surprising given that the error message says it's a driver for SQL Server 6.

Over the network, SQL Server speaks TDS: Tabular Data Stream. New versions of
TDS coincide with each release of SQL Server. SQL 7 got a pretty major overhaul
to the point where the management tools for it can't even connect to SQL 6.

So the funny thing then is that Windows can speak to SQL Server over AppleTalk just fine,
but there's no software I've found for MacOS that can do it. I hope there is some out there.

[MARCHintosh]: https://www.marchintosh.com/
[jrouter]: https://gitea.drjosh.dev/josh/jrouter
[Windows 2000 and AppleTalk]: /2025/04/windows-2000-and-appletalk
