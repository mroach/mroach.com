---
date: 2019-02-03T00:00:00Z
title: Back to Linux
categories:
  - Tech
tags:
  - Linux
  - Arch Linux
aliases:
  - /2019/02/03/back-to-linux/
---

{{< figure src="images/arch-neofetch.png" title="board" >}}

This past summer I treated myself to building a new PC. I hadn't built a PC in over ten years ever since I got a MacBook Pro that could do everything I needed for both work and personal use. I'll skip the part where I fall out of love with MacBooks and sell my 2017 MacBook Pro.

After watching so many YouTube videos about PC builds, and wanting to do some PC gaming, I had to build one. So I built a modest system, trying not to go beyond the point of diminishing returns for components. For example, the **i7-8700K** is twice the price as an **i5-8400**. Is it twice as good for what I'll be doing? Highly doubt it.

I installed Windows 10 and Windows Subsystem for Linux. I have to say, Microsoft did a truly impressive job there making that work. It worked really well. The problem is I just didn't enjoy using Windows, it was sluggish at times, and I was spending all my time in WSL anyway. So I wiped it all out and installed Arch Linux.

I hadn't used Linux on the desktop since Gentoo back on my Dell Latitude D400. That was back circa 2005. Gentoo was a great distro for get started with Linux since you had no choice but to learn how the whole system is put together. So if something goes wrong, you know how to help yourself through it and you learn a lot along the way. The other factor I valued is that your system would only have software you asked for and nothing else. I don't like bloat, so Gentoo was perfect. But for a new install I wasn't interested in Gentoo, as compiling everything from source is just a waste of time. Arch looked like the worthy successor. It's a roll-your-own OS like Gentoo with rolling releases and an enthusiastic community; the value of which should never be underestimated.

After having [Arch Linux] setup for some weeks, I've compiled a list of packages that I had installed and why. So next time I setup Arch I'll have a good list of packages for my base system. I've left off the stuff that's quite obvious for me to install straight away like a web browser, editor ([Sublime Text]), and things like that. I'll probably update this as I make changes.

<!--more-->

> Tip: You can see top-level packages with `pacman -Qqen | sort`

### Development

base-devel
: A group package that installs everything you need to compile C and C++. Your basics like `gcc`, `make`, `binutils`.

docker, docker-compose
: Going forward I'd like to containerize all my development so I'm not natively installing every language, database system, and other dependencies natively on my system. My MacBook Pro for work has rvm handling multiple versions of Ruby, PostgreSQL, MySQL, Redis, statsd, memcache, and all sorts of other stuff that has no reason to be running natively.

[fish]
: I've been trying out fish as a replacement for zsh. I rather like it's tab completions and its way of organising custom functions as files in a config directory

### Interface

[arc-gtk-theme]
: Nice theme for GTX. Makes XFCE look a lot better than the default.

[lxdm]
: Lightweight desktop manager. This is what handles the UI-based login and starting XFCE.

[xfce4], xfce4-goodies
: Ever since I started using Linux back with Gentoo in the early 2000s, I've been an XFCE fan. Lightweight desktop environment with what I find to be just the right amount of "stuff" that comes with it. One day I might give [i3] a real try, but for now, XFCE is my go-to.

### Utilities

[conky]
: Lightweight desktop system monitor

galculator
: Nice calculator app

gpick
: Colour picker

[neofetch]
: When sharing your desktop screenshots to [/r/unixporn] you really *need* to have some system information in there, and neofetch is a good tool for this. That's what generated the image in this post.

[p7zip]
: Port of 7zip for Linux that includes support for 7z, rar, zip.

[pikaur]
: Tool for installing AUR (Arch User Repository) packages and keep them updated.

## Fonts

ttf-iosevka (AUR)
: For years, [Iosevka] has been my programming and terminal font of choice. It's narrow, so you can see more text on a given window width than with other fonts. It also supports all the modern fun stuff like ligatures.

[noto]-fonts
: Great font collection made by Google to handle most any language. The standard Latin fonts also look great. I use them as my default for my whole environment.

noto-fonts-emoji
: Gotta have emoji support!

otf-ipafont
: Font for Japanese

ttf-dejavu
: A default font on many platforms. I don't really use it, but it's nice to have around.

## Misc

```
pacman -S lm_sensors htop git nvidia pulseaudio tig tmux vlc xscreensaver youtube-dl
```


[/r/unixporn]: http://reddit.com/r/unixporn
[arc-gtk-theme]: https://github.com/horst3180/arc-theme
[Arch Linux]: https://www.archlinux.org/
[conky]: https://github.com/brndnmtthws/conky
[fish]: https://fishshell.com/
[i3]: https://i3wm.org/
[Iosevka]: http://typeof.net/Iosevka/
[lxdm]: https://wiki.lxde.org/en/LXDM
[neofetch]: https://github.com/dylanaraps/neofetch
[Noto]: https://www.google.com/get/noto/
[p7zip]: https://wiki.archlinux.org/index.php/p7zip
[pikaur]: https://github.com/actionless/pikaur
[Sublime Text]: https://www.sublimetext.com/
[xfce4]: https://www.xfce.org/
