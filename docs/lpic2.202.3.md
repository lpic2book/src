##  Alternate Bootloaders (202.3)

Candidates should be aware of other bootloaders and their major
features.

###   Key Knowledge Areas

-   SYSLINUX, ISOLINUX, PXELINUX

-   Understanding of PXE for both BIOS and UEFI

-   Awareness of systemd-boot and U-Boot

-   Booting UEFI systems

-   Systemd-boot

-   U-Boot

###   Terms and Utilities
-   `syslinux`

-   `extlinux`

-   `isolinux.bin`

-   `isolinux.cfg`

-   `isohdpfx.bin`

-   `efiboot.img`

-   `pxelinux.0`

-   `pxelinux.cfg/`

-   `uefi/shim.efi`

-   `uefi/grubx64.efi`

-   `UEFI`

-   `Systemd-boot`

-   `U-boot`

###   LILO

The lilo bootloader consists of two stages. During the two stage boot,
LILO indicates its progress by printing consecutive letters from the
word \"LILO\" to the BIOS console, with one letter at the start and end
of each stage.

Errors during either stage result in only parts of the word being
printed, optionally followed by a numeric BIOS error code, or a single
character. E.g, `LIL-` or `LIL?`.

In interactive mode (`prompt` keyword in `/etc/lilo.conf`) LILO presents
the user with a choice of up to 16 entries. If no `timeout=nnn` (`nnn`
in tens of a second) is specified, the bootloader will wait
indefinitely. If the timeout expires, or no `prompt` was included, LILO
proceeds by loading the first image listed. This can be overruled with
the `default=name` keyword.

####  /etc/lilo.conf and /sbin/lilo

Unless modern bootloaders, neither stage of LILO is actually aware of
the contents of `/etc/lilo.conf`. Instead, the file is used only as a
specification for the lilo installer, typically at `/sbin/lilo`. Without
additional options, `/sbin/lilo` will install the bootloader into the
MBR, and process the contents of `/etc/lilo.conf`, creating a mapping of
any files specified to store into `/boot/map`.

Please refer to the `lilo.conf(5)` man page online for a detailed
description of `/etc/lilo.conf`.

Example `/etc/lilo.conf` (from an older debian distribution)

``` {#lpic2.202.3.lilo.conf.example}
    # lilo.conf
    #
    #  global options:
    boot=/dev/hda
    prompt
    timeout=150
    lba32
    compact
    vga=normal
    root=/dev/hda1
    read-only
    menu-title=" John's Computer "
    #
    #  bootable kernel images:
    image=/boot/zImage-1.5.99
         label=try
    image=/boot/zImage-1.0.9
         label=1.0.9
    image=/tamu/vmlinuz
         label=tamu
         initrd=initramdisk.img
         root=/dev/hdb2
         vga=ask
    #
    #  other operating systems:
    other=/dev/hda3
         label=dos
         boot-as=0x80    # must be C:
    other=/dev/hdb1
         label=Win98
         boot-as=0x80    # must be C:
    other=/dev/hdb5
         label=os2
         loader=os2_d
         table=E:   # os2 sees as E:
            
```

###   SYSLINUX, ISOLINUX, PXELINUX: The Syslinux Project

`SYSLINUX` is a linux bootloader designed to run from an MS-DOS/Windows
FAT file system. It is limited to Intel/AMD hardware.

Over time, the Syslinux project (<http://syslinux.org>) expanded to
include support for booting natively from CD-ROMS (`ISOLINUX`), linux
file systems (`EXTLINUX`) and over PXE (`PXELINUX`).

This summary handles the LPIC-2 specific objectives. A full description
can be found in the syslinux wiki at
<http://www.syslinux.org/wiki/index.php/SYSLINUX>

####  SYSLINUX

SYSLINUX is an Intel Linux bootloader which is able to boot from
Windows/MS-DOS FAT based file systems. It can be installed with the
command of the same name, from either Windows, MS-DOS, or linux.

The syslinux system consists of the actual bootloader and its installer.
The bootloader itself is a 32bit native binary written in assembler.

The `syslinux` installer command comes in different versions:
`syslinux.exe` for Windows, `syslinux` for linux. There is even a
`syslinux.com` for DOS based systems.

#### SYSLINUX Installer Options

        --offset        -t      Offset of the file system on the device
        --directory     -d      Directory for installation target
        --install       -i      Install over the current bootsector
        --update        -U      Update a previous installation
        --sectors=#     -S      Force the number of sectors per track
        --heads=#       -H      Force number of heads
        --stupid        -s      Slow, safe and stupid mode
        --raid          -r      Fall back to the next device on boot failure
        --once=...              Execute a command once upon boot
        --clear-once    -O      Clear the boot-once command
        --reset-adv             Reset auxilliary data
        --menu-save=    -M      Set the label to select as default on the next boot
        --force         -f      Ignore precautions
                    

#### MSDOS specific options

        -m      MBR: install a bootable MBR sector to the beginning of the drive.
        -a      Active: marks the partition used active (=bootable)
                    

#### Linux only

        -t      (-o on older systems) Specifies the byte offset of the filesystem 
                image in the file. It has to be used with a disk image file.
                

#### Exceptions for ISOLINUX, EXTLINUX, PXELINUX

[//]: # (this section needs clarification (jos@sue.nl))

####The ISOLINUX Installer

While `syslinux` expects a target device to write the bootloader, the
`isolinux` installer generates an ISO image from a directory structure.
The directory must include a subdirectory `isolinux` which in turn must
include the actual `isolinux.bin` bootloader.

####The EXTLINUX Installer

The `extlinux` installer expects a mounted file system to install the
bootloader into.

####PXELINUX

is treated in [PXELINUX](#lpic2.202.3.PXELINUX).

#### Syslinux Boot Configuration

The bootloaders installed by these utilities will look for a
`syslinux.cfg` file in the following three directories:
`/boot/syslinux`, `/syslinux`, `/` (root).

The ISOLINUX bootloader will first look for `/boot/isolinux` and
`/isolinux`. The EXTLINUX bootloader looks for `/boot/extlinux` and
`/extlinux` first.

The directory where the config file is found will be the default
directory for further pathnames in the boot process.

The CONFIG keyword will restart the boot process with a new config file.
If two pathnames are supplied, the second parameter overrides the
default directory.

The boot process will look in the `syslinux.cfg` file for a line with
\"LABEL linux\". When found, it will use any subsequent keywords to
guide the boot process. (A `DEFAULT label` phrase can be used to
override the \"linux\" label.)

Typical keywords in a boot configuration:

`KERNEL` *image*

-   The `KERNEL`keyword specifies an image file. This does not have to
    be an actual kernel image, but can be the name of the next stage
    bootprogram. SYSLINUX e.a. rely on filename extensions to decide on
    the file format.

    `.0`

    :   is used with PXELINUX for the PXE NBP (Network Boot Program),
        with `pxelinux.0` being the default.

    `.bin`

    :   used with ISOLINUX, and refers to the CD Boot Sector,

    `.bs` or `.bss`

    :   refer to (patched) DOS bootsectors \[SYSLINUX\].

    `.com`, `.cbt`, and `.c32`

    :   are COMBOOT images (DOS,non-DOS,32 bit). For versions 5.00 and
        later `c32` changed from COMBOOT to ELF binary format.

    `.img`

    :   is an ISOLINUX diskimage.

    Any *other* file extension (or none at all) indicate a linux kernel
    image.

    The file type can also be forced by using one of the `KERNEL`
    keyword aliases: `LINUX`, `BOOT`, `BSS`, `PXE`, `FDIMAGE`, `COMBOOT`
    or `COM32`.

`APPEND` string

-   The `APPEND` keyword specifies a string of boot parameters that is
    appended to the kernel command line. Only the last `APPEND` line
    will be applied.

`SYSAPPEND`

-   The `SYSAPPEND` keyword expects a numeric argument that is
    interpreted as a bitmap. Each bit in this bitmap will add a specific
    auto-generated string to the kernel command line.

    `1:`Adds a string with network information:
    `ip=client:bootserver:gw:netmask`

    `2:`Adds `BOOTIF=` \..., identifying the active network interface by
    its mac address.

    `4:`Adds the string `SYSUUID=`\...

    `8:`Add `CPU=`\...

    Higher order bits (0x00010 through 0x10000) control additional
    strings from DMI/SMBIOS, if available. A full list can be found in
    the Syslinux wiki:
    [http://www.syslinux.org/wiki/index.php/SYSLINUX\"](http://www.syslinux.org/wiki/index.php/SYSLINUX)

`INITRD` *filename*

-   The `INITRD` keyword is equivalent to `APPEND initrd=filename`.

`TIMEOUT` num

-   For interactive use, the argument to `TIMEOUT` indicates the number
    of tens of a second that SYSLINUX should wait for input on the
    console or serial port.

####  PXELINUX 

[//]: # (this section needs clarification (jos@sue.nl))

The PXELINUX bootloader is used as the second stage of a PXE network
boot. The PXE network boot mechanism is further explained in
[Understanding PXE](#lpic2.202.3.understanding.pxe).

PXELINUX expects a standard TFTP server with a `/tftpboot` directory
containing the `pxelinux.0` syslinux bootloader, and the `ldlinux.c32`
library module.

In addition, a directory `/tftpboot/pxelinux.cfg` must exist for
additional configuration details.

A PXE TFTP boot server can serve many different clients, and needs a way
to maintain different configuration files for different (categories of)
clients. There are many different ways in which the name of the
configuration file can be specified.

#### Combine DHCP Option 209 and 210

-   Option 209 (`pxelinux.config-file`) specifies the filename for the
    configfile.

    Option 210 (`pxelinux.pathprefix`) specifies the search path
    (directory prefix) on the TFTP server namespace (ending in the
    OS-specific separator character for the file system).

#### Hardcoded in the `pxelinux.0` image.

-   The `pxelinux-options` command can be used to hardcode the options
    as shown in this table
    
    |number|option|
    |----|----|
    |6 |domain-name-servers|
    |15 |domain-name|
    |54 |next-server|
    |209 |config-file|
    |210 |path-prefix|
    |211 |reboottime|

    Options can be specified as 'before-options', where DHCP has
    precedence, or as 'after-options', which override DHCP.

#### Derived from UUID, MAC-address, or IP-Address

-   If no config file is specified, the filename is derived from a list
    of variables. The first file in the list that actually exists on the
    TFTP server will be used.

    The list of variables is:

    -   The client's UUID, in lower case.

    -   The client's MAC address, in lower case hexadecimal, with bytes
        separated by a dash (\"-\").

    -   The longest possible prefix of the Upper case hexadecimal
        representation of the client's ipv4 address. Each time the
        string does not match, PXELINUX drops the last character from
        the string and tries again as long as the result contains at
        least one character.

    -   As a last resort, PXELINUX will try to retrieve the file named
        \"default\".

#### Understanding PXE 

PXE is a specification created by Intel to enhance the original network
boot protocols: BOOTP, TFTP and DHCP.

BOOTP, RARP and TFTP were created by the IETF to enable systems to
automatically retrieve their network configuration and initial
bootloader from a server.

The initial BOOTP standard was limited to a number of fixed fields in
which client and server could exchange information. A client could
supply its hardware address in `chaddr`, and request a specific type of
`file`, and would receive its ip address as `yiaddr` and a servername
`sname`. Combined with the server IP address field (`siaddr`) and the
gateway IP address field, and the returned boot file name (`file`) this
would tell the boot client where to retrieve its boot image, using TFTP.

**BOOTP Fields.**

        ciaddr  4       client IP address
        yiaddr  4       your IP address
        siaddr  4       server IP address
        giaddr  4       gateway IP address
        chaddr  16      client hardware address
        sname   64      optional server host name, null terminated string.
        file    128     boot file name, null terminated string;
        vend    n     n=64 in original BOOTP, starts with the 4 byte
                        DHCP 'magic' number.
                    

Over time networks and IT infrastructure became more complicated and
requirements more demanding. To allow clients to provide more
information about themselves and to retrieve tailored information, BOOTP
received the BOOTP Vendor Information Extensions \[RFC 1048\], which in
turn was enhanced with a new protocol, DHCP. DHCP extended BOOTP with a
number of standard options, defining different types of messages. Some
DHCP options may overlap with standard BOOTP fields, and should contain
the same value in that case.

**Note**
A DHCP message is a BOOTP packet (request or response) with a special 4
byte value (the DHCP magic cookie) in the BOOTP \"Vendor Information
Field\". Following that are DHCP options, consisting of a single byte
option type, a length field, and `length` bytes of option content.

This rule has two exceptions: *Padding* (`0`) and *End of Options*
(`255`) are just one byte in length and lack a length field.

Finally, Intel introduced PXE, to enhance the BOOTP/DHCP protocol even
further, in an attempt to standardise the way clients can identify
themselves. This allows boot clients and servers to minimize the number
of packets that needs to be exchanged before they can decide on the
correct parameters and the boot program needed to get going.

A PXE boot request starts with a DHCP Discover message including at
least five options, of which three are PXE-specific:

        (53) DHCP Message type (DHCP Discover),
        (55) Parameter Request List,
        (93) Client System Architecture,
        (94) Client Network Device Interface, 
        (97) UUID/GUID-based Client Identifier
                

Options 93, 94, and 97 are defined in the PXE specification. In
addition, option 55, the Parameter Request List, must \*also\* request
options 128 through 135, even though a server is not required to provide
a response to them. This list and the three options listed above act to
identify the client as PXE aware.

#### Proxy DHCP for PXE

Not every DHCP server (especially those embedded in network equipment)
will be able to process a PXE request.

The PXE specification allows PXE-aware DHCP servers to co-exist with
simple DHCP servers, where the default DHCP server provides the basic
network detail. The PXE-aware server can then provide additional detail
for the actual TFTP boot process. This is called proxy-DHCP.

It is even possible to separate DHCP services on the same server, in
which the proxy DHCP service is expected to listen to UDP port 4011.

#### Example DHCP request

See below for an example DHCP Discover message, including requests for
standard network detail such as (1) Subnet Mask, (3) Router, (6) Name
server, (12) Host Name, (15) Domain Name, etc.

        Option: (53) DHCP Message Type
            Length: 1
            DHCP: Discover (1)
        Option: (57) Maximum DHCP Message Size
            Length: 2
            Maximum DHCP Message Size: 1464
        Option: (55) Parameter Request List
            Length: 35
            Parameter Request List Item: (1) Subnet Mask
            Parameter Request List Item: (2) Time Offset
            Parameter Request List Item: (3) Router
            Parameter Request List Item: (4) Time Server
            Parameter Request List Item: (5) Name Server
            Parameter Request List Item: (6) Domain Name Server
            Parameter Request List Item: (12) Host Name
            Parameter Request List Item: (13) Boot File Size
            Parameter Request List Item: (15) Domain Name
            Parameter Request List Item: (17) Root Path
            Parameter Request List Item: (18) Extensions Path
            Parameter Request List Item: (22) Maximum Datagram Reassembly Size
            Parameter Request List Item: (23) Default IP Time-to-Live
            Parameter Request List Item: (28) Broadcast Address
            Parameter Request List Item: (40) Network Information Service Domain
            Parameter Request List Item: (41) Network Information Service Servers
            Parameter Request List Item: (42) Network Time Protocol Servers
            Parameter Request List Item: (43) Vendor-Specific Information
            Parameter Request List Item: (50) Requested IP Address
            Parameter Request List Item: (51) IP Address Lease Time
            Parameter Request List Item: (54) DHCP Server Identifier
            Parameter Request List Item: (58) Renewal Time Value
            Parameter Request List Item: (59) Rebinding Time Value
            Parameter Request List Item: (60) Vendor class identifier
            Parameter Request List Item: (66) TFTP Server Name
            Parameter Request List Item: (67) Bootfile name
            Parameter Request List Item: (97) UUID/GUID-based Client Identifier
            Parameter Request List Item: (128) DOCSIS full security server IP [TODO]
            Parameter Request List Item: (129) PXE - undefined (vendor specific)
            Parameter Request List Item: (130) PXE - undefined (vendor specific)
            Parameter Request List Item: (131) PXE - undefined (vendor specific)
            Parameter Request List Item: (132) PXE - undefined (vendor specific)
            Parameter Request List Item: (133) PXE - undefined (vendor specific)
            Parameter Request List Item: (134) PXE - undefined (vendor specific)
            Parameter Request List Item: (135) PXE - undefined (vendor specific)
        Option: (97) UUID/GUID-based Client Identifier

        Length: 17
            Client Identifier (UUID): 00000000-0000-0000-0000-44123456789a
        Option: (94) Client Network Device Interface
            Length: 3
            Major Version: 3
            Minor Version: 16
        Option: (93) Client System Architecture
            Length: 2
            Client System Architecture: EFI BC (7)
        Option: (60) Vendor class identifier
            Length: 32
            Vendor class identifier: PXEClient:Arch:00007:UNDI:003016
        Option: (255) End
            Option End: 255
                    

####  Systems with UEFI 

UEFI is a protocol known as Unified Extensible Firmware Interface (UEFI)
Secure Boot. This was to be a modern replacement for the aging BIOS
system and would help ensure boot-time malware couldn't be injected into
a system.

The BIOS replacement, UEFI, requires a digital key installed for the OS
to pass the UEFI firmware check to be able to boot. Mainstream Linux
distributions like Red Hat, Ubuntu and Suse for example have purchased
those keys so they have no problems with Secure Boot systems.

Without this digital key you generally still should be able to use Linux
on a secure boot system. You can start with disabling the folowing in
your BIOS:

                             Quickboot/Fastboot

                             Intel Smart Response Technology (ISRT)

                             FastStartUp (if you have Windows 8).
                             

If you get a Secure boot or signature error, you need to disable Secure
Boot. If your system is running Windows 7, you can enter the BIOS by
entering the keyboard key required to enter the BIOS settings and
disable Secure Boot. If the system comes with Windows 8 you will need to
boot into Windows and choose to do an Advanced startup. This should
allow you to enter the BIOS and disable Secure Boot. Not: Sometimes a
BIOS is able to run in EFI or legacy mode. If your system allows this
you should not have any problems installing Linux

####  Booting with Systemd-boot 

Systemd comes with Systemd-boot. This is intended for use with EFI
systems. It can only start EFI executables such as the Linux kernel
EFISTUB, UEFI Shell, GRUB and the Windows Boot Manager. Systemd-boot is
managed with the `bootctl` command. systemd-boot requires an EFI System
Partition (ESP), preferably mounted on `/boot`. The ESP must contain the
EFI binaries. Further information and examples can be found at
<https://www.freedesktop.org/software/systemd/man/index.html>

####  Booting with Das U-boot 

Das U-boot "the Universal Boot Loader" is an open source, primary boot
loader aimed at embedded devices. It is used to package the instructions
to boot the kernel code. It is supporting many computer architectures,
including 68k, ARM, AVR32, Blackfin, MicroBlaze, MIPS, Nios, SuperH, PPC
and x86. U-Boot can be split into stages if there are size restraints.
U-Boot requires explicit commands as to where the memory addresses are
to copy the kernel, ramdisk, etc data to opposed to other bootloaders
which automatically choose the memory locations. Due to the U-Boot
commands being low-level, booting a kernel requires multiple steps. This
allows U-Boot to be very flexible. U-Boot can boot from on board
storage, the network and even serial ports.
