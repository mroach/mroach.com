---
title: "Windows 2000 and AppleTalk"
date: 2025-04-17T17:27:46+02:00
categories:
  - Tech
tags:
  - Windows 2000
  - AppleTalk
  - Homelab
---

So you want to get up and running with AppleTalk on Windows 2000? Good choice!

<!--more-->

AppleTalk is reasonably well supported on Windows 2000.

Windows 2000 Professional can only join AppleTalk networks. It can't share anything.
Windows 2000 Server can join a zone, create zones, plus share files and printers.

## Joining an AppleTalk Zone

If you want to join an existing AppleTalk zone, you'll have to add AppleTalk
to your adapter configuration if it's not there already.

1. **Start > Settings > Network and Dial-up Connections**
2. Right-click on the adapter you want to configure, **Properties**

On a default Windows setup the only protocol you'll see is **Internet Protocol (TCP/IP)**

To add AppleTalk:
1. Click **Install...**
2. Double-click **Protocol**
3. Double-click **AppleTalk Protocol**

The UI will hang for a bit as it searches the AppleTalk network. Now you can
check what it found. Double-click **AppleTalk Protocol**.

If a zone was found on your network, it should already be selected.
If there wasn't a zone, continue on to create one in Windows 2000 Server.

{{< figure src="images/appletalk-client.png" class="center" >}}

## Creating a zone

### Initial Setup

AppleTalk services are not installed by default on Windows 2000 Server, but they're easy to add.

1. Open up the **Control Panel**
2. **Add/Remove Programs**
3. **Add/Remove Windows Components**
4. Select **Other Network File and Print Services** and click **Details...**
5. Tick both **Macintosh** services
6. OK and Next your way out of all these.

If there's already an AppleTalk zone available on your network, Windows probably
already joined it by default. You can verify or change that in the network adapter properties
covered in the previous section.

{{< figure src="images/appletalk-services.png" class="center" >}}

### Add a zone

If there's no AppleTalk zone on your network yet or you want to add more, they're quick to add.

> You don't need to do this if you're going to use **jrouter** (see **Next Steps**)
> as it will create the zone and be the router.

1. **Start > Programs > Administrative Tools > Routing and Remote Access**
2. Right-click on **AppleTalk Routing**, click **Enable AppleTalk Routing**

It may take a bit to enable. Now, open up the adapter you want to configure
and tick **Enable seed routing on this network**.

Now you can click **New Zone...** to create a new AppleTalk zone.

{{< figure src="images/appletalk-create-zone.png" class="center" >}}

## File Sharing

Sharing a folder from Windows over AppleTalk uses a different interface than the
normal shortcut of right-clicking on a folder and sharing it.

You'll use **Computer Management**. There are a couple quick ways of getting there:
- Right-click on **My Computer** and click **Manage**
- Or, **Start > Programs > Administrative Tools > Computer Management**

Under **System Tools**:

1. Expand **Shared Folders**.
2. Right-click on **Shares** to add click **New File Share**.

From here it's pretty self-explanatory.

You can use **Sessions** to monitor connections to your AppleTalk shares.

{{< figure src="images/appletalk-folder-sharing.png" class="center" >}}


### Additional Configuration

You can right click on **Shared Folders** in the Management Console and pick
**Configure File Server for Macintosh...** to set options like what this
server's name will appear as to Mac clients and some other stuff, but the defaults are fine.

{{< figure src="images/appletalk-server-properties.png" class="center" >}}

## Using AppleTalk Printers

Adding an AppleTalk printer is slightly misleading since you create them as local printers.

I've had mixed results with the browser actually finding printers. I did get it to work once.

1. Add a printer as usual, but select **Local printer**.
2. Select **Create a new port** and **AppleTalk Printing Devices**.
3. When you click **Next**, a dialog will appear to open a zone and pick a printer.

It's going to ask you about capturing the printer. I don't fully understand this
and it sounds like something you don't want to do in a shared environment, so I declined
and printing still worked fine.

{{< figure src="images/appletalk-printer-client.png" class="center" >}}

## Sharing Printers

Unlike folder sharing, this one is totally standard. Share the printer as usual
and it will show up in the AppleTalk network.

## Next Steps

If you want to join [GlobalTalk] and connect to other AppleTalk networks across
the internet, you'll need an **AppleTalk Internet Router**. If you don't have
a Mac running OS 7 or 8, the easiest way to do it these days is with [jrouter].
This is a piece of cake to get up and running on Linux.

[jrouter]: https://gitea.drjosh.dev/josh/jrouter
[GlobalTalk]: https://marchintosh.com/globaltalk.html
