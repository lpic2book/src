##  Adjusting Storage Device Access (204.2)

Candidates should be able to configure kernel options to support various
drives. This objective includes software tools to view and modify hard
disk settings including iSCSI devices.


###   Key Knowledge Areas

-   Tools and utilities to configure DMA for IDE devices including ATAPI
    and SATA

-   Tools and utilities to manipulate or analyse system resources (e.g.
    interrupts)

-   Awareness of `sdparm` command and its uses

-   Tools and utilities for iSCSI

-   SSD and NVMe configuration and awareness of SAN

###   Terms and Utilities

-   `hdparm`

-   `sdparm`

-   `tune2fs`

-   `sysctl`

-   `iscsiadm, scsi_id, iscsid` and `iscsid.conf`

-   `/dev/hd*` and `/dev/sd*`

-   WWID, WWN, LUN numbers

###  Configuring disks

####  Configuring iSCSI

iSCSI is an abbreviation of Internet Small Computer System Interface.
iSCSI is simply a networked implementation of the well-known
standardized SCSI protocol. SCSI defines a model, cabling, electrical
signals and commands to use to access various devices. iSCSI uses just
the model and the commands. SCSI (and hence: iSCSI) can be used to
access all kinds of devices and though mostly used for disks and
tape-units has been used to access USB storage, printers and flatbed
scanners too, just to name a few.

The iSCSI setup is similar to the SCSI setup as it consists of a client
and a server. In between is an IP based network, which can be a LAN, WAN
or the Internet. The client issues low level SCSI commands as usual
(e.g. `read`, `write`, `seek` or `erase`). The commands can be encrypted
by the client and are then encapsulated and sent over the network. The
server receives and possibly decrypts the commands and executes the
commands. Unlike traditional Fibre Channel, which requires
special-purpose cabling, iSCSI can be run over long distances using
existing network infrastructure.

Clients are refered to as "initiators". The commands are referred to as
"CDBs" (Command Descriptor Blocks) and the server storage devices are
known as "targets".

Definitions: iSCSI target, iSCSI initiator The exported storage entity
is the *target* and the importing entity is the *initiator*.

#### iSCSI Initiator

On Linux hosts that act as a client (initiator) to a iSCSI server
(target) you will need to install the client software. You will also
need to edit the configuration file so you can discover the desired
target(s). On Red Hat Linux and its derivatives the configuration file
is `/etc/iscsi/iscsid.conf`. Edit the file so it points to the proper
server (target) and contains a set of valid credentials - see example
file at the bottom of this segment.

After configuration, ensure that the iSCSI service runs using the
following command:

        /etc/init.d/iscsi status
                        

If needed start the iSCSI service using the following command:

        /etc/init.d/iscsi start
                        

iscsiadm Use the `iscsiadm` command to discover the targets. Where our
example shows questionmarks, substitute the IP address of the target:

        iscsiadm -m discovery -t sendtargets -p ???.???.???.???
                        

After successfully discovering targets you can log in into the volumes
that were discovered. This can be done with the `iscsiadm` tool, which
can also be used to log out of a volume. A fast way to add newly
discovered volumes is to restart the iscsi service:

        /etc/init.d/iscsi restart
                        

_Hint_:

When adding an iscsi mount point to the `fstab` file use the `_netdev`
option:

        /dev/sdb1 /mnt/iscsi ext3(4) _netdev 0 0
                            

The `_netdev` option ensures that the network is up before trying to
mount the device.


Example `/etc/iscsi/iscsid.config`:

        ###############
        # iSNS settings
        ###############
        # Address of iSNS server
        isns.address = ***.***.***.***
        isns.port = 3260

        # *************
        # CHAP Settings
        # *************

        # To enable CHAP authentication set node.session.auth.authmethod
        # to CHAP. The default is None.
        node.session.auth.authmethod = CHAP

        # To set a CHAP username and password for initiator
        # authentication by the target(s), uncomment the following lines:
        node.session.auth.username = ********
        node.session.auth.password = ********

        # To enable CHAP authentication for a discovery session to the target
        # set discovery.sendtargets.auth.authmethod to CHAP. The default is None.
        discovery.sendtargets.auth.authmethod = CHAP

        # To set a discovery session CHAP username and password for the initiator
        # authentication by the target(s), uncomment the following lines:
        discovery.sendtargets.auth.username = ********
        discovery.sendtargets.auth.password = ********
                        

#### iSCSI Target

There are a number of ways to set up a target. The SCSI Target Framework
(STGT/TGT) was the standard before linux 2.6.38. The current standard is
the LIO target.

Another well-known implementation was the iSCSI Enterprise Target (IET)
and its successor the SCSI Target Subsystem (SCST). IET was a candidate
for kernel inclusion too, but LIO was the final choice. LIO (an
abbreviation of linux-iscsi.org) now is the standard open-source SCSI
Target for shared data storage in Linux. It supports all prevalent
storage fabrics, including Fibre Channel (QLogic), FCoE, iEEE 1394,
iSCSI, iSER (Mellanox InfiniBand), SRP (Mellanox InfiniBand), USB,
vHost, etc.

####Adding a new target (on the target host)

To add a new iSCSI target edit the `/etc/tgt/targets.conf` configuration
file. This file contains many examples of different configuration
options that have been commented out. A basic target may be defined as:

        <target iqn.2008-09.com.example:server.target1>
            backing-store /srv/images/iscsi-share.img
            direct-store /dev/sdd
        </target>
                            

This example defines a single target with two LUNs. LUNs are described
with either the backing-store or direct-store directives where
backing-store refers to either a file or a block device, and
direct-store refers to local SCSI devices. Device parameters, such as
serial numbers and vendor names, will be passed through to the new iSCSI
LUN.

The target service is aptly named `tgtd`. To start it run:

        # service tgtd start
                            

To stop the `tgtd` service, run:

        # service tgtd stop
                            

If there are open connections, use:

        # service tgtd force-stop
        Warning Using this command will terminate all target arrays. 
                            

####  WWID

Any connected SCSI device is assigned a unique device name. The device
name begins with `/dev/sd`, for example `/dev/sdd`, `/dev/sda`.
Additionally, each SCSI device has a unique World Wide Identifier
(WWID). The identifier can be obtained from the device itself by issuing
the `inquiry` command. On Linux systems you can find the WWIDs in the
`/dev/disk/by-id/` directory, in which you will find symbolic links
whose names contain the WWID and which point to the assigned device
name. There are two types of WWIDs, known as 'page 0x83' and 'page
0x80' and any SCSI device has one of these.

For example, a device with a page 0x83 identifier would have:

        scsi-3600508b400105e210000900000490000 -> ../../sda
                        

Or, a device with a page 0x80 identifier would have:

        scsi-SSEAGATE_ST373453LW_3HW1RHM6 -> ../../sda
                        

Red Hat Enterprise Linux automatically maintains the proper mapping from
the WWID-based device name to a current `/dev/sd` name on that system.
Applications can use the `/dev/disk/by-id/` name to reference the data
on the disk, even if the path to the device changes, and even when
accessing the device from different systems. This also allows detection
and access to plugable devices, say a photocamera. If it is plugged in,
the system will sent a `inquiry` command and will create the proper
symbolic link, hence allowing you to access the camera under the same
name.

It is possible and feasible to have more than one path to a device, for
example to offer a fail-over or fall-back option and/or to increase
performance. Such "paths" might be implemented as additional network
paths (preferably using their own network card) or over fibre
(preferably using their own HBAs) etc. If there are multiple paths from
a system to a device, a special kernel-module and associated daemons and
other software will use the WWID to detect the paths. A single
"pseudo-device" in `/dev/mapper/wwid` will be created by them, such as
`/dev/mapper/3600508b400105df70000e00000ac0000`, which will give access
to the device, regardless which path(s) to it there are in use, as long
as at least one of them can be used ('is active').

The command `multipath -l` shows the mapping to the non-persistent
identifiers: Host:Channel:Target:LUN, `/dev/sd` name, and the
major:minor number:

        3600508b400105df70000e00000ac0000 dm-2 vendor,product 
        [size=20G][features=1 queue_if_no_path][hwhandler=0][rw] 
        \_ round-robin 0 [prio=0][active] 
        \_ 5:0:1:1 sdc 8:32  [active][undef] 
        \_ 6:0:1:1 sdg 8:96  [active][undef]
        \_ round-robin 0 [prio=0][enabled] 
        \_ 5:0:0:1 sdb 8:16  [active][undef] 
        \_ 6:0:0:1 sdf 8:80  [active][undef]
                        

Device-mapper-multipath automatically maintains the proper mapping of
each WWID-based device name to its corresponding `/dev/sd` name on the
system. These names are persistent a cross path changes, and they are
consistent when accessing the device from different systems. When the
user\_friendly\_names feature (of device-mapper-multipath) is used, the
WWID is mapped to a name of the form `/dev/mapper/mpathn`. By default,
this mapping is maintained in the file `/etc/multipath/bindings`. These
`mpath` names are persistent as long as the file is maintained.

**Note**
Important If you use user\_friendly\_names, then additional steps are
required to obtain consistent names in a cluster. Refer to the
Consistent Multipath Device Names in a Cluster section in the Using DM
Multipath Configuration and Administration book.

####  LUN

Another way to address a SCSI device is by using its LUN, the Logical
unit number. The LUN is a three bit number (0..7) which indicates a
device within a target. Any target should at least have a device with
LUN 0, which can be used like any device, but is also capable of
providing information about the other LUNs in the device (if any). If
there is just one device in a target that device has LUN 0 as any target
should have a LUN 0.

Say you bought a SCSI device that contained three disks (all connected
over the same SCSI cable). To find out how many disks there are in your
target (or tape units etc.) you would sent an inquiry to LUN 0. The
device that has LUN 0 is designed to be able to tell you the
configuration and might report that it knows of other devices. To
address these the client uses the LUNs as specified by LUN 0.

Because SCSI disks were often refered to by their LUN, the habit stuck
and nowadays the term is also used to refer to a logical disk in a SAN.
But there can be many more LUNs in a SAN than the humble 7 that are used
in older configurations. Also, such a SAN-LUN may well consist of series
of disks, which might possibly be configured as a RAID, possibly
subdivided in volumes etc. - to the client, it is just a disk with a
LUN.

#### Configuring device name persistence (aka LUN persistence)

Linux device names may change upon boot. This can lead to confusion and
damage to data. Therefore, there are a number of techniques that allow
persistent names for devices. This section covers how to implement
device name persistence in guests and on the host machine with and
without multipath. Persistence simply means that you will have the same
name for the device, regardles its access paths. So, your camera or disk
is always recognised as such and will be issued the same device name,
regardless where you plug it in.

####Implementing device name persistence without multipath

If your system is not using multipath, you can use `udev` to implement
LUN persistence. `udev` is a device manager that listens to an interface
with the kernel. If a new device is plugged in or a device is being
detached, `udev` will receive a signal from the kernel and, using a set
of rules, will perform actions, for example assign an additional device
name to the device.

Before implementing LUN persistence in your system you will first need
to acquire the proper WWIDs from the devices you want to control. This
can be done by using the `scsi_id` program. After you required the WWIDs
of your devices, you will need to write a rule so `udev` can assign a
persistent name to it.

scsi\_id A minor hurdle has to be taken first. The `scsi_id` program
will not list any device by default and will only list devices it has
been told to see ('whitelisted' devices). To whitelist a device you
will need to add its WWID to the `scsi_id` configuration file, which is
`/etc/scsi_id.conf`. That's safe, but a nuisance if you want to
discover WWIDs of new devices. Hence you can specify the `-g` option to
allow detection of any disk that has not been listed yet. If you feel
that this should be the default behaviour, you may consider editing
`/etc/scsi_id.conf`. If there is a line that says:

        options=-b
                                

delete it or comment it out. Then add a line that says:

        options=-g
                                

If this has been configured, next time a program uses the `scsi_id`
command, it will add the `-g` option (and any other options you might
have specified in the configuration file) and hence allow extracting the
WWIDs from new devices. The `-g` should be used either by default from
the configuration file or be set manually in any `udev` rule that uses
the `scsi_id` command, or else your newly plugged in device won't be
recognised.

You then will need to find out what device file your new device was
allocated by the kernel. This is routinely done by using the command
`dmesg` after you plugged in the new device. Typically, you will see
lines similar to these:

        usb 1-5: new high speed USB device using ehci_hcd and address 25
        usb 1-5: configuration #1 chosen from 1 choice
        scsi7 : SCSI emulation for USB Mass Storage devices
        usb-storage: device found at 25
        usb-storage: waiting for device to settle before scanning
          Vendor: USB       Model: Flash Disk        Rev: 8.07
          Type:   Direct-Access                      ANSI SCSI revision: 04
        SCSI device sdc: 7886848 512-byte hdwr sectors (4038 MB)
                                

As you see, we plugged in a 4Gb Flash Disk that was assigned the device
name 'sdc'. This device is now available as `/sys/block/sdc` in the
`/sys` pseudo-filesystem, and also as a devicefile `/dev/sdc`.

To determine the device WWID, use the `scsi_id` command:

        # scsi_id -g -u -s /block/sdc
        3200049454505080f
                                

As you see, we used the `-g` forcibly. The `-s` option specifies that
you want to use the device name relative to the root of the `sysfs`
filesystem (`/sys`). Newer versions of scsi\_id (e.g. those in RHEL6) do
not allow use of `sysfs` names anymore, so should use the device name
then:

        /sbin/scsi_id -g -u -d /dev/sdc
        3200049454505080f
                                

The long string of characters in the output is the WWID. The WWID does
not change when you add a new device to your system. Acquire the WWID
for each device in order to create rules for the devices. To create new
device rules, edit the `20-names.rules` file in the `/etc/udev/rules.d`
directory. The device naming rules follow this format:

        KERNEL="sd<?>",  BUS="scsi",  PROGRAM="<scsi_id -options..>", RESULT="<WWID>", NAME="<devicename>"
                                

So, when you plug in a new device the kernel will signal `udev` it found
a new SCSCI device. the PROGRAM will be executed and the RESULT should
match. If so, the NAME will be used for the device file.

An example would be:

        KERNEL="sd*",  BUS="scsi",  PROGRAM="/sbin/scsi_id -g -u -d /dev/$parent", RESULT="3200049454505080f", NAME="bookone"
                                

Or on RHEL6 systems:

        KERNEL="sd*",  BUS="scsi",  PROGRAM="/sbin/scsi_id -g -u -s /block/$parent", RESULT="3200049454505080f", NAME="bookone"
                                

When the kernel allocates a new device which name matches the KERNEL
pattern, the PROGRAM is executed and when the RESULT is found the NAME
is created. Note the `-g` option that we have included so we can
actually see the device, though it is not whitelisted.

The `udevd` daemon is typically started by the execution of a local
startup script, normally done by the `init` process and initiated by a
line in the `/etc/inittab` file. On older systems you would ensure that
this line was in `/etc/rc.local`:

        /sbin/start_udev
                                

On some systems, e.g. RHEL6 the line should be in `/etc/rc.sysinit`.

####Implementing device name persistence with multipath

You can implement device name persistence by using the `multipath`
drivers and software. Of course, normally you would only use this if you
have more than one path to your device. But you can actually define a
`multipath` with only has one active path, and it will work just like
any other disk. Just define an alias and the name will be persistent
across boots.

The `multipath` software consists of a daemon, that guards the paths to
the various devices. It executes the external command `multipath` on
failure. The `multipath` command in turn will signal the daemon after it
has reconfigured paths.

To implement LUN persistence in a multipath environment, you can define
an alias name for the `multipath` device. Edit the device aliases in the
configuration file of the `multipath` daemon, `/etc/multipath.conf`:

        multipaths {
            multipath  {  
                wwid       3600a0b80001327510000015427b625e
                alias      backupdisk
            }
        }
                                

This defines a device that has a persistent device file
`/dev/mpath/backupdisk`. That will grant access to the device - whatever
its name - that has WWID 600a0b80001327510000015427b625e. The alias
names are persistent across reboots.

###   Physical installation

To install a new disk in your
system, you will need to physically install the hard drive and configure
it in your computer's BIOS. Linux will detect the new drive
automatically in most cases. You could type `dmesg | more` to find out
the name and device file of the drive. As an example: the second IDE
drive in your system will be named `/dev/hdb`. We will assume that the
new drive is `/dev/hdb`.

On older kernels IDE devicenames match the pattern `/dev/hd[a-d]`, where
a is used for the primary master IDE device, b is the primary slave, c
the secondary master and d is the secondary slave IDE device. For
PATA/SATA drives the Linux SCSI driver is used as the PATA/SATA
architecture is similar to that of SCSCI. Newer devices hence have
device files that match the pattern `/dev/sd*`.

After installation of your disk and it being recognised by the
kernel you can choose to (re)partition your new disk. As `root` in a
shell type:

        fdisk /dev/hdb 
                    

This will take you to a prompt

        Command (m for help):
                    

At the prompt, type `p` to display the existing partitions. If you have
partitions that you need to delete, type `d`, then at the prompt, type
the number of the partition that you wish to delete. Next, type `n` to
create the new partition. Type `1` (assuming that this will be the first
partition on the new drive), and hit `enter`. Then you will be prompted
for the cylinder that you want to start with on the drive. Next, you
will be asked for the ending cylinder for the partition. Repeat these
steps until all partitions are created.

To put a clean filesystem on the first partition of your newly
partitioned drive, type:

        mkfs /dev/hdb1 
                    

Repeat this step for all partitions. You can use the `-t` parameter to
define the filesystem type to build, e.g. `ext2`, `ext3`, `xfs`, `minix`
etc. ([???](#creating-filesystems)).

You will now need to decide the mount point for each new
partition on your drive. We will assume `/new`. Type:

        mkdir /new 
                    

to create the mount point for your drive. Now you will need to edit
`/etc/fstab`. You will want to make an entry at the end of the file
similar to this:

        /dev/hdb1       /new     ext2          defaults       1   1
                    

Modern SSDs (Solid State Disks) might profit from some optimisation.
SSDs are very fast compared to standard harddisks with platters but
they have a bigger chance of suffering from bad blocks after many
rewrites to blocks. An SSD can use TRIM to discard those blocks
efficiently. `noatime` or `relatime` can also be used to reduce the
amount of writes to disk. This will tell the filesystem not to keep
track of last accessed times, but only last modified times. In
`/etc/fstab` it would look like:

        /dev/hdb1        /new     ext4    discard,noatime       1      1
                    

NVM Express (NVMe) is a specification for accessing SSDs attached
through the PCI Express bus. The Linux NVMe driver is included in kernel
version 3.3 and higher. NVMe devices can be found under `/dev/nvme*`.
NVMe devices are a family of SSD's thatshould not be issued discards.
Discards are usualy disabled on setups that use ext4 and LVM, but other
filesystems might need discards to be disabled explicitly.

         /dev/nvme0n1p1  /new     ext4 defaults 0 0
                    

Moving your `/tmp` partition to memory (tmpfs) is another way to reduce
disk writes. This is advisable if your system has enough memory. Add the
following entry to `/etc/fstab`:

        none             /tmp/                   tmpfs   size=10%                 0       0
                    

After you have created a similar entry for each partition, write the
file.

        mount -a 
                    

will mount the partitions in the directory that you specified in
`/etc/fstab`.

###   Using `tune2fs`

When a kernel interacts with ext2 or ext3 filesystems the
`tune2fs` command can be used to configure the interaction. Noteworthy
options of this command are:

-e error\_behaviour

-   This option defines how the kernel should react in case of errors on
    the filesystem to which this command is applied. Possible behaviours
    are:

    continue

    :   Ignore the error on the filesystem. Report the read or write
        error to the application that tries to access that part of the
        filesystem.

    remount-ro

    :   Remount the filesystem as read-only. This secures data that is
        already on disc. Applications that try to write to this
        filesystem will result in error.

    panic

    :   This causes a kernel panic and the system will halt.

-m reserved\_block\_percentage

-   Full filesystems have very bad performance due to fragmentation. To
    prevent regular users from filling up the whole filesystem a
    percentage of the blocks will be reserved. This reserved part cannot
    be used by regular users. Only the root user can make use this part
    of the filesystem.

    The default percentage of the reserved blocks is 5%. With disks
    becoming ever larger, setting aside 5% would result in a large
    number of reserved blocks. For large disks 1% reserved blocks should
    be sufficient for most filesystems.

-O \[\^\]mount\_option

-   This sets the mount options of the filesystem. Command line options
    or options in `/etc/fstab` take precedence. The \^-sign clears the
    specified option.

    This option is supported by kernel 2.4.20 and above.

-s \[0\|1\]

-   Enable or disable the sparse superblock feature. Enabling this
    feature on large filesystems saves space, because less superblocks
    are used.

    After enabling or disabling this feature the filesystem must be made
    valid again by running the `e2fsck` command.

###   Using `hdparm`

The `hdparm` command is used to set/get SATA/IDE device
parameters. It provides a command line interface to various kernel
interfaces supported by the Linux SATA/PATA/SAS "libata" subsystem and
the older IDE driver subsystem. Newer (from 2008) USB disk enclosures
now support "SAT" (SCSI-ATA Command Translation) so they might also work
with `hdparm`.

The syntax for this command is:

        hdparm [options] [device]
                

Frequently used options are:

-a

-   Get or set the sector count for filesystem read-ahead.

-d \[0\|1\]

-   Get or set the `using_dma` flag.

-g

-   Display drive geometry.

-i

-   Display identification information.

-r \[0\|1\]

-   Get (1) or set (0) the read-only flag.

-t

-   Perform device read for benchmarking.

-T

-   Perform device cache read for benchmarking.

-v

-   Display all settings, except -i.

See also `man hdparm` for more information.

###   Using `sdparm`

The `sdparm` command is used to access SCSI mode pages, read VPD
(Vital Product Data) pages and send simple SCSI commands.

The utility fetches and can change SCSI device mode pages. Inquiry data
including Vital Product Data pages can also be displayed. Commands
associated with starting and stopping the medium; loading and unloading
the medium; and other housekeeping functionality may also be issued by
this utility.

###   Configuring kernel options

In [???](#lpic2.201.1) and on, the process to configure and debug
Configuring Linux kernel options kernels is described. Additional kernel
options may be configured by patching the kernel source code. Normally
the kernel's tunable parameters are listed in the various header files
in the source code tree. There is no golden rule to apply here - you
need to read the kernel documentation or may even need to crawl through
the kernel-code to find the information you need. Additionally, a
running kernel can be configured by either using the `/proc` filesystem
or by using the `sysctl` command.

###   Using the `/proc` filesystem

Current kernels also support dynamic setting of kernel parameters. The
/proc easiest method to set kernel parameters is by modifying the
`/proc` filesystem. You can use the `echo` command to set parameters, in
the format:

        # echo value > /proc/kernel/parameter 
                    

e.g. to activate IP-forwarding:

        # echo 1 >/proc/sys/net/ipv4/ip_forward
                    

The changes take effect immediately but are lost during reboot.
/proc/sys/net/ipv4/ip\_forward

The `/proc/` filesystem can also be queried. To see which interrupts a
system uses, for example you could issue /proc/interrupts

        # cat /proc/interrupts
                    

which generates output that may look like this:

                   CPU0       
          0:   16313284          XT-PIC  timer
          1:     334558          XT-PIC  keyboard
          2:          0          XT-PIC  cascade
          7:      26565          XT-PIC  3c589_cs
          8:          2          XT-PIC  rtc
          9:          0          XT-PIC  OPL3-SA (MPU401)
         10:          4          XT-PIC  MSS audio codec
         11:          0          XT-PIC  usb-uhci
         12:     714357          XT-PIC  PS/2 Mouse
         13:          1          XT-PIC  fpu
         14:     123824          XT-PIC  ide0
         15:          7          XT-PIC  ide1
        NMI:          0
                    

On multicore systems you will see multiple CPU-columns, e.g. CPU0..CPU3
for a four core system. The interrupts are delivered to core 0 by
default. This can create a performance bottleneck, especially on
networked storage systems. As CPU0 gets swamped by IRQ's the system
feels sluggish, even when the other cores have almost nothing to do.
Newer kernels try to load balance the interrupts. But you can override
the defaults and choose which core will handle which interrupt. The
procedure is listed in the next paragraph.

Each interrupt listed in the `/proc/interrupts` file has a subdirectory
in the `/proc/irq/` tree. So, interrupt 12 corresponds to the directory
`/proc/irq/12`. In that directory the file `smp_affinity` contains data
that describes what core handles the interrupt. The file contains a
bitmask that has one bit per core. By setting the proper bit the APIC
chip will deliver the interrupt to the corresponding core, e.g. 2
selects CPU1, 4 selects CPU2, 8-3, 16-4.. etc. To set for example CPU5
to receive all interrupts \#13, do:

        # echo 32 >/proc/irq/13/smp_affinity
                    

By carefully selecting which interrupts go to which processor you can
dramatically influence the performance of a busy system.

###   Using `sysctl`

Kernel tuning can be automated by putting the `sysctl` commands
in the startup scripts (e.g. `/etc/sysctl.d/99-sysctl.conf`. The
`sysctl` command is used to modify kernel parameters at runtime. The
parameters that can be modified by this command are listed in the
`/proc/sys` directory tree. Procfs is required for `sysctl` support
under Linux. `sysctl` can be used to read as well as write kernel
parameters.

Frequently used options of the `sysctl` command are:

`-a`; `-A`

-   Display all values currently available.

`-e`

-   Use this option to ignore errors about unknown keys.

`-n`

-   Use this option to disable printing of the key name when printing
    values.

`-p`

-   Load sysctl settings from the file specified, or /etc/sysctl.conf if
    none given. Specifying `-` as filename means reading data from
    standard input.

`-w`

-   Use this option to change a sysctl setting.
