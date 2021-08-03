##  Configuring RAID (204.1)


Candidates should be able to configure and implement software RAID. This
objective includes using and configuring RAID 0, 1, and 5.

###   Key Knowledge Areas

-   Software raid configuration files and utilities

###   Terms and Utilities

-   `mdadm`

-   `mdadm.conf`

-   `fdisk`

-   `/proc/mdstat`

###   What is RAID?

RAID stands for "Redundant Array of Inexpensive Disks".

The basic idea behind RAID is to combine multiple small, inexpensive
disk drives into an array which yields performance exceeding that of one
large and expensive drive. This array of drives will appear to the
computer as a single logical storage unit or drive.

Some of the concepts used in this chapter are important factors in
deciding which level of RAID to use in a particular situation. Parity is
a concept used to add redundancy to storage. A parity bit is a binary
digit which is added to ensure that the number of bits with value of one
in a given set of bits is always even or odd. By using part of the
capacity of the RAID for storing parity bits in a clever way, single
disk failures can happen without data-loss since the missing bit can be
recalculated using the parity bit. I/O transactions are movements of
data to or from a RAID device or its members. Each I/O transaction
consists of one or more blocks of data. A single disc can handle a
maximum random number of transactions per second, since the mechanism
has a seek time before data can be read or written. Depending on the
configuration of the RAID, a single I/O transaction to the RAID can
trigger multiple I/O transactions to its members. This affects the
performance of the RAID device in terms of maximum number of I/O
transactions and data transfer rate. Data transfer rate is the amount of
data a single disk or RAID device can handle per second. This value
usually varies for read and write actions, random or sequential access
etc.

RAID is a method by which information is spread across several disks,
using techniques such as disk striping (RAID Level 0), disk mirroring
(RAID level 1), and striping with distributed parity (RAID Level 5), to
achieve redundancy, lower latency and/or higher bandwidth for reading
and/or writing to disk, and maximize recoverability from hard-disk
crashes.

The underlying concept in RAID is that data may be distributed across
each drive in the array in a consistent manner. To do this, the data
must first be broken into consistently-sized chunks (often 32K or 64K in
size, although different sizes can be used). Each chunk is then written
to each drive in turn. When the data is to be read, the process is
reversed, giving the illusion that multiple drives are actually one
large drive. Primary reasons to use RAID include:

-   enhanced transfer speed

-   enhanced number of transactions per second

-   increased single block device capacity

-   greater efficiency in recovering from a single disk failure

####  RAID levels

There are a number of different ways to configure a RAID subsystem -
some maximize performance, others maximize availability, while others
provide a mixture of both. For the LPIC-2 exam the following are
relevant:

-   RAID-0 (striping)

-   RAID-1 (mirroring)

-   RAID-4/5

-   Linear mode

#### Level 0

RAID 0 striping RAID level 0, often called "striping", is a
performance-oriented striped data mapping technique. This means the data
being written to the array is broken down into strips and written across
the member disks of the array. This allows high I/O performance at low
inherent cost but provides no redundancy. Storage capacity of the array
is equal to the sum of the capacity of the member disks. As a result,
RAID 0 is primarily used in applications that require high performance
and are able to tolerate lower reliability.

#### Level 1

RAID 1 mirroring RAID level 1, or "mirroring", has been used longer than
any other form of RAID. Level 1 provides redundancy by writing identical
data to each member disk of the array, leaving a mirrored copy on each
disk. Mirroring remains popular due to its simplicity and high level of
data availability. Level 1 operates with two or more disks that may use
parallel access for high data-transfer rates when reading, but more
commonly operate independently to provide high I/O transaction rates.
Level 1 provides very good data reliability and improves performance for
read-intensive applications but at a relatively high cost. Array
capacity is equal to the capacity of the smallest member disk.

#### Level 4

RAID 4 RAID level 4 uses parity concentrated on a single disk drive to
protect data. It is better suited to transaction I/O rather than large
file transfers. Because the dedicated parity disk represents an inherent
bottleneck, level 4 is seldom used without accompanying technologies
such as write-back caching. Array capacity is equal to the capacity of
member disks, minus the capacity of one member disk.

#### Level 5

RAID 5 The most common type of RAID is level 5 RAID. By distributing
parity across some or all of the member disk drives of an array, RAID
level 5 eliminates the write bottleneck inherent in level 4. The only
bottleneck is the parity calculation process. Because the widespread use
of modern CPUs and software RAID that is not really an issue anymore. As
with level 4, the result is asymmetrical performance, with reads
substantially outperforming writes. Level 5 is often used with
write-back caching to reduce the asymmetry. The capacity of the array is
equal to the total capacity of all member disks, minus the capacity of
one member disk. Upon failure of a single member disk, subsequent reads
can be calculated from the distributed parity such that no data is lost.
RAID 5 requires at least three disks.

#### Linear RAID

Linear RAID is a simple grouping of drives to create a
larger virtual drive. In linear RAID the chunks are allocated
sequentially from one member drive, going to the next drive only when
the first is completely filled. The difference with "striping" is that
there is no performance gain for single process applications, mostly
everything is written to one and the same disk. The disk(partition)s can
have different sizes whereas "striping" requires them to be roughly the
same size. If you have a larger number of mostly used disks in a linear
RAID setup, multiple processes may benefit during reads as each process
may access a different drive. Linear RAID also offers no redundancy, and
in fact decreases reliability; if any one member drive fails, the entire
array cannot be used. The capacity is the total of all member disks.

RAID can be implemented either in *hardware* or in *software*; both
scenarios are explained below.

#### Hardware RAID

RAID hardware The hardware-based system manages the RAID subsystem
independently from the host and presents to the host only a single disk
per RAID array.

A typical hardware RAID device might connect to a SCSI controller and
present the RAID array(s) as a single SCSI drive. An external RAID
system moves all RAID handling intelligence into a controller located in
the external disk subsystem.

SCSI RAID controllers also come in the form of cards that act like a
SCSI controller to the operating system, but handle all of the actual
drive communications themselves. In these cases, you plug the drives
into the RAID controller just as you would a SCSI controller, but then
you add them to the RAID controller's configuration, and the operating
system never knows the difference.

#### Software RAID

Software RAID implements the various RAID
levels in the kernel disk (block device) code. It also offers the
cheapest possible solution: Expensive disk controller cards or hot-swap
chassis are not required, and software RAID works with cheaper SATA
disks as well as SCSI disks. With today's fast CPUs, software RAID
performance can excel in comparison with hardware RAID.

MD Software RAID allows you to dramatically increase Linux disk I/O
performance and reliability without having to buy expensive hardware
RAID controllers or enclosures. The MD driver in the Linux kernel is an
example of a RAID solution that is completely hardware independent. The
performance of a software-based array is dependent on the server CPU
performance and load. Also, the implementation and setup of the software
RAID solution can significantly influence performance.

The concept behind software RAID is simple - it allows you to combine
two (three, at least, for RAID5) or more block devices (usually disk
partitions) into a single RAID device. So if you have three empty
partitions (for example: `hda3`, `hdb3`, and `hdc3`), using Software
RAID you can combine these partitions and address them as a single RAID
device, `/dev/md0`. `/dev/md0` can then be formatted to contain a
filesystem and be used like any other partition.

#### Recognizing RAID on your Linux system

Detecting hardware raid on a Linux system can be tricky and there is not
one sure way to do this. Since hardware RAID tries to present itself to
the operating system as a single block device, it often shows up as a
single SCSI disc when querying the system. Often special vendor software
or physical access to the equipment is required to adequately detect and
identify hardware RAID equipment. Software raid can be easily identified
by the name of the block device (/dev/mdn) and its major number 9.

#### Configuring RAID (using `mdadm`) {#mdadm}

Configuring software RAID using `mdadm`
(Multiple Devices Admin) requires only that the md driver be configured
into the kernel, or loaded as a kernel module. The optional `mdadm.conf`
file may be used to direct `mdadm` in the simplification of common
tasks, such as defining multiple arrays, and defining the devices used
by them. The `mdadm.conf` has a number of possible options, described
later in this document, but generally, the file details arrays and
devices. It should be noted that, although not required, the
`mdadm.conf` greatly reduces the burden on administrators to "remember"
the desired array configuration when launching. The `mdadm` is used (as
its acronym suggests) to configure and manage multiple devices.
*Multiple* is key here. In order for RAID to provide any kind of
redundancy to logical disks, there must obviously be at the very least
two physical block devices (three for RAID5) in the array to establish
redundancy, ergo protection. Since `mdadm` manages multiple devices, its
application is not limited solely to RAID implementations, but may be
also be used to establish multi-pathing. `mdadm` has a number of modes,
listed below

#### Assemble

"Rebuilds" a pre existing array. Typically used when
migrating arrays to new hosts, but more often used from system startup
to launch a pre existing array., *Build* Does not create array
superblocks, and therefore does not destroy any pre existing data. May
be useful when attempting to recover or access stale data. (can not be
used in combination with `mdadm.conf `). Typically used with legacy
arrays, and rarely used., 

#### Create

Creates an array from scratch, using
pre-existing block devices, and activates the array., 

#### Grow


Used to
modify a existing array, for example adding, or removing devices.
Capability is expected to be extended during the development lifecycle
of the 2.6 kernel., 

#### Misc 

Used for performing various loosely bundled
housekeeping tasks. Can be used to generate the initial mdadm.conf file
for an existing array, setting the array into read only, and read/write
modes, and for checking the status of array devices. The more typical
uses are described in more detail later on in this section.

The
Linux kernel provides a special driver, `/dev/md0`, to access separate
disk partitions as a logical RAID unit. These partitions under RAID do
not actually *need* to be different disks, but in order to eliminate
risks it is better to use different disks. `mdadm` may also be used to
establish multipathing, also over filesystem devices (since multipathing
is established at the block level). However, as with establishing RAID
over multiple filesystems on the same physical disk, multipathing on the
same physical disk provides only the vague illusion of redundancy, and
its use should probably be restricted to test purposes only or out of
pure curiosity.

####  Setting up software RAID

Follow these steps to set up software RAID in Linux:

1.  Configure the RAID driver

2.  Initialise the RAID drive

3.  Check the replication using `/proc/mdstat`

4.  Automate RAID activation after reboot

5.  Mount the filesystem on the RAID drive

Each of these steps is now described in detail:

#### Initialize partitions to be used in the RAID setup

Create partitions using any disk partitioning tool.

#### Configure the driver

A driver file for each independant array will be automatically created
when `mdadm` creates the array, and will follow the convention
`/dev/md[n]` for each increment. It may also be manually created using
`mknod` and building a block device file, with a major number 9 (md
device driver found in `/proc/devices`).

#### Initialize RAID drive

Here is an example of the sequence of commands needed to create and
format a RAID drive:

1.  Prepare the partition for auto RAID detection using `fdisk`

    In order for a partition to be automatically recognised as part of a
    RAID set, it must first have its partition type set to "fd". This
    may be achieved by using the `fdisk` command menu, and using the `t`
    option to change the setting. Available settings may be listed by
    using the `l` menu option. The description may vary accross
    implementations, but should clearly show the type to be a Linux auto
    raid. Once set, the settings *must* be saved back to the partition
    table using the `w` option.

    In working practice, it may be that a physical disk containing the
    chosen partition for use in a RAID set also contains partitions for
    local filesystems which are not intended for inclusion within the
    RAID set. In order for `fdisk` to write back the changed partition
    table, all of the partitions on the physical disk must not be in
    use. For this reason, RAID build planning should take into account
    factors which may not allow the action to be performed truly online
    (i.e will require downtime).

2.  create the array raidset using `mdadm`

    To create an array for the first time, we need to have identified
    the partitions that will be used to form the RAIDset, and verify
    with `fdisk -l` that the fd partition type has been set. Once this
    has been achieved, the array may be created as follows. `mdadm` -C
    /dev/md0 -l raid5 -n 3 /dev/partition1 /dev/partition2
    /dev/partition3

    This would create, and activate a raid5 array called md0,containing
    three devices, named /dev/partition1 /dev/partition2, and
    /dev/partiton3. Once created and running, the status of the array
    may be checked by `cat`'ing `/proc/mdstat`.

3.  Create filesystems on the newly created raidset

    The newly created RAID set may then be addressed as a single device
    using the `/dev/md0` device file, and formatted and mounted as
    normal. For example: `mkfs.ext3` `/dev/md0`.

4.  create the `/etc/mdadm.conf` using the `mdadm` command.

    Creating the `/etc/mdadm.conf` file is pleasantly simple, requiring
    only that `mdadm` be called with the `--scan`, `--verbose`, and
    `--detail` options, and its standard output redirected. It may
    therefore also be used as a handy tool for determining any changes
    on the array simply by `diff`'ing the current and stored output.
    Create as follows:

    `mdadm` \--detail \--scan \--verbose \> `/etc/mdadm.conf`

5.  Create mount points and edit `/etc/fstab`

    Care must be taken that any recycled partitions used in the RAID set
    be removed from the `/etc/fstab` if they still exist.

6.  Mount filesystems using `mount`

    If the array has been created online, and a reboot has not been
    executed, then the file systems will need to be manually mounted,
    either manually using the `mount` command, or simply using
    `mount -a`

#### Check the replication using `/proc/mdstat`

The `/proc/mdstat` file shows the state of the kernels RAID/md driver.

#### Automate RAID activation after reboot

raidstart

Run `mdadm --assemble` in one of the startup files (e.g.
`/etc/rc.d/rc.sysinit` or `/etc/init.d/rcS`) When called with the `-s`
option (scan) to `mdadm
                --assemble`, instructs `mdadm` to use the
`/etc/mdadm.conf` if it exists, and otherwise to fallback to
`/proc/mdstat` for missing information. A typical system startup entry
could be for example, `mdadm --assemble -s`.

#### Mount the filesystem on the RAID drive

Edit `/etc/fstab` to automatically mount the filesystem on the RAID
drive. The entry in `/etc/fstab` is identical to normal block devices
containing file systems.

#### Manual RAID activation and mounting

Run `mdadm --assemble` for each RAID block device you want to start
manually. After starting the RAID device you can mount any filesystem
present on the device using `mount` with the appropriate options.

####  Configuring RAID (alternative)

Instead of managing RAID via `mdadm`, it can be configured via
`/etc/raidtab` and controlled via the `mkraid`, `raidstart`, and
`raidstop` utilities.

Here's an example `/etc/raidtab`:

        #
        # Sample /etc/raidtab configuration file
        #
        raiddev /dev/md0
          raid-level              0
          nr-raid-disks           2
          persistent-superblock   0
          chunk-size              8
      
          device                  /dev/hda1
          raid-disk               0
          device                  /dev/hdb1
          raid-disk               1

        raiddev /dev/md1
          raid-level              5
          nr-raid-disks           3
          nr-spare-disks          1
          persistent-superblock   1
          parity-algorithm        left-symmetric
      
          device                  /dev/sda1
          raid-disk               0
          device                  /dev/sdb1
          raid-disk               1
          device                  /dev/sdc1
          raid-disk               2
          device                  /dev/sdd1
          spare-disk              0
                

The `mkraid`, `raidstart`, and `raidstop` utilities all use this file as
input and respectively configure, activate (start) and unconfigure
(stop) RAID devices. All of these tools work similiarly. If -a (or
\--all) is specified, the specified operation is performed on all of the
RAID devices mentioned in the configuration file. Otherwise, one or more
RAID devices must be specified on the command line.

Refer to the manual pages for raidtab(8), mdstart(8) and raidstart,
raidstop(8) for details.


