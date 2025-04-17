---
title: "Windows 2000 on libvirt"
date: 2025-04-07T19:14:58+02:00
tags:
  - Windows
  - Retro
  - Homelab
---

For the retro part of my home network, I have Windows 2000 Server running
Active Directory, DNS, and DHCP servers on the retro VLAN.
I was running this on Proxmox, but wanted to move this over to my Debian server running [libvirt].

Rather than try to migrate the actual virtual machine, I installed a new instance
of Windows 2000 Server under libvirt and added it as a Domain Controller.

libvirt has support for legacy operating systems, but its default configurations
are not optimal and will cause difficulties.

[libvirt]: https://libvirt.org/

## Creating a new VM

When creating a new VM, pick your installation media. By default, libvirt won't
detect Windows 2000. Open the search box and tick *Include end of life operating systems*,
then you can pick `win2k`.

{{< figure
    src="images/install.png"
    alt="The New VM screen showing the option for Windows 2000"
>}}

On the last screen, tick *Customise configuration before install*.

Even when picking `win2k`, libvirt still defaults to using hardware that is not
supported out of the box by Windows 2000. We'll make some changes to use hardware
that Windows 2000 has built-in drivers for.

Depending on your libvirt version, some of the hardware models listed below may
not be in the options list. You can still type them in the dropdown, or use the XML
editor to set them.

### Network

There are 3 well-supported adapters available to use in libvirt/QEMU.

{{<div "table table-slim">}}
| ID          | Model            | Speed    |
| ------      | ---------        | -----    |
| `e1000`     | Intel PRO/1000   | 1 Gbit   |
| `rtl8139`   | Realtek RTL8139  | 100 Mbit |
| `pcnet`     | AMD PCNET        | 10 Mbit  |
{{</div>}}

Windows 2000 includes drivers for `rtl8139` and `pcnet` but *not* `e1000`.

If you want gigabit, you'll need a driver disk or CD for the PRO/1000. Otherwise, pick `rtl8139`.

### Sound

If you want sound, set the model to `ac97`. Otherwise, delete the card.

### Video

Set the model to `cirrus`.

This will limit you to 1024x768 @ 16 bit colour, or 1280x1024 @ 256 colour.

To get higher resolutions, you can use the model `vmvga` to emulate the VMWare SVGA adapter.
This requires drivers from VMware Tools version 10.0.12, the last to support Windows 2000.

https://packages.vmware.com/tools/releases/10.0.12/windows/

I extracted the Windows 2000 video drivers from this installer:
https://dl.mroach.com/virt/vmvga_win2k.zip

### CPU

You don't have to change anything here, but I like to set the processor model to `pentium3`
to keep things authentic when looking at system info inside the VM.

## High idle CPU usage

There's one more issue to handle in VM configuration.

After installing Windows 2000, I noticed that `qemu-system-x86_64` was using about
20% CPU consistently even though the VM itself was completely idle.
This is a known issue with some versions of Windows and the trick is to enable
the *High Performance Event Timer* which is switched off by default.

In the VM settings, go to **Overview** and then **XML** to edit.

In the `clock` element:

1. Delete the `timer` lines for `rtc` and `pit`
2. Change the `hpet` line to be `present="yes"`

It should look like this:

```xml
<clock offset="localtime">
  <timer name="hpet" present="yes"/>
  <timer name="hypervclock" present="yes"/>
</clock>
```

### Debian 12 Gotcha

If you're running this on Debian 12 "Bookworm" you'll get an error:

> unsupported configuration: hpet is not supported

This is a bug in libvirt 9.0 and it was fixed in 9.2. Unfortunately Debian 12
uses 9.0 and doesn't have a stable backport. Debian 13 "Trixie" has libvirt 11.0
so this problem is solved there.

I tested this fix on my Fedora workstation running libvirt 10.6 and it works fine.

## Bonus config

If you want to have the system information in Windows display a custom system
manufacturer and model, you can edit the XML again to add some config.
In my case, I wanted my VM to think it's a Compaq ProLiant DL580

```xml
<sysinfo type="smbios">
  <system>
    <entry name="manufacturer">Compaq</entry>
    <entry name="product">ProLiant DL580</entry>
  </system>
</sysinfo>
```

Then, add one line to the `os` element:

```xml
<os>
  <!-- snip type, boot -->
  <smbios mode="sysinfo"/>
</os>
```

{{< figure
    src="images/sysinfo.png"
    alt="System information showing the configured system manufacturer and model"
>}}


## Dual CPU Problem

If your VM is configured with multiple CPUs and you install **Update Rollup 1**,
you'll notice 100% CPU usage after rebooting.

This is a known problem and the fix is modifying the Hardware Abstraction Layer
via the registry. In Notepad, create a file with the following contents, save it,
then install it.

```
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\HAL]
"14140000FFFFFFFF"=dword:00000010
```

Beta Archive has an archive of [KB919521](https://www.betaarchive.com/wiki/index.php?title=Microsoft_KB_Archive%2F919521)
about this topic.

## Conclusion

With a few tweaks to libvirt, we can run Windows 2000 smoothly as a guest.

If you know of any other good tweaks for running legacy operating systems under
libvirt/qemu, please get in touch here or on Mastodon!
