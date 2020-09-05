---
title: "Checking CD-ROM status with Bash"
date: 2020-09-05T16:12:07+02:00
draft: false
categories:
  - Tech
tags:
  - Linux
  - Bash
  - Python
  - Ruby
  - Perl
  - CD-ROM
thumbnail: /2020/09/checking-cd-rom-status-with-bash/images/cdrom.jpg
summary: >
  Running Python, Ruby, and Perl from one Bash script to detect the CD-ROM
  drive tray status using Linux ioctl.
---

{{< figure src="images/msdn.jpg" class="float-right" thumb="350" >}}

I got a good deal on a bundle of unopened MSDN CDs from 1999. Score! The first thing I wanted to do was image every CD while they were still pristine. Imaging dozens of CDs by hand would be a hassle, so a Bash script could help me out.

I needed a script to:

1. Check if the CD-ROM drive has a disc in it
2. Once the disk is ready to read, create an image of the disc using `dd`
3. After imaging, eject the disc tray
4. Wait for a new disc to be inserted and start over

Sounds easy enough, but surprisingly, there's no easy way to read the CD-ROM tray status in Linux without an external program.


ioctl
-----

I searched around and found that the only way to do this is either by installing a program that will tell you the CD-ROM status or write a bit of code that uses ioctl to talk to the CD-ROM device.

The steps to do this with ioctl are:

1. Open (get a file handle to) the CD-ROM device, e.g. `/dev/cdrom`
2. Send the ioctl command `0x5326` which asks for the status.
3. Receive the result as an integer 0 to 4

Excerpt from [uapi/linux/cdrom.h] with relevant information:

```c
#define CDROM_DRIVE_STATUS  0x5326

#define CDS_NO_INFO         0
#define CDS_NO_DISC         1
#define CDS_TRAY_OPEN       2
#define CDS_DRIVE_NOT_READY 3
#define CDS_DISC_OK         4
```


Choosing a language
-------------------

I saw examples that do this in C and Python. Wanting to make things more flexible (and add extra fun!), I decided to implement the solution code in multiple languages and use one that is available on the system.

I opted for interpreted languages so that the code could just be executed as needed. Implementing with **Python**, **Perl**, and **Ruby** should be quite enough.


Implementations
---------------

Each implementation needed to fulfil these requirements:

* Accept the CD-ROM device as the first program argument
* Open the device in non-blocking mode so it doesn't hang when the disc isn't ready
* Write the status number to standard output

Since every implementation is being stored in a Bash script, some code golf was called for.

### Python

```python
import os, sys, fcntl
fd = os.open(sys.argv[1], os.O_NONBLOCK) or os.exit(1)
print fcntl.ioctl(fd, 0x5326)
os.close(fd)
```

Pretty simple and straight forward. Read the device from program arguments using `sys.argv[1]`. Open the device, send our command `0x5326` and `print` it out.


### Perl

```perl
sysopen(my $fd, $ARGV[0], 2048) or die("unable to open device");
print ioctl($fd, 0x5326, 1);
close($fd);
```

Quite similar to the Python implementation. The only notable difference here is the `2048` which is the constant value of `O_NONBLOCK`. This could have been imported using `use Fcntl qw(O_NONBLOCK);`.

### Ruby

```ruby
File.open(ARGV[0], File::NONBLOCK) { |fd| print fd.ioctl(0x5326) }
```

Ruby is the clear winner for code golf. One line of clean code. Very nice indeed.


Running from Bash
-----------------

To keep things easily portable, we can embed the code directly into a Bash script and execute it with the interpreter.

The interpreters `ruby`, `perl`, and `python` all support running code sent to standard input and passing an argument at the same time.

To keep things clean, we'll create a function for each one using heredocs to pipe the code into the interpreter. `$1` is the first argument of the function which we'll pass as the first argument to the interpreter.

For example, with Python:

```bash
cdstat::python() {
  python - $1 <<'EOF_PY'
import os, sys, fcntl
fd = os.open(sys.argv[1], os.O_NONBLOCK) or os.exit(1)
print fcntl.ioctl(fd, 0x5326)
os.close(fd)
EOF_PY
}
```

### Selecting the language

We can automatically detect which language to use by looping over a list of interpreter candidates and checking if they exist with `command -v`. The first one we hit is the one to use.

```bash
cdstat=""
candidates=(ruby perl python)

for candidate in ${candidates[@]}; do
  if command -v $candidate 1>/dev/null; then
    cdstat="cdstat::$candidate"
    break
  fi
done

if [ -z "$cdstat" ]; then
  echo "could not find any environment to run" >&2
  echo "tried: ${candidates[*]}" >&2
  exit 1
fi
```

Now `$cdstat` references one of our functions we can execute.
If an argument is passed to the shell script, we'll use it as our CD-ROM device, otherwise `/dev/cdrom` is a sensible default on most Linux distributions.

```bash
device=${1:-/dev/cdrom}
$cdstat $device
```


Wrapping-up
-----------

If we put this all together in a script called `cdstat.sh` and `chmod +x cdstat.sh`, we now have a self-contained executable to read the status of the CD-ROM tray.

```bash
#!/bin/bash

set -euo pipefail

cdstat::ruby() {
  ruby - $1  <<'EOF_RB'
File.open(ARGV[0], File::NONBLOCK) { |fd| print fd.ioctl(0x5326) }
EOF_RB
}

cdstat::perl() {
  perl - $1 <<'EOF_PL'
sysopen(my $fd, $ARGV[0], 2048) or die("unable to open device");
print ioctl($fd, 0x5326, 1);
close($fd);
EOF_PL
}

cdstat::python() {
  python - $1 <<'EOF_PY'
import os, sys, fcntl
fd = os.open(sys.argv[1], os.O_NONBLOCK) or os.exit(1)
print fcntl.ioctl(fd, 0x5326)
os.close(fd)
EOF_PY
}

cdstat=""
device=${1:-/dev/cdrom}
candidates=(ruby perl python)

for candidate in ${candidates[@]}; do
  if command -v $candidate 1>/dev/null; then
    cdstat="cdstat::$candidate"
    break
  fi
done

if [ -z "$cdstat" ]; then
  echo "could not find any environment to run" >&2
  echo "tried: ${candidates[*]}" >&2
  exit 1
fi

statuses=(none no_disc tray_open not_ready ready)
status=$($cdstat $device)

echo "${statuses[$status]}"
```

##
{{< figure src="images/cdrom.jpg" class="float-right" thumb="300" >}}

```shell
$ ./cdstat.sh
tray_open
```

The robo CD imager can be found on my GitHub: [autorip.sh]

[uapi/linux/cdrom.h]: https://github.com/torvalds/linux/blob/master/include/uapi/linux/cdrom.h
[autorip.sh]: https://github.com/mroach/misc/blob/master/scripts/autorip.sh
