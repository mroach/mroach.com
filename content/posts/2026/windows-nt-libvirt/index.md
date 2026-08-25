---
title: "Windows NT 4 on libvirt"
date: 2026-08-24T10:54:53+02:00
categories:
  - Tech
tags:
  - Windows NT
  - Retro
  - Homelab
  - Linux
images:
  - /2026/08/windows-nt-4-on-libvirt/images/nt4-desktop.png
thumbnail: /2026/08/windows-nt-4-on-libvirt/images/nt4-desktop.png
---

To celebrate 24 August 2026, the 30th anniversary of Windows NT Workstation 4.0's release,
I put together a guide for how to get it up and running smoothly in libvirt on Linux.

<!--more-->

I've personally had a world of hurt trying to get Windows NT Terminal Server to work
at all with libvirt/qemu. Lots of disk corruption and I/O errors. This guide is
only tested and working with with Workstation and regular Server.

{{< figure
    src="images/nt4-happy-birthday.png"
    alt="Windows NT 4.0 Desktop"
>}}

-------
Drivers
-------

This guide makes driver recommendations to get the best virtual NT 4.0 experience.

I've assembled a floppy disk image with all necessary drivers: [qemu-nt4.img](resources/qemu-nt4.img)

---------------
Create a new VM
---------------

When creating a new VM, libvirt won't detect the OS from the install media.

### OS Select

1. Open the search box
2. Tick **Include end of life operating systems**
3. Pick **Windows NT Server 4.0 (winnt4.0)**

{{< figure
    src="images/libvirt-os-select.png"
    alt="Selecting Windows NT Server 4.0"
>}}

### Disk

I pick a disk size of 4 GB since the NT installer won't let you format and install
to a C: drive larger than 4 GB. You can always add more disks later.

### RAM

128 MB of RAM is typically ample for NT.

### Don't install, yet

At the last step, **do not** begin installation yet. We have a bunch of settings
to change. Tick **Customise configuration before install**.


-------------
Configuration
-------------

### CPU

Disable **Copy host CPU configuration**. Set the model to `pentium-v1`.

### Boot Options

Optional, but a quality of life change to make here.

The Windows NT installation CDs will always boot directly into the installer.
There is no "press spacebar to install..." with a timeout like Windows 2000 and XP have.

To avoid having to eject and re-insert the virtual CD-ROM multiple times,
make the hard drive have first boot priority. With a blank hard drive image,
you'll boot into the installer, and after the first phase, off the hard drive.

{{< figure
    src="images/libvirt-boot-order.png"
    alt="Boot Options showing HDD before CD-ROM"
>}}

### IDE cache mode

If you don't change these settings, you'll get random I/O errors during installation
and VM usage that can be fatal.

For both **IDE Disk 1** and **IDE CDROM 1**, under **Advanced options**,
change the **Cache mode** to **writethrough**.

### Network

You have two options when it comes to network cards in libvirt/qemu.

Windows NT 4.0 has built-in drivers for the `pcnet` network card. This is a 10 Mb
card from AMD and works fine, but you'll be limited to 10 Mbit which can be rough
depending on what you use the VM for.
You won't find `pcnet` in the *Device model* dropdown, but you can type it in or edit the XML.

Your other option is the Realtek `rtl8139`. This is a 100 Mbit card that's well-supported
by NT 4, but you'll need to bring your own drivers.

### Sound

Windows NT 4 has built-in support for the Sound Blaster 16 card. You'll have to
edit the XML configuration to set use model and configure the ISA bus.

```xml
<sound model="sb16">
  <alias name="sound0"/>
  <address type="isa" iobase="0x220" irq="0x7"/>
</sound>
```

### Video

There are multiple video card models that can work in NT and provide high resolution
and high colour depth graphics.

* `vga` - With the **VirtualBox VBE Miniport** driver or **QEMU std-vga** driver
* `vmvga` - With the **VMWare SVGA** driver

The no-driver option is `cirrus` which will at least give you decent colour depth
at low resolutions.

### Optional: Floppy drive

If you want to install network support during setup, a floppy drive and image is
the natural way to do this.

----------------------
During NT installation
----------------------

### Network

* If you're using `pcnet` as your NIC, you can auto-detect this during setup.
* If you're using the `rtl8139` and have the floppy driver disk available, you
  can get the NIC installed at this point.

You can of course always add networking support after the initial installation.

{{< figure
    src="images/nt4-setup-nic.png"
    alt="Windows NT setup - Network card"
>}}


### Display

* *DO NOT* try to change the display settings *at all*. It'll hang the VM and you'll
have to hard-reset and start the graphical portion of the install over again.

------------
Post-install
------------

Once your new NT install is up and running, there are few more things you'll want to do.

### ATA Driver

By default, your disk I/O will be running in PIO mode which is *terribly* slow.
Unless you want your VM to feel like you're running on a vintage 486, you'll want
to install an ATA driver so you're running in DMA mode.

The [UniATA] driver works great and will provide a noticeable improvement in disk I/O performance.

1. In **Control Panel**, open up **SCSI Adapters**
2. On the **Drivers** tab, click **Add...**, then **Have Disk...** and enter the path to the UniATA drivers. If you're using my floppy image, it's `A:\uniata`
3. Select **Universal ATA Driver (Win NT 4) (Win2003)**
4. After that's added, select **IDE CD-ROM (ATAPI 1.2)/Dual-channel PCI IDE Controller** and then **Remove** it.
5. Reboot and you'll now be running with fast I/O.

[UniATA]: http://alter.org.ua/en/soft/win/uni_ata/index.php

### Sound

If you're using sound:

1. Open up **Control Panel**, **Multimedia**, and the **Devices** tab.
2. Click **Add** and then pick **Creative Labs Sound Blaster 1.X, Pro, 16**.
3. On the **Configuration** screen, set the **MPU401 I/O Address** to **Disable**.

### Video

Install the right drivers for your card. **VMWare SVGA** (for `vmvga`) and
**VirtualBox VBE Miniport** for (`vga`) both work well.

I've found that `vmvga` can have some strange rendering issues like the mouse being
too large and screen elements persisting. The VBE driver causes a license to
appear during the blue startup screen, but that's not a problem.

To install the driver:
1. Right-click on the desktop and click **Properties**
2. On the **Settings** tab, click **Display Type...**
3. Click **Change** and then **Have Disk...**

If you're using my driver disk, now you can enter `A:\vga` or `A:\vmvga` depending
on which adapter you're using.

Note: If you're using `vga`, after rebooting your system your display will be set to
640x480 which obscures the "OK" button in the **Display Properties** window.
If you tab through the 3 buttons at the bottom of this window, hit tab once more and then
enter to apply the settings.

### Service Pack 6

Once you're done installing system components and drivers, upgrading to Service Pack 6 is a must.

You can also install the final updates:
* Service Pack 6a
* Post-SP6 update `q299444`

------
Wrapup
------

If all goes well, you should have a snappy NT 4.0 VM with all the essential hardware
working nicely!

For bonus fun, you can [add IPv6 support](/2026/03/ipv6-on-windows-nt-4-and-2000) to your system.

{{< figure
    src="images/nt4-hardware.png"
    alt="Windows NT 4.0 Desktop"
>}}

------------------
libvirt XML Sample
------------------

The stock/default config for things like SPICE and USB controllers has been removed
from this to focus on the parts that matter.


```xml
<domain type="kvm">
  <metadata>
    <libosinfo:libosinfo xmlns:libosinfo="http://libosinfo.org/xmlns/libvirt/domain/1.0">
      <libosinfo:os id="http://microsoft.com/winnt/4.0"/>
    </libosinfo:libosinfo>
  </metadata>

  <memory>131072</memory>
  <currentMemory>131072</currentMemory>

  <!-- NT may BSOD if you change this to multi-processor. -->
  <vcpu>1</vcpu>

  <os>
    <type arch="x86_64" machine="pc-i440fx-10.0">hvm</type>
  </os>

  <!-- NT doesn't support ACPI, so you can remove the `<acpi>` element entirely -->
  <features>
    <apic/>
    <vmport state="off"/>
  </features>

  <!-- You may encounter BSOD if emulating newer processors -->
  <cpu mode="custom" match="exact">
    <model>pentium-v1</model>
  </cpu>

  <devices>
    <emulator>/usr/bin/qemu-system-x86_64</emulator>

    <!-- Make sure to set "writethrough" for the cache -->
    <disk type="file" device="disk">
      <driver name="qemu" type="qcow2" discard="unmap" cache="writethrough"/>
      <source file="/tank/vm/images/nt4w7.qcow2"/>
      <target dev="hda" bus="ide"/>
    </disk>

    <!-- Make sure to set "writethrough" for the cache -->
    <disk type="file" device="cdrom">
      <driver name="qemu" type="raw" cache="writethrough"/>
      <source file="/tank/library/virt/winnt40wks_sp1_en.iso"/>
      <target dev="hdb" bus="ide"/>
      <readonly/>
    </disk>

    <!-- Optional, but makes life easier to get drivers on the VM -->
    <disk type="file" device="floppy">
      <driver name="qemu" type="raw"/>
      <source file="/tank/library/virt/qemu-nt4.img"/>
      <target dev="fda" bus="fdc"/>
      <readonly/>
    </disk>

    <!-- You can also use `pcnet` for 10 Mbit -->
    <interface>
      <model type="rtl8139"/>
    </interface>

    <!-- Must be on the ISA bus to work -->
    <sound model="sb16">
      <alias name="sound0"/>
      <address type="isa" iobase="0x220" irq="0x7"/>
    </sound>

    <!-- Can also use `vmvga` with the VMWare drivers -->
    <video>
      <model type="vga"/>
    </video>
  </devices>
</domain>
```
