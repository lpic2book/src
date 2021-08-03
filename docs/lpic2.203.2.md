##  Maintaining a Linux Filesystem (203.2)

Candidates should be able to properly maintain a Linux filesystem using
system utilities. This objective includes manipulating standard
filesystems and monitoring SMART devices.

Resources: [???](#bandel97); [???](#btrfs); the `man` pages for
`e2fsck`, `badblocks`, `dumpe2fs`, `debugfs` and `tune2fs`.

###   Key Knowledge Areas

-   Tools and utilities to manipulate ext2, ext3 and ext4.

-   Tools and utilities to perform Btrfs operations, including
    subvolumes and snapshots.

-   Tools and utilities to manipulate xfs.

-   Awareness of ZFS.

###   Terms and Utilities

-   `fsck (fsck.*)`

-   `mkfs (mkfs.*)`

-   `mkswap`

-   `tune2fs`

-   `dumpe2fs`

-   `debugfs`

-   `btrfs`

-   `btrfs-convert`

-   `xfs_info`, `xfs_check`, `xfs_repair`, `xfs_dump` and `xfs_restore`

-   `smartd` and `smartctl`

###   Disk Checks

Good disk maintenance requires periodic disk checks. Your best tool is
`fsck`, and should be run at least fsck monthly. Default checks will
normally be run after 20 system reboots, but if your system stays up for
weeks or months at a time, you'll want to force a check from time to
time. Your best bet is performing routine system backups and checking
your `lost+found` directories from time to time.

The frequency of the checks at system reboot can be changed with
`tune2fs`. This utility can also be used to tune2fs change the mount
count, which will prevent the system from having to check all
filesystems at the 20th reboot (which can take a long time).

The `dumpe2fs` utility will provide important dumpe2fs information
regarding hard disk operating parameters found in the superblock, and
`badblocks` will perform surface checking. Finally, surgical procedures
to remove areas grown bad on the disk can be accomplished using
`debugfs`. debugfs

####  fsck (fsck.\*)

`fsck` is a utility to check and repair a fsck Linux filesystem. In
actuality `fsck` is simply a front-end for the various filesystem
checkers (`fsck.fstype`) available under Linux.

`fsck` is called automatically at system startup. If the filesystem is
marked "not clean", or the maximum mount count is reached or the time
between checks is exceeded, the filesystem is checked. To change the
maximum mount count or the time between checks, use `tune2fs`.

Frequently used options to `fsck` include:

`-s`

-   Serialize `fsck` operations. This is a fsck-a good idea if you're
    checking multiple filesystems and the checkers are in an interactive
    mode.

`-A`

-   Walk through the `/etc/fstab` file fsck-A and try to check all
    filesystems in one run. This option is typically used from the
    /etc/rc system initialization file, instead of multiple commands for
    checking a single filesystem.

    The root filesystem will be checked first. After that, filesystems
    will be checked in the order specified by the `fs_passno` (the
    sixth) field in the `/etc/fstab` file. Filesystems with a
    `fs_passno` value of 0 are skipped and are not checked at all. If
    there are multiple filesystems with the same pass number, fsck will
    attempt to check them in parallel, although it will avoid running
    multiple filesystem checks on the same physical disk.

`-R`

-   When checking all filesystems with the -A flag, skip fsck-R the root
    filesystem (in case it's already mounted read-write).

Options which are not understood by fsck are passed to the
filesystem-specific checker. These arguments(=options) must not take
arguments, as there is no way for fsck to be able to properly guess
which arguments take options and which don't. Options and arguments
which follow the `--` are treated as filesystem-specific options to be
passed to the filesystem-specific checker.

The filesystem checker for the ext2 filesystem is called `fsck.e2fs` or
`e2fsck`. Frequently used options include:

`-a`

-   This option does the same thing as the `-p` option. It is provided
    for backwards compatibility only; it is suggested that people use -p
    option whenever possible.

`-c`

-   This option causes e2fsck to run the fsck-c `badblocks(8)` program
    to find any badblocks blocks which are bad on the filesystem, and
    then marks them as bad by adding them to the bad block inode.

`-C`

-   This option causes e2fsck to write completion fsck-C information to
    the specified file descriptor so that the progress of the filesystem
    check can be monitored. This option is typically used by programs
    which are running e2fsck. If the file descriptor specified is 0,
    e2fsck will print a completion bar as it goes about its business.
    This requires that e2fsck is running on a video console or terminal.

`-f`

-   Force checking even if the filesystem seems clean. fsck-f

`-n`

-   Open the filesystem read-only, and assume an answer of fsck-n "no"
    to all questions. Allows e2fsck to be used non-interactively. (Note:
    if the -c, -l, or -L options are specified in addition to the -n
    option, then the filesystem will be opened read-write, to permit the
    bad-blocks list to be updated. However, no other changes will be
    made to the filesystem.)

`-p`

-   Automatically repair (\"preen\") the filesystem without fsck-p any
    questions.

`-y`

-   Assume an answer of "yes" to all questions; allows fsck-y `e2fsck`
    to be used non-interactively.

####  mkfs (mkfs.\*) {#mkfs}

mkfs The `mk2fs` command is used to create a Linux filesystem. It can
create different types of filesystems by specifying the `-t filesystem `
or by giving the `mkfs.filesystem` command. Actually `mkfs` is a
front-end for the several `mkfs.fstype` commands. Please read the mkfs
man pages and section for more information. [???](#creating-filesystems)

####  tune2fs

`tune2fs` is used to "tune" a tune2fs filesystem. This is mostly used to
set filesystem check options, such as the `maximum mount count` and the
`time between filesystem checks`.

It is also possible to set the `mount count` to a specific value. This
can be used to 'stagger' the mount counts of the different
filesystems, which ensures that at reboot not all filesystems will be
checked at the same time.

So for a system that contains 5 partitions and is booted approximately
once a month you could do the following to stagger the mount counts:

        tune2fs -c 5 -C 0
        partition1
        tune2fs -c 5 -C 1
        partition2
        tune2fs -c 5 -C 2
        partition3
        tune2fs -c 5 -C 3
        partition4
        tune2fs -c 5 -C 4
        partition5
                

The maximum mount count is 20, but for a system that is not mount count
frequently rebooted a lower value is advisable.

Frequently used options include:

`-c max-mount-counts`

-   Adjust the maximum mount count between two filesystem tunefs-c
    checks. If max-mount-counts is 0 then the number of times the
    filesystem is mounted will be disregarded by e2fsck(8) and the
    kernel. Staggering the mount-counts at which filesystems are
    forcibly checked will avoid all filesystems being checked at one
    time when using journalling filesystems.

    You should strongly consider the consequences of disabling
    mount-count-dependent checking entirely. Bad disk drives, cables,
    memory and kernel bugs could all corrupt a filesystem without
    marking the filesystem dirty or in error. If you are using
    journalling on your filesystem, your filesystem will never be marked
    dirty, so it will not normally be checked. A filesystem error
    detected by the kernel will still force an fsck on the next reboot,
    but it may already be too late to prevent data loss at that point.

`-C mount-count`

-   Set the number of times the filesystem has been tunefs-C mounted.
    Can be used in conjunction with -c to force an fsck on the
    filesystem at the next reboot.

`-i interval-between-checks[d|m|w]`

-   Adjust the maximal time between two filesystem tunefs-i checks. No
    suffix or d result in days, m in interval between checks months, and
    w in weeks. A value of zero will disable the time-dependent
    checking.

    It is strongly recommended that either -c (mount-count-dependent) or
    -i (time-dependent) checking be enabled to force periodic full
    e2fsck(8) checking of the filesystem. Failure to do so may lead to
    filesystem corruption due to bad disks, cables or memory or kernel
    bugs to go unnoticed, until they cause data loss or corruption.

`-m reserved-blocks-percentage`

-   Set the percentage of reserved filesystem blocks. tunefs-m reserved
    blocks

`-r reserved-blocks-count`

-   Set the number of reserved filesystem blocks. tunefs-r

####  dumpe2fs

`dumpe2fs` prints the super block and blocks dumpe2fs group information
for the filesystem present on device.

`-b`

-   print the blocks which are reserved as bad in the filesystem.

`-h`

-   only display the superblock information and not any of the block
    group descriptor detail information.

####  badblocks

`badblocks` is a Linux utility to check for damaged sectors on a disk
drive. It marks these sectors so that they are not used in the future
and thus do not cause corruption of data. It is part of the e2fsprogs
project.

It is strongly recommended that badblocks not be run directly but to
have it invoked through the `-c` option in `e2fsck` or `mke2fs`. A
commonly used option is:

`-o output-file`

-   write the list of bad blocks to `output-file`.

####  debugfs

With `debugfs`, you can modify the disk with direct disk writes. Since
this utility is so powerful, you will normally want to invoke it as
read-only until you are ready to actually make changes and write them to
the disk. To invoke `debugfs` in read-only mode, do not use any options.
To open in read-write mode, add the `-w` option. You may also want to
include in the command line the device you wish to work on, as in
`/dev/hda1` or `/dev/sda1`, etc. Once it is invoked, you should see a
debugfs prompt.

When the superblock of a partition is damaged, you can specify
superblock location a different superblock to use:

        debugfs -b 1024 -s 8193 /dev/hda1
                

This means that the superblock at block 8193 will be used and the
blocksize is 1024. Note that you have to specify the blocksize when you
want to use a different superblock. The information about blocksize and
backup superblocks can be found with:

        dumpe2fs /dev/hda1
                

The first command to try after invocation of `debugfs`, is `params` to
show the mode (read-only or read-write), and the current file system. If
you run this command without opening a filesystem, it will almost
certainly dump core and exit. Two other commands, `open` and `close`,
may be of interest when checking more than one filesystem. Close takes
no argument, and appropriately enough, it closes the filesystem that is
currently open. Open takes the device name as an argument. To see disk
statistics from the superblock, the command `stats` will display the
information by group. The command `testb` checks whether a block is in
use. This can be used to test if any data is lost in the blocks marked
as "bad" by the `badblocks` command. To get the filename for a block,
first use the `icheck` command to get the inode and then `ncheck` to get
the filename. The best course of action with bad blocks is to mark the
block "bad" and restore the file from backup.

To get a complete list of all commands, see the man page of `debugfs` or
type `?`, `lr` or `list_requests`.

####  ext4 {#ext4fs}

Ext4 is the evolution of the most used Linux filesystem, Ext3. In many
ways, Ext4 is a deeper improvement over Ext3 than Ext3 was over Ext2.
Ext3 was mostly about adding journaling to Ext2, but Ext4 modifies
important data structures of the filesystem such as the ones destined to
store the file data. The result is a filesystem with an improved design,
better performance, reliability, and features. Therefore converting ext3
to ext4 is not as straightforward and easy as it was converting ext2 to
ext3.

To creating ext4 partitions from scratch, use:

        mkfs.ext4 /dev/sdxY
                

**Note**
Tip: See the mkfs.ext4 man page for more options; edit
`/etc/mke2fs.conf` to view/configure default options.


Be aware that by default, mkfs.ext4 uses a rather low bytes-per-inode
ratio to calculate the fixed amount of inodes to be created.

**Note**
Note: Especially for contemporary HDDs (750 GB+) this usually results in
a much too large inode number and thus many likely wasted GB. The ratio
can be set directly via the -i option; one of 6291456 resulted in 476928
inodes for a 2 TB partition.


For the rest ext4 can be manipulated using all the same tools that are
available for ext2/ext3 type of filesystems like badblocks, dumpe2fs,
e2fsck and tune2fs.

####  btrfs

Btrfs (abbreviation for: *BTree File System*)is a new copy on write
(CoW) filesystem for Linux aimed at implementing advanced features while
focusing on fault tolerance, repair and easy administration. Jointly
developed at Oracle, Red Hat, Fujitsu, Intel, SUSE, STRATO and many
others, Btrfs is licensed under the GPL and open for contribution from
anyone. Btrfs has several features characteristic of a storage device.
It is designed to make the file system tolerant of errors, and to
facilitate the detection and repair of errors when they occur. It uses
checksums to ensure the validity of data and metadata, and maintains
snapshots of the file system that can be used for backup or repair. The
core datastructure used by btrfs is the *B-Tree* - hence the name.

**Note**
Btrfs is still under heavy development, but every effort is being made
to keep the filesystem stable and fast. Because of the speed of
development, you should run the latest kernel you can (either the latest
release kernel from kernel.org, or the latest -rc kernel.


As of the beginning of the year 2013 Btrfs was included in the default
kernel and its tools (btrfs-progs) are part of the default installation.
GRUB 2, mkinitcpio, and Syslinux have support for Btrfs and require no
additional configuration.

The main Btrfs features available at the moment include:

-   Extent based file storage

-   2\^64 byte == 16 EiB maximum file size

-   Space-efficient packing of small files

-   Space-efficient indexed directories

-   Dynamic inode allocation

-   Writable snapshots, read-only snapshots

-   Subvolumes (separate internal filesystem roots)

-   Checksums on data and metadata (crc32c)

-   Compression (zlib and LZO)

-   Integrated multiple device support

-   File Striping, File Mirroring, File Striping+Mirroring, Striping
    with Single and Dual Parity implementations

-   SSD (Flash storage) awareness (TRIM/Discard for reporting free
    blocks for reuse) and optimizations (e.g. avoiding unnecessary seek
    optimizations, sending writes in clusters, even if they are from
    unrelated files. This results in larger write operations and faster
    write throughput)

-   Efficient Incremental Backup

-   Background scrub process for finding and fixing errors on files with
    redundant copies

-   Online filesystem defragmentation

-   Offline filesystem check

-   Conversion of existing ext3/4 file systems

-   Seed devices. Create a (readonly) filesystem that acts as a template
    to seed other Btrfs filesystems. The original filesystem and devices
    are included as a readonly starting point for the new filesystem.
    Using copy on write, all modifications are stored on different
    devices; the original is unchanged.

-   Subvolume-aware quota support

-   Send/receive of subvolume changes

-   Efficient incremental filesystem mirroring

The most notable (unique) btrfs features are:

#### RAID functionality

-   A Btrfs filesystem provides support for integrated RAID
    functionality, and can be created on top of many devices. More
    devices can be added after the filesystem is created. By default,
    metadata will be mirrored across two devices and data will be
    striped across all of the devices present. If only one device is
    present, metadata will be duplicated on that one device.

    Btrfs can add and remove devices online, and freely convert between
    RAID levels after the filesystem is created. Btrfs supports raid0,
    raid1, raid10, raid5 and raid6, and it can also duplicate metadata
    on a single spindle. When blocks are read in, checksums are
    verified. If there are any errors, Btrfs tries to read from an
    alternate copy and will repair the broken copy if the alternative
    copy succeeds.

    `mkfs.btrfs` will accept more than one device on the command line.
    It has options to control the raid configuration for data (-d) and
    metadata (-m). Valid choices are raid0, raid1, raid10 and single.
    The option -m single means that no duplication of metadata is done,
    which may be desired when using hardware raid. here some examples on
    creating the filesystem.

            # Create a filesystem across four drives (metadata mirrored, linear data allocation)
            mkfs.btrfs /dev/sdb /dev/sdc /dev/sdd /dev/sde

            # Stripe the data without mirroring
            mkfs.btrfs -d raid0 /dev/sdb /dev/sdc

            # Use raid10 for both data and metadata
            mkfs.btrfs -m raid10 -d raid10 /dev/sdb /dev/sdc /dev/sdd /dev/sde

            # Don't duplicate metadata on a single drive (default on single SSDs)
            mkfs.btrfs -m single /dev/sdb
                                    

    After filesystem creation it can be mounted like any other
    filesystem. To see the devices used by the filesystem you can use
    the follwing command:

            butterfs filesystem show
            label:  none  uuid: c67b1e23-887b-4cb9-b037-5958f6c0a333
                total devices 2 FS bytes used 383.00KiB
                devid   1 size 4.00 GiB used 847.12MiB path /dev/sdb
                devid   2 size 4.00 GiB used 837.12MiB path /dev/sdc
            Btrfs v4.8.5
             
                                    

#### Snapshotting

-   Btrfs's snapshotting is simple to use and understand. The snapshots
    will show up as normal directories under the snapshotted directory,
    and you can cd into it and walk around there as you would in any
    directory.

    By default, all snapshots are writeable in Btrfs, but you can create
    read-only snapshots if you choose so. Read-only snapshots are great
    if you are just going to take a snapshot for a backup and then
    delete it once the backup completes. Writeable snapshots are handy
    because you can do things such as snapshot your file system before
    performing a system update; if the update breaks your system, you
    can reboot into the snapshot and use it like your normal file
    system. When you create a new Btrfs file system, the root directory
    is a subvolume. Snapshots can only be taken of subvolumes, because a
    subvolume is the representation of the root of a completely
    different filesystem tree, and you can only snapshot a filesystem
    tree.

    The simplest way to think of this would be to create a subvolume for
    `/home`, so you could snapshot `/` and `/home` independently of each
    other. So you could run the following command to create a subvolume:

            btrfs subvolume create /home
                                    

    And then at some point down the road when you need to snapshot
    `/home` for a backup, you simply run:

            btrfs subvolume snapshot /home/ /home-snap
                                    

    Once you are done with your backup, you can delete the snapshot with
    the command

            btrfs subvolume delete /home-snap/
                                    

    The hard work of unlinking the snapshot tree is done in the
    background, so you may notice I/O happening on a seemingly idle box;
    this is just Btrfs cleaning up the old snapshot. If you have a lot
    of snapshots or don't remember which directories you created as
    subvolumes, you can run the command:

            # btrfs subvolume list /mnt/btrfs-test/
            ID 267 top level 5 path home
            ID 268 top level 5 path snap-home
            ID 270 top level 5 path home/josef
                                    

    This doesn't differentiate between a snapshot and a normal
    subvolume, so you should probably name your snapshots consistently
    so that later on you can tell which is which.

#### Subvolumes

-   A subvolume in btrfs is not the same as an LVM logical volume, or a
    ZFS subvolume. With LVM, a logical volume is a block device in its
    own right; this is not the case with btrfs. A btrfs subvolume is not
    a block device, and cannot be treated as one.

    Instead, a btrfs subvolume can be thought of as a POSIX file
    namespace. This namespace can be accessed via the top-level
    subvolume of the filesystem, or it can be mounted in its own right.
    So, given a filesystem structure like this:

            toplevel
              `--- dir_a                * just a normal directory
              |         `--- p
              |         `--- q
              `--- subvol_z             * a subvolume
                    `--- r
                    `--- s
                                    

    the root of the filesystem can be mounted, and the full filesystem
    structure will be seen at the mount point; alternatively the
    subvolume can be mounted (with the `mount` option
    `subvol=subvol_z`), and only the files `r` and `s` will be visible
    at the mount point.

    A btrfs filesystem has a default subvolume, which is initially set
    to be the top-level subvolume. It is the default subvolume which is
    mounted if no subvol or subvolid option is passed to mount. Changing
    the default subvolume with *btrfs subvolume default* will make the
    top level of the filesystem inaccessible, except by use of the
    `subvolid=0` mount option.

#### Space-efficient indexed directories

-   Directories and files look the same on disk in Btrfs, which is
    consistent with the UNIX way of doing things. The ext file system
    variants have to pre-allocate their inode space when making the file
    system, so you are limited to the number of files you can create
    once you create the file system.

    With Btrfs we add a couple of items to the B-tree when you create a
    new file, which limits you only by the amount of metadata space you
    have in your file system. If you have ever created thousands of
    files in a directory on an ext file system and then deleted the
    files, you may have noticed that doing an ls on the directory would
    take much longer than you'd expect given that there may only be a
    few files in the directory.

    You may have even had to run this command:

            e2fsck -D /dev/sda1
                                    

    to re-optimize your directories in ext. This is due to a flaw in how
    the directory indexes are stored in ext: they cannot be shrunk. So
    once you add thousands of files and the internal directory index
    tree grows to a large size, it will not shrink back down as you
    remove files. This is not the case with Btrfs.

    In Btrfs we store a file index next to the directory inode within
    the file system B-tree. The B-tree will grow and shrink as
    necessary, so if you create a billion files in a directory and then
    remove all of them, an ls will take only as long as if you had just
    created the directory.

    Btrfs also has an index for each file that is based on the name of
    the file. This is handy because instead of having to search through
    the containing directory's file index for a match, we simply hash
    the name of the file and search the B-tree for this hash value. This
    item is stored next to the inode item of the file, so looking up the
    name will usually read in the same block that contains all of the
    important information you need. Again, this limits the amount of I/O
    that needs to be done to accomplish basic tasks.

####  mkswap

mkswap mkswap sets up a Linux swap area on a device or in a file. (After
creating the swap area, you need to invoke the `swapon` command to start
using it. Usually swap areas are listed in `/etc/fstab` so that they can
be taken into use at boot time by a `swapon` `-a` command in some boot
script.) See [???](#swapfilemc)

####  xfs\_info

xfs\_info xfs\_info shows the filesystem geometry for an XFS filesystem.
xfs\_info is equivalent to invoking xfs\_growfs with the `-n` option.

####  xfs\_check

xfs\_check xfs\_check checks whether an XFS filesystem is consistent. It
is needed only when there is reason to believe that the filesystem has a
consistency problem. Since XFS is a Journalling filesystem, which allows
it to retain filesystem consistency, there should be little need to ever
run `xfs_check`.

####  xfs\_repair

xfs\_repair xfs\_repair repairs corrupt or damaged XFS filesystems.
xfs\_repair will attempt to find the raw device associated with the
specified block device and will use the raw device instead. Regardless,
the filesystem to be repaired must be unmounted, otherwise, the
resulting filesystem may become inconsistent or corrupt.

####  smartmontools: smartd and smartctl

smartd smartctl Two utility programs, *smartctl* and *smartd* (available
when the *smartmontools* package is installed) can be used to monitor
and control storage systems using the *Self-Monitoring, Analysis and
Reporting Technology System (SMART)*. SMARTis built into most modern ATA
and SCSI harddisks and solid-state drives. The purpose of SMARTis to
monitor the reliability of the hard drive and predict drive failures,
and to carry out different types of drive self-tests.

*smartd*is a daemon that will attempt to enable SMARTmonitoring on ATA
devices and polls these and SCSI devices every 30 minutes
(configurable), logging SMARTerrors and changes of SMARTAttributes via
the SYSLOG interface. smartd can also be configured to send email
warnings if problems are detected. Depending upon the type of problem,
you may want to run self-tests on the disk, back up the disk, replace
the disk, or use a manufacturer's utility to force reallocation of bad
or unreadable disk sectors.

smartd can be configured at start-up using the configuration file
/usr/local/etc/smartd.conf. When the USR1 signal is sent to smartd it
will immediately check the status of the disks, and then return to
polling the disks every 30 minutes. Please consult the manual page for
smartd for specific configuration options.

The *smartctl* utility controls the SMART system. It can be used to scan
devices and print info about them, to enable or disable SMART on
specific disks, to configure what to do when (imminent) errors are
detected. Please consult the smartctl manual page for details.

####  ZFS: zpool and zfs

ZFS, currently owned by Oracle Corporation, was developed at Sun
Microsystems as a next generation filesystem aimed at near infinite
scalability and free from traditional design paradigms. Only Ubuntu
currently offers kernel integration for ZFS on Linux. Other Linux
distributions can make use of ZFS through userspace with the aid of
Fuse.

The main ZFS features available at the moment include:

-   High fault tolerance and data integrity

-   Near unlimited storage due to 128 bit design

-   Hybrid volume/filesystem management with RAID capabilities

-   Compression/deduplication of data

-   Data snapshots

-   Volume provisioning (zvols)

-   Ability to use different devices for caching and logging

-   Ability to use delegate administrative rights to unprivileged users

The high fault tolerance and data integrity design makes it unneccesary
to have a command like fsck available. ZFS works in transactions in
where the ueberblock is only updated if everything was completed. Copies
of previous uberblocks (128) are being kept in a round robin fashion.
The so called vdev labels, which identify the disks used in a zfs pool,
also have multiple copies: 2 at the beginning of the disk and 2 at the
end. Periodic scrubbing of pools can reveal data integrity issues, and
if a pool is equipped with more than one device, can repair it on the
fly.

ZFS allows for additional checksumming algoritms of blocks and can have
multiple copies of those blocks stored. This can be configured per ZFS
filesystem.

ZFS pools can be considered the logical volume managent and can consist
out of single or multiple disks. The pools can have seperate cache and
logging devices attached so that reading/writing is offloaded to faster
devices. Having multiple disks in a pool allows for on the fly data
recovery.

A typical simple ZFS pool:

        $ sudo zpool list -v
        NAME   SIZE  ALLOC   FREE  EXPANDSZ   FRAG    CAP  DEDUP  HEALTH  ALTROOT
        tank  1.98G   448K  1.98G         -     0%     0%  1.00x  ONLINE  -
         sdb  1.98G   448K  1.98G         -     0%     0%
                

Status of the pool:

        $ sudo zpool status -v
          pool: tank
         state: ONLINE
          scan: none requested
        config:

            NAME        STATE     READ WRITE CKSUM
            tank        ONLINE       0     0     0
              sdb       ONLINE       0     0     0
            errors: No known data errors
                

History overview for ZFS pools:

        $ sudo zpool history
        History for 'tank':
        2017-01-11.11:32:50 zpool create -f -m /tank tank /dev/sdb
        2017-01-11.12:37:44 zpool scrub tank
                

The ZFS pool is used as backing for one or more ZFS filesystems. By
default the pool itself has a single filesystem named after the pool.
ZFS filesystems are flexible in size and allow for customisation of
various attributes like compression, size reservation, quota, block
copies and so on. A full set of attributes can be seen with
`zfs get all ` and optionally a zfs filesystem, snapshot or volume.

A typical ZFS filesystem listing

        $ sudo zfs list
        NAME   USED  AVAIL  REFER  MOUNTPOINT
        tank   242K  1.92G    19K  /tank
                

Create a ZFS filesystem "documents" and use compression

        $ sudo zfs create -o compression=on tank/documents
        $ sudo zfs list tank/documents
        NAME             USED  AVAIL  REFER  MOUNTPOINT
        tank/documents    19K  1.92G    19K  /tank/documents
                

or

        $ sudo zfs create tank/documents
        $ sudo zfs set compression=on tank/documents
        $ sudo zfs list tank/documents
        NAME             USED  AVAIL  REFER  MOUNTPOINT
        tank/documents    19K  1.92G    19K  /tank/documents
                

With some data in `/tank/documents` compression ratio can be seen with

        $ sudo zfs get compressratio tank/documents 
        NAME            PROPERTY       VALUE  SOURCE
        tank/documents  compressratio  1.68x  -
                

Creating a backup of `/tank/documents` can be done instantaniously and
takes no space until `/tank/documents`'s content changes. The contents
of the snapshot can be accessed through the `.zfs/snapshot` directory of
that ZFS filesystem.

        $ sudo zfs snap tank/documents@backup
        $ sudo zfs list -t snapshot
        NAME                    USED  AVAIL  REFER  MOUNTPOINT
        tank/documents@backup      0      -  45.0M  -
                
