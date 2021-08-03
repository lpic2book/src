##  Configuring PCMCIA Devices (204.4)

Candidates should be able to configure a Linux installation to include
PCMCIA support. This objective includes configuring PCMCIA devices, such
as ethernet adapters, to be auto detected when inserted.

###   Key files, terms and utilities include:

/etc/pcmcia/

\*.opts

cardctl

cardmgr

###   Overview of PCMCIA

Nowadays, almost all laptops, and even a number of desktops, contain
PCMCIA slots. PCMCIA is an PCMCIA abbreviation for
Personal Computer Memory Card International Association, a commission
that defines standards for expansion cards. The PCMCIA itself was
founded in 1990. It initially developed a set of standards by which
memory could be added to portable systems. The PCMCIA specification 2.0
release in 1991 added protocols for I/O devices and hard disks. The 2.1
release in 1993 refined these specifications, and is the standard around
which PCMCIA cards are built today. PCMCIA cards are credit card size
adapters which fit into PCMCIA slots. There are three types of PCMCIA
cards, Type I generally used for memory cards such as FLASH and STATIC
RAM; Type II used for I/O peripherals Type II Type I Type III such as
serial adapters and fax-modems and Type III which are used for rotating
media such as hard disks. The only difference in the physical
specification for these cards is thickness: type I is the thinnest, type III the thickest.

PCMCIA cards are "hot pluggable" e.g. you can remove your network card
without hot pluggable damaging your system (your network will not work
of course) and plug it back in which will automatically start up your
card and configure the card for your system. Linux supports PCMCIA
standards. It features a daemon which monitors PCMCIA sockets to see if
cards are removed or inserted (`cardmgr`), and runs scripts to configure
the network into your system. Linux also features drivers for the
various PCMCIA cards. These drivers are either part of the kernel
distribution or are supplied via an additional package (Card Services
for Linux). Card Services

####  cardmgr

The `cardmgr` daemon is responsible for monitoring PCMCIA cardmgr
sockets, loading client drivers when needed and running user-level
scripts in response to card insertions and removals. It records its
actions in the system log, but also uses beeps to signal card status
changes. The tones of the beeps indicate success or failure of
particular configuration steps. Two high beeps indicate that a card was
identified and configured successfully. A high beep followed by a low
beep indicates that a card was identified, but could not be configured
for some reason. One low beep indicates that a card could not be
identified. The `cardmgr` daemon configures cards based on a database of
known card types kept in `/etc/pcmcia/config`. This file describes the
various client /etc/pcmcia/config drivers, then describes how to
identify various cards and which driver(s) belong with which cards. The
format of this file is described in the `pcmcia(5)` man page.

####  The `stab` file

The `cardmgr` daemon records device information for each socket in the
file `/var/lib/pcmcia/stab`. For the lines /var/lib/pcmcia/stab
describing devices, the first field is the socket, the second is the
device class, the third is the driver name, the fourth is used to number
multiple devices associated with the same driver, the fifth is the
device name, and the final two fields are the major and minor device
numbers for this device (if applicable).

####  The `/etc/pcmcia` directory

The `/etc/pcmcia` directory contains various configuration files for
PCMCIA devices. Also, it contains scripts that start or stop PCMCIA
PCMCIA/etc/pcmcia devices. For example the configuration file
`config.opts` contains the local resource settings for PCMCIA devices,
such as which ports to use, memory ranges to use and ports and irq's to
exclude. Additionally, extra options for the modules can be specified
here.

####  Card Services for Linux

"Card Services for Linux" is a complete PCMCIA or "PC Card" support
package. It includes a set of loadable kernel modules that implement a
version of the Card Services applications-programming interface, a set
of client drivers for specific cards and a card manager daemon that can
respond to card LinuxCard Services insertion and removal events, loading
and unloading drivers on demand. It supports "hot swapping" of most card
types, so cards can be safely inserted and ejected at any time. The
release includes drivers for a variety of ethernet cards, a driver for
modem and serial port cards, several SCSI adapter drivers, a driver for
ATA/IDE drive cards and memory-card drivers that should support most
SRAM cards and some flash cards.

You'll need the kernel source to install `pcmcia-cs`, since pcmcia-cs
the driver modules contain references to the kernel source files.
Installing the `pcmcia-cs` package results in a number of modules in the
`/lib/modules/<your-kernel-version>` directory.

The PCMCIA startup script recognizes several groups of startup options
which are set via environment variables. Multiple options should be
separated by spaces and enclosed in quotes. Placement of startup options
depends on the Linux distribution used. They may be placed directly in
the startup script or they may be kept in a separate option file. These
are specific for various Linux distributions.

Card Services should automatically avoid allocating IO ports and
interrupts already in use by other standard devices. It will also
attempt to detect conflicts with unknown devices, but this is not
completely reliable. In PCMCIA/etc/pcmcia/config.opts some cases, you
may need to explicitly exclude resources for a device in
`/etc/pcmcia/config.opts`.

###   Newer kernels and PCMCIA

As of kernel 2.4 PCMCIA support is integrated into the kernel - that is:
the modules (drivers) are part of the kernel code distribution. You may
want to try that first. However, in some situations the integrated
support does not work. In many cases, you will still want to download
and install "Card Services for Linux" (`pcmcia-cs`).

The `cardctl` and `cardinfo` commands

The `cardctl` command can be used to check the status of a socket or to
see how it is configured. It can also be used to alter the cardctl
cardinfo configuration status of a card.

  -------------------- --------------------------------------------------------
  statusPCMCIAstatus   Display the current socket status flags.

  config               Display the socket configuration, including power
                       PCMCIAconfig settings, interrupt and I/O window settings
                       and configuration registers.

  ident                Display card identification information, including
                       PCMCIAident product identification strings, manufacturer
                       ID codes and function ID codes.

  suspend              Shut down and then disable power for a socket.
                       PCMCIAsuspend

  resume               Restore power to a socket and re-configure for use.
                       PCMCIAresume

  reset                Send a reset signal to a socket, subject to approval
                       PCMCIAreset by any drivers already bound to the socket.

  eject                Notify all client drivers that this card will be
                       PCMCIAeject ejected, then cut power to the socket.

  insert               Notify all client drivers that this card has
                       PCMCIAinsert just been inserted.

  scheme               If no scheme name is given, cardctl will display the
                       PCMCIAscheme current PCMCIA configuration scheme. If a
                       scheme name is given, cardctl will de-configure all
                       PCMCIA devices, and reconfigure for the new scheme.
  -------------------- --------------------------------------------------------

  : `cardctl` commands

If you are running X, the `cardinfo` utility produces a graphical
interface to most `cardctl` functions.

