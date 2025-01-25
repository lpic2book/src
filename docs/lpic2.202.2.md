##  System recovery (202.2)

###   Objectives {#lpic2.202.2.objectives}

Candidates should be able to properly manipulate a Linux system during
both the boot process and during recovery mode. This objective includes
using both the init utility and init-related kernel options. Candidates
should be able to determine the cause of errors in loading and usage of
bootloaders. GRUB version 2 and GRUB Legacy are the bootloaders of
interest.

###   Key Knowledge Areas

-   GRUB version 2 and Legacy

-   Grub shell

-   Boot loader start and hand off to kernel

-   Kernel loading

-   Hardware initialisation and setup

-   Daemon/service initialisation and setup

-   Know the different boot loader install locations on a hard disk or
    removable device

-   Overwriting standard boot loader options and using boot loader
    shells

-   Awareness of UEFI

-   UEFI and NVMe booting

###   Terms and Utilities

-   `mount`

-   `fsck`

-   `inittab`, `telinit` and `init` with SysV init

-   The contents of `/boot/` and `/boot/grub/`

-   GRUB

-   `grub-install`

-   `initrd`, `initramfs`

-   Master boot record

###   GRUB explained

GRUB (short for GRand Unified Bootloader) loads the operating
system kernel and transfers execution control to it.

Two major versions of GRUB exist. The current version is known as GRUB
but is in fact GRUB 2. GRUB has been developed around 2011. The older
version was developed back in 1999 and is now referred to as GRUB
Legacy. GRUB Legacy is still in use but its development has been frozen.

####  GRUB 2 

GRUB is a modular bootloader and supports booting from PC UEFI, PC BIOS
and other platforms. The advantage of its modular design is that as new
filesystems and/or storage solutions are added to the kernel, boot
support can easily be added to GRUB 2 in separate modules.

Examples of boot support added by such modules are modules for
filesystem support (like ext4, NTFS, btrf and zfs), and LVM and software
RAID devices.

GRUB is able to boot many operating systems, both free and proprietary
ones. Open operating systems, like FreeBSD, NetBSD, OpenBSD, and Linux,
are supported by GRUB directly. Proprietary kernels (e.g. DOS, Windows
and OS/2) are supported using GRUB's chain-loading function.
Chain-loading implies that GRUB will be used to boot the system, and in
turn will load and run the proprietary systems bootloader, which then
boots the operating system.

The GRUB boot process features both a menu interface and a command-line
interface (CLI). The CLI called is called the GRUB shell and allows you
to execute commands to select a root device (`root` command), load a
kernel from it (`linux` command) and, if necessary load some additional
kernel modules (`insmod`) and subsequently boot the kernel (`boot`
command). The menu interface offers a quick selection method of the
desired runtime environment. While booting, both interfaces are
available. On boot the menu is displayed, and the user can simply choose
one of the menu entries. Without user interaction, the system will boot
the default entry after a pre-defined time value has passed.

Alternatively, the user can hit e to edit the current entry before
booting, or hit c to enter the CLI. Some Linux distributions hide the
GRUB screen during boot. Pressing the SHIFT key right after BIOS/UEFI
initialization will unhide the GRUB screen.

After invoking the GRUB shell, the user can type commands from the list
below. The list of commands may vary, and depends on which modules are
present on the system. The `help` command will produce a list of
available commands.


    o acpi:                 Load ACPI tables
    o badram:               Filter out bad regions of RAM
    o blocklist:            Print a block list
    o boot:                 Start up your operating system
    o cat:                  Show the contents of a file
    o chainloader:          Chain-load another boot loader
    o cmp:                  Compare two files
    o configfile:           Load a configuration file
    o cpuid:                Check for CPU features
    o crc:                  Calculate CRC32 checksums
    o date:                 Display or set current date and time
    o drivemap:             Map a drive to another
    o echo:                 Display a line of text
    o export:               Export an environment variable
    o false:                Do nothing, unsuccessfully
    o gettext:              Translate a string
    o gptsync:              Fill an MBR based on GPT entries
    o halt:                 Shut down your computer
    o help:                 Show help messages
    o initrd:               Load a Linux initrd
    o initrd16:             Load a Linux initrd (16-bit mode)
    o insmod:               Insert a module
    o keystatus:            Check key modifier status
    o linux:                Load a Linux kernel
    o linux16:              Load a Linux kernel (16-bit mode)
    o list_env:             List variables in environment block
    o load_env:             Load variables from environment block
    o loopback:             Make a device from a filesystem image
    o ls:                   List devices or files
    o normal:               Enter normal mode
    o normal_exit:          Exit from normal mode
    o parttool:             Modify partition table entries
    o password:             Set a clear-text password
    o password_pbkdf2:      Set a hashed password
    o play:                 Play a tune
    o pxe_unload:           Unload the PXE environment
    o read:                 Read user input
    o reboot:               Reboot your computer
    o save_env:             Save variables to environment block
    o search:               Search devices by file, label, or UUID
    o sendkey:              Emulate keystrokes
    o set:                  Set an environment variable
    o true:                 Do nothing, successfully
    o unset:                Unset an environment variable
    o uppermem:             Set the upper memory size
                


GRUB uses its own syntax to describe hard disks. Device names need to be
enclosed in brackets, e.g

        (fd0)
                    

denotes the floppy disk, and

        (hd0,1)
                    

denotes the first partition on the first hard disk. Note that while disk
numbers start at zero, partition numbers start at one, so the last
example references the *first* disk and the *first* partition.

GRUB uses the computer BIOS to find out which hard drives are available.
But it can not always figure out the relation between Linux device
filenames and the BIOS drives. The special file `/boot/grub/device.map`
can be created to map these, e.g.:

        (fd0)  /dev/fd0
        (hd0)  /dev/hda
                    

Note that when you are using software RAID-1 (mirroring), you need to
set up GRUB on both disks. Upon boot, the system will not be able to use
the software RAID system yet, so booting can only be done from one disk.
If you only set up GRUB on the first disk and that disk would be
damaged, the system would not be able to boot.

####  GRUB Configuration File 

The configuration file for GRUB 2 is `/boot/grub/grub.cfg`. The GRUB
configuration file is written in a shell-like scripting language with
conditional statements and functions.

It is not recommended to modify `grub.cfg` directly; the configuration
file is updated whenever a kernel is added, updated, or removed using
the package manager of the distribution or when the user runs the
`update-grub` script. The `update-grub` is a wrapper around
`grub-mkconfig`, specifying `grub.cfg` as its output file. The behaviour
of `grub-mkconfig` is controlled by files in the directory `/etc/grub.d`
and keywords in the `/etc/default/grub` file.

Examples keywords: the default menu entry to boot (GRUB\_DEFAULT) or the
timeout in seconds to boot the default menu entry after the menu is
displayed (GRUB\_TIMEOUT).

Operating systems, including foreign operating systems like Windows are
automatically detected by the `/etc/grub.d/30_os_prober` script. A
custom file (by default `40_custom`) can be modified by the user to
create custom entries.

GRUB 2 menu entries start with the `menuentry` keyword. The menu
entry's title can be found within quotation marks on the `menuentry`
line. The `menuentry` line ends with an opening curly brace ({). The
menu entry ends with a closing curly brace (}).

A very simple example:

``` {#lpic2.202.2.grub2.menuentry.example}
    menuentry 'Linux 3.3.10' {
    <... >
    }
                
```

####  Differences with GRUB Legacy

At first glance, the two versions do not differ much. However, there are
some obvious differences:

-   The GRUB configuration file is now called `/boot/grub/menu.list`,
    while Red Hat based distributions favor the `/boot/grub/grub.conf`
    filename. Besides the slightly different name, the configuration
    file also has a different syntax. The grub.cfg file is now generated
    during grub-install, and is not supposed to be edited by hand.

-   The core GRUB engine is smaller and less platform dependent. Support
    for many different filesystems and platforms is now available in
    separate modules. As a consequence, the platform, and filesystem(s)
    in use determine the modules loaded during the boot sequence. In
    contrast, GRUB Legacy has a fixed boot sequence with critical
    components hardcoded, making it less flexible.

-   Partition numbering starts at 1 in GRUB 2, rather than 0. Disks are
    still numbered from 0. This can be a bit confusing.

-   GRUB 2 kernel specification is done with the `linux` command, while
    in GRUB Legacy, we use the `kernel` command instead.

-   The root device can be selected with `set root` in stead of the
    `root` command. The root device can also be set from the `search`
    command which can find devices by disk label or UUID.

-   GRUB 2 uses `insmod` to load modules. In GRUB Legacy modules are
    loaded with `module` or `modulenounzip`.

####  GRUB Legacy

The GRUB Legacy definitions for the menu-entries are stored in
`/boot/grub/menu.lst`. On some systems you may find a `grub.conf` (not to be confused with GRUB 2 `grub.cfg` config file)
link in the `/etc` or `/boot/grub` directory. Because GRUB accesses the
file directly, any changes in that file will impact the bootloader
immediately.

On systems with the Legacy bootloader, GRUB shell is available to
install and emulate it. This shell emulates the boot loader and can be
used to install the boot loader. It also comes in handy to inspect your
current set up and modify it. To start it up (as `root`) simply type
`grub`. In the following example we display the help screen:

``` {#lpic2.202.grub.legacy.screen}
    # grub
    grub> help
    blocklist FILE                         boot
    cat FILE                               chainloader [--force] FILE
    color NORMAL [HIGHLIGHT]               configfile FILE
    device DRIVE DEVICE                    displayapm
    displaymem                             find FILENAME
    geometry DRIVE [CYLINDER HEAD SECTOR [ halt [--no-apm]
    help [--all] [PATTERN ...]             hide PARTITION
    initrd FILE [ARG ...]                  kernel [--no-mem-option] [--type=TYPE]
    makeactive                             map TO_DRIVE FROM_DRIVE
    md5crypt                               module FILE [ARG ...]
    modulenounzip FILE [ARG ...]           pager [FLAG]
    partnew PART TYPE START LEN            parttype PART TYPE
    quit                                   reboot
    root [DEVICE [HDBIAS]]                 rootnoverify [DEVICE [HDBIAS]]
    serial [--unit=UNIT] [--port=PORT] [-- setkey [TO_KEY FROM_KEY]
    setup [--prefix=DIR] [--stage2=STAGE2_ terminal [--dumb] [--timeout=SECS] [--
    testvbe MODE                           unhide PARTITION
    uppermem KBYTES                        vbeprobe [MODE]

    grub >_
            
```

**Note**
Note that the grub shell is not available for GRUB 2. Instead, you can
install the Grub Emulator, `grub-emu`.

Other GRUB Legacy commands include the `blocklist` command, which
can be used to find out on which disk blocks a file is stored, or the
`geometry` command, which can be used to find out the disk geometry. You
can create new (primary) partitions using the `partnew` command, load an
`initrd` image using the `initrd` command, and many more. All options
are described in the GRUB documentation. GRUB is part of the GNU
software library and as such is documented using the `info` system. On
most systems there is a limited `man` page available as well.

The initial boot process , upon boot, the BIOS accesses the initial
sector of the hard disk, the so-called MBR (Master Boot Record), loads
the data found there in memory and transfers execution to it. If GRUB is
used, the MBR contains a copy of the first stage of GRUB, which tries to
load stage 2.

To be able to load stage 2, GRUB needs to have access to code to handle
the filesystem(s). There are many filesystem types and the code to
handle them will not fit within the 512 byte MBR, even less so since the
MBR also contains the partitioning table. The GRUB parts that deal with
filesystems are therefore stored in the so-called DOS compatibility
region. That region consists of sectors on the same cylinder where the
MBR resides (cylinder 0). In the old days, when disks were adressed
using the CHS (Cylinder/Head/Sector) specification, the MBR typically
would load DOS. DOS requires that its image is on the same cylinder.
Therefore, by tradition, the first cylinder on a disk is reserved and it
is this space that GRUB uses to store the filesystem code. That section
is referred to as stage 1.5. Stage 1.5 is commonly referred to as the
`core.img`; it is constructed from several files by the installer, based
on the filesystem(s) grub needs to support during boot.

Stage 2 contains most of the boot-logic. It presents a menu to the
end-user and an additional command prompt, where the user can manually
specify boot-parameters. GRUB is typically configured to automatically
load a particular kernel after a timeout period. Once the end-user made
his/her selection, GRUB loads the selected kernel into memory and passes
control on to the kernel. At this stage GRUB can pass control of the
boot process to another loader using chain loading if required by the
operating system.

grub-install In Linux, the `grub-install` command is used to install
stage 1 to either the MBR or within a partition.

####  Influencing the regular boot process 

The regular boot process is the process that normally takes place when
GRUB (re)booting the system. This process can be influenced by the GRUB
prompt. What can be influenced will be discussed in the following
sections, but first we must activate the prompt.

#### Choosing another kernel

If you have just compiled a new kernel and you are experiencing
difficulties with the new kernel, chances are that you would like to
revert to the old kernel.

For GRUB, once you see the boot screen, use the cursor keys to select
the kernel you would like to boot, and press Enter to boot it.

#### Booting into single user mode or a specific runlevel

This can be useful if, for instance, you have installed a graphical
environment which is not functioning properly. You either do not see
anything at all or the system does not reach a finite state because is
keeps trying to start X over and over again.

Booting into single user mode or into another runlevel where the single
user mode graphical environment is not running will give you access to
the system so you can correct the problem.

To boot into single user mode in GRUB, point the cursor to the kernel
entry you would like to boot and press e. Then select the line starting
with "linux" (for GRUB 2) or "kernel" in GRUB Legacy. Go to the end of
the line, and add "single". After that, press Enter to exit the editing
mode and then press [CTRL+x]{.keycombo} (GRUB 2), or b in GRUB Legacy to
exit the editor and boot that entry.

####  Switching runlevels

telinit It is possible in Linux to switch to a different runlevel than
the currently active one. This is done through the `telinit` command.
It's syntax is simple: telinit \[OPTION\] RUNLEVEL where RUNLEVEL is
the number of the runlevel.

The only option which `telinit` supports is `-e KEY=VALUE`. It is used
to specify an additional environment variable to be included in the
event along with RUNLEVEL and PREVLEVEL. Usually you will not use this
option.

You will find you use `telinit` mostly to switch to single-user mode
(runlevel 1), for example to be able to umount a filesystem and `fsck`
it. In that case you can use:

        # telinit 1
                    

telinit Note that `telinit` on most systems is a symbolic link to the
`init` command.

init Use of the command `/sbin/init q` forces init to reload
`/etc/inittab`.

inittab

#### Passing parameters to the kernel

If a device doesn't work:

A possible cause can be that the device driver in the kernel has to be
told to use another irq and/or another I/O port. This is only applicable
if support for the device has been compiled into the kernel, not if you
are using a loadable module.

As an example, let us pretend we have got a system with two identical
ethernet-cards for which support is compiled into the kernel. By default
only one card will be detected, so we need to tell the driver in the
kernel to probe for both cards. Suppose the first card is to become eth0
with an address of 0x300 and an irq of 5 and the second card is to
become eth1 with an irq of 11 and an address ether= of 0x340. For GRUB,
you can add the additions the same way as booting into single-user mode,
replacing the keyword "single" by the parameters you need pass.

For the example above, the keywords to pass to the kernel would be:

        ether=5,0x300,eth0 ether=11,0x340,eth1
                        

####  The Rescue Boot process {#lpic2.202.boot.rescue}

#### When `fsck` is started but fails {#lpic2.202.fsckfail}

During boot file systems are checked. On a Debian system this is done by
fsck `/etc/rcS.d/S30check.fs`. All filesystems are checked based on the
contents of `/etc/fstab`.

If the command `fsck` returns an exit status larger than 1, the command
has failed. The exit status is the result of one or more of the
following conditions:

        0    - No errors
        1    - File system errors corrected
        2    - System should be rebooted
        4    - File system errors left uncorrected
        8    - Operational error
        16   - Usage or syntax error
        128  - Shared library error
                    

If the command has failed you wil get a message:

        fsck failed. Please repair manually
        
        "CONTROL-D" will exit from this shell and
        continue system startup.
                    

If you do not press [Ctrl+D]{.keycombo} but enter the root password, you
will get a shell, in fact `/sbin/sulogin` is launched, and you should be
/sbin/sulogin able to run `fsck` and fix the problem if the root
filesystem is mounted read-only.

Alternatively (see next section) you can boot from boot media.

#### If your root (/) filesystem is corrupt 

####Using the distribution's bootmedia 

A lot of distributions come with one or more CD's or boot images which
can be put on a USB stick. One of these CD's usually contains a
"rescue" option to boot Linux in core. This allows you to fix things.

Remember to set the boot-order in the BIOS to boot from CD-ROM or USB
stick first and then HDD. In the case of a USB stick it may also be
necessary to enable "USB Legacy Support" in the bios.

What the rescue mode entails is distribution specific. But it should
allow you to open a shell with root-privileges. There you can run `fsck`
on the unmounted corrupt filesystem.

Let's assume your root partition was `/dev/sda2`. You can then run a
filesystem check on the root filesystem by typing `fsck -y
                    /dev/sda2`. The "-y" flag prevents `fsck` from
asking questions which you must answer (this can result in a lot of
Enters) and causes `fsck` to use "yes" as an answer to all questions.

mount Although the root (/) filesystem of a rescue image is completely
in RAM, you can `mount` a filesystem from harddisk on an existing
mountpoint in RAM, such as `/target`. Or, you can create a directory
first and then `mount` a harddisk partition there.

After you corrected the errors, do not forget to `umount` the
filesystems you have mounted before you reboot the system, otherwise you
will get a message during boot that one or more filesystems have not
been cleanly umounted and `fsck` will try to fix it again.

#### UEFI and NVMe boot considerations

For many decades, the system BIOS *(Basic Input Output System)* took
care of hardware and software initialization during the boot process.
Early BIOS versions required manual configuration of physical jumpers on
the motherboard. Later versions replaced the manual jumper routine by a
software menu, capable of providing an interface to configure the most
elementary computer settings. As convenient as this may sound, the
constant evolution of computer systems evolved to a point where even the
most sophisticated BIOS software proved to have its limitations. To
combat these limitations, Intel developed the EFI *(Extensible Firmware
Interface)* system in 1998 as a BIOS replacement. The EFI system dit not
catch on, until the standard was adopted by the UEFI Forum around 2005.
The standard was then (re)branded from EFI to UEFI *(Universal
Extensible Firmware Interface)*. UEFI is sometimes also referred to as
(U)EFI. Linux kernel 3.15 and newer should be able to use the UEFI
advantages.

What are these advantages you may ask? To answer that question we have
to look at the BIOS limitations first. One of the limitations of BIOS
systems is noticable when booting operating systems. Traditionally, a
BIOS can be configured to use one or more boot devices in a specific
order. A boot device can be an optical drive, a harddrive, a portable
USB volume or a network interface card. After the BIOS has performed the
POST *(Power On Self Test)*, each configured boot device will be checked
for the existence of a boot loader. The first bootloader detected will
be loaded. In case of a harddrive, the BIOS expects the bootloader to be
located at sector 0 or the MBR*(Master Boot Record)*. Since the MBR only
allows for a small amount of data (446 bytes) to be stored, the MBR
usually contains instructions that point to another piece of code on
disk. This two stage approach is known as *chainloading*. This other
piece of code could then consist of a boot manager. A boot manager is
capable of loading operating systems located at various locations on the
storage volumes. Both the first and second stage of the boot code have
to be stored within the first MegaByte of available storage on the
harddrive.

UEFI uses a different approach. Instead of being limited to the MBR
contents of one specific drive, UEFI reads boot data from an ESP
partition. ESP stands for *EFI System Partition*. The ESP is a
designated boot partition. The filesystem is usually of the type FAT ,
and it can hold any size of bootloader, or even multiple ones. On Linux
systems, the ESP is usually mounted as `/boot/efi`. Underneath that
mountpoint will be a directory structure that depends on the Operating
System in use. The boot files located within those directories carry a
`.efi` extension. With UEFI, the UEFI software acts as a mini-bootloader
looking for filenames ending in `.efi` within pre-defined locations. On
a Fedora based system, the contents of the ESP may look as follows:

        # cd /boot/efi/
        # ls -a
        .  ..  EFI
        #  cd EFI
        #  ls
        BOOT  fedora
        # ls -l BOOT
        total 1332
        -rw-r--r-- 1 root root 1293304 May 17  2016 BOOTX64.EFI
        -rw-r--r-- 1 root root   66072 May 17  2016 fallback.efi
        # ls -l fedora/
        total 3852
        -rw-r--r-- 1 root root     104 May 17  2016 BOOT.CSV
        drwxr-xr-x 2 root root    4096 Sep 28 22:17 fw
        -rwxr-xr-x 1 root root   70864 Sep 28 22:17 fwupx64.efi
        -rw-r--r-- 1 root root 1276192 May 17  2016 MokManager.efi
        -rw-r--r-- 1 root root 1293304 May 17  2016 shim.efi
        -rw-r--r-- 1 root root 1287000 May 17  2016 shim-fedora.efi
                

In the example above, every file ending in `.efi` can add functionality
to the UEFI system. So, whereas BIOS based systems depend on harddrive
metadata to boot up a system, UEFI based systems are capable of reading
files within the ESP portion of the harddrive. UEFI offers backwards
compatibility towards legacy BIOS functions, while at the same time
offering more advanced functions for modern computers. Computers using
BIOS software have trouble dealing with todays 8TB harddrives. UEFI
based computers are able to use GPT disk layouts that defeat the 2TB
partition limit of their BIOS counterparts. The UEFI software comes with
network support for IPv4 and IPv6. TCP and UDP are supported, and
booting remote boot media is supported using TFTP and even HTTP. Booting
over HTTP does require UEFI 2.5 or newer. Version 2.5 was released in
Januari 2016.

LPIC-2 exam candidates should be aware of the possibility to switch
between UEFI and Legacy BIOS boot modes on modern computers. Despite the
advantages that UEFI may have, there are also requirements that should
be met. The `.efi` boot files are expected to be located beneath a
certain path. When *Secure Boot* is enabled, the boot code has to be
digitally signed. Otherwise, systems may encounter boot issues. When
troubleshooting boot issues on a modern Linux computer, try to
distinguish MBR from GPT disk layouts. When using the UEFI boot mode,
confirm that the Linux distribution in use can also handle UEFI boot.
When *Secure Boot* is enabled, confirm that the required conditions are
met. When in doubt, switch back to "Legacy BIOS" or equivalent within
the UEFI interface. When booting from USB, it may be necessary to enable
'Legacy USB' settings for Mass Storage Devices in the UEFI interface.

#### NVM

In the previous chapter, 8TB harddrives are mentioned as a result of
recent computer storage evolution. These conventional SATA *(Serial
Advanced Technology Attachmenti)* harddrives have moving parts, and are
controlled using a protocol called AHCI *(Advanced Host Configuration
Interface)*. In recent years, SSD *(Solid State Disk)* harddrives have
become more popular. One of the advantages of these drives is the lack
of moving parts. This makes SSD harddrives not only more energy
efficient but also faster than mechanical harddrives. Because the SSD
drives have to be compatible with existing computers, they are connected
with the same SATA connector mechanical harddrives use. And they also
use the same AHCI protocol. This protocol was initially designed with
mechanical harddrives in mind. AHCI uses 1 queue with 32 commands to
control the harddrive. This poses a bottleneck for the newer generation
of SSD harddrives. To combat this bottleneck, a new technology called
NVMe *(Non Volatile Memory Express)* has been developed. NVMe allows SSD
harddrives to connect to a NVMe controller that is connected to the
PCI-E bus on the motherboard. The SSD harddisk is then controlled using
the NVMHCI *(Non Volatile Memory Host Configuration Interface)*
protocol. Instead of 1 queue holding 32 commands at a time, the SSD can
now be controlled using 65.000 queues holding up to 65.000 commands
each. This is possible because the PCI-E bus is much faster than the
SATA bus. The latest generation of fast SSD harddrives can achieve
throughput speeds up to seven times faster using NVMe when compared to
PCI-E connected AHCI harddrives.

Just as traditional harddrives connected to a Linux computer are
represented by `/dev/hda*` or `/dev/sda*` references, NVMe harddrives
are represented by `/dev/nvme*` within the Linux filesystem tree. When
working with these harddrives, be aware that the disk notation starts at
`0`, but the namespace and partition on disk start at `1`. Therefore,
the first partition on the first namespace on the first NVMe harddrive
of a system is represented by `/dev/nvme0n1p1`. More about UEFI and NVMe
booting at 204.2

