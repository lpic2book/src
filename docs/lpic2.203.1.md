##  Operating The Linux Filesystem (203.1)

Candidates should be able to properly configure and navigate the
standard Linux filesystem. This objective includes configuring and
mounting various filesystem types.


###   Key Knowledge Areas

-   The concept of the `fstab` configuration

-   Tools and utilities for handling SWAP partitions and files

-   Use of UUIDs for identifying and mounting file systems

-   Understanding of systemd mount units

###   Terms and Utilities

-   `/etc/fstab`

-   `/etc/mtab`

-   `/proc/mounts `

-   `mount` and `umount`

-   `sync`

-   `swapon`

-   `swapoff`

-   `blkid`

###   The File Hierarchy

Historically, the location of certain files and utilities has not always
been standard (or fixed). This has led to problems with development and
upgrading between different "distributions" of Linux. The Linux
directory structure (or Linux directory structure file hierarchy) was
based on existing flavors of UNIX, but as it evolved, certain
inconsistencies came into being. These were often small things such as
the location (or placement) of certain configuration files, but this
resulted in difficulties porting software from host to host.

To equalize these differences a file standard was developed. This, to
date, is an evolving process resulting in a fairly static model for the
Linux file hierarchy. This filesystem hierarchy is standardized Linux
file hierarchy in the filesystem hierarchy standard. The current version
is 2.3. More information and documentation on the FHS can be found at
[Filesystem Hierarchy Standard homepage](http://www.pathname.com/fhs/).
See also the section on [the FHS standard](#fhs).

The top level of the Linux file hierarchy is referred to as the root (or
`/` ). The root directory typically contains several other directories.
An overview was already presented in [the section that discusses the
contents of the root file system](#root-fs-contents). A recap:

     
      `bin/`          Required boot-time binaries
      `boot/`         Boot configuration files for the OS loader and kernel image
      `dev/`          Device files
      `etc/`          System configuration files and scripts
      `home/`         User home directories
      `lib/`          Main OS shared libraries and kernel modules
      `lost+found/`   Storage directory for "recovered" files
      `media/`        Mount point(s) for removable media like CD-ROM's, flash disks and floppies
      `mnt/`          Temporary mount point for filesystems as needed by a system administrator
      `opt/`          Reserved for the installation of large add-on application software packages
      `proc/`         A \"virtual\" filesystem used by Linux systems to store information about the kernel, processes and current resource usage
      `root/`         Linux (non-standard) home directory for the root user. Alternate location being the `/` directory itself
      ` sbin/`        System administration binaries and tools
      ` tmp/`         Location of temporary files
      ` usr/`         Shareable, read-only data, containing e.g. user commands, C programs header files and non-vital system binaries
      ` var/`         Variable data, usually machine specific. Includes spool directories for mail and news, administrative and logging data
  

Generally, the root should not contain any additional files NDASH a
possible exception would be mount points for various purposes.

###   Filesystems

A filesystem consists of methods and data structures that an filesystems
operating system uses to keep track of files on a disk or partition;
that is, the way the files are organised on the disk. The word is also
used to refer to a partition or disk that is used to store the files or
the type of the filesystem. Thus, one might say "I have two filesystems"
meaning one has two partitions on which files are stored, or one might
say "I am using the XFS filesystem", meaning the type of the XFS
filesystem.

The difference between a disk or partition and the partition filesystem
it contains is important. A few programs (including those that create
filesystems) operate directly on the raw sectors of a disk or partition;
if a filesystem is already there it will be destroyed or seriously
corrupted. Most programs operate on a filesystem, and therefore won't
work on a partition that doesn't contain one (or that contains a
filesystem of the wrong type).

Before a partition or disk can be used as a filesystem, it needs to be
initialized, and the bookkeeping data structures need to be written to
the disk. This process is called making a filesystem. making a
filesystem

Most UNIX filesystem types have a similar general structure, although
the exact details vary quite a bit. The central superblock inode
directory blocks indirection blocks concepts are superblock, inode, data
block, directory block, and indirection block. The superblock contains
information about the filesystem as a whole, such as its size (the exact
information here depends on the filesystem). An inode contains all
information about a file, except its name. The name is stored in the
directory, together with the number of the inode. A directory entry
consists of a filename and the number of the inode which represents the
file. The inode contains the numbers of several data blocks, which are
used to store the data in the file. There is space only for a few data
block numbers in the inode, however, and if more are needed, more space
for pointers to the data blocks is allocated dynamically. These
dynamically allocated blocks are indirect blocks; the name indicates
that in order to find the data block, one has to find its number in the
indirect block first.

####   Creating Filesystems

Before a partition can be mounted (or used), a filesystem must
Creatingfilesystem first be installed on it NDASH with ext2, this is the
process of creating i-nodes and data blocks.

This process is the equivalent of initializing the partition. Under
create filesystem mkfs Linux, the command to create a filesystem is
called `mkfs`.

The command is issued in the following way:

        mkfs [-c] [ -t fstype ] filesystem [ blocks ]
                

e.g.

        mkfs -t ext2 /dev/fd0 # Make a ext2 filesystem on a floppy
                

where:

`-c`

-   forces a check for bad blocks

`-t fstype`

-   specifies the filesystem type. For most filesystem types there is a
    shorthand for this e.g.: `mkfs -t ext2` can also be called as ext2
    `mke2fs` or mkfs.ext2 `mkfs.ext2` and `mkfs -t vfat` or
    `mkfs -t msdos` can also be called as `mkfs.vfat`, `mkfs.msdos` or
    `mkdosfs`

`filesystem`

-   is either the device file associated with the partition or device OR
    is the directory where the file system is mounted (this is used to
    erase the old file system and create a new one)

**Note**
Creating a filesystem on a device with an existing filesystem will cause
all data on the old filesystem to be erased.


####  Mounting and Unmounting

Linux presents all filesystems as one directory tree. Hence to add a new
device with a filesystem on it its filesystem needs to be made part of
that one directory tree. The way this is done is by attaching the new
filesystem under an existing (preferably empty) directory, which is part
of the existing directory tree - the "`mount`" point.

To attach a new file system to the directory mount unmount hierarchy you
must mount its associated device file. First you will need to create the
mount point; a directory where the device will be attached. As
directories are part of a filesystem too the mount point exists on a
previously mounted device. It should be empty. If is is not the files in
the directory will not be visible while the device is mounted to it, but
will reappear after the device has been disconnected (or unmounted).
This type of security by obscurity is sometimes used to hide information
from the casual onlooker.

To mount a device, use the mount command:

        mount [options] device_file mount_point
                

With some devices, mount will detect what type of filesystem exists on
the device, however it is more usual to use mount in the form of:

        mount [options] -t file_system_type device_file mount_point
                

Generally, only the root user can use the mount command - mainly due to
the fact that the device files are owned by root. For example, to mount
the first partition on the second (IDE) hard drive off the `/usr`
directory and assuming it contained the ext2 filesystem, you'd enter
the command:

        mount -t ext2 /dev/hdb1 /usr
                

A common device that is mounted is the floppy drive. A floppy disk
generally contains the FAT, also known as msdos, filesystem (but not
always) FAT and is mounted with the command:

        mount -t msdos /dev/fd0 /mnt
                

Note that the floppy disk was mounted under the `/mnt` directory. This
is because the `/mnt` directory is the usual place to temporarily mount
devices.

To see which devices you currently have mounted, simply type the command
`mount`. Some sample output:

        /dev/hda3 on / type ext2 (rw)
        /dev/hda1 on /dos type msdos (rw)
        none on /proc type proc (rw)
        /dev/cdrom on /cdrom type iso9660 (ro)
        /dev/fd0 on /mnt type msdos (rw)
                

Each line shows which device file is mounted, where it is iso9660
mounted, what filesystem type each partition is and how it is mounted
(`ro` = read only, `rw` = read/write). Note the strange entry on line
three NDASH the proc filesystem. This is a special "virtual" filesystem
used by Linux systems to store information about the kernel, processes
and current resource usage. It is actually part of the system's memory
NDASH in other words, the kernel sets aside an area of memory in which
it stores information about the system. This same area is mounted onto
the filesystem so that user programs have access to this information.

The information in the proc filesystem can also be used to see which
filesystems are mounted by issuing the command: /proc/mounts

        $ cat /proc/mounts
        /dev/root / ext2 rw 0 0
        proc /proc proc rw 0 0
        /dev/hda1 /dos msdos rw 0 0
        /dev/cdrom /cdrom iso9660 ro 0 0
        /dev/fd0 /mnt msdos rw 0 0
                

The difference between `/etc/mtab` and `/proc/mounts` is that
`/etc/mtab` is the user space administration kept by `mount`, and
`/proc/mounts` is the information kept by the kernel. The latter
reflects the information in user space. Due to these different
implementations the info in `/proc/mounts` is always up-to-date, while
the info in `/etc/mtab` may become inconsistent.

To release a device and disconnect it from the filesystem, the umount
command is used. It is issued in the form: umount

        umount device_file
                

or

        umount mount_point
                

For example, to release the floppy disk, you'd issue the command:

        umount /dev/fd0
                

or

        umount /mnt
                

Again, you must be the root user or a user with privileges to do this.
You can't unmount a device/mount point that is in use by a user (e.g.
the user's current working directory is within the mount point) or is
in use by a process. Nor can you unmount devices/mount points which in
turn have devices mounted to them.

The system needs to mount devices during boot. In true UNIX fashion,
there is a file which governs the behaviour of mounting devices at boot
time. In Linux, this file is `/etc/fstab`. Lines from the /etc/fstabfile
use the following format:

        device_file mount_point file_system_type mount_options [n] [n]
                

The first three fields are self explanatory; the fourth field,
`mount_options` defines how the device will be mounted (this includes
information of access mode `ro` / `rw` , execute permissions and other
information) - information on this can be found in the `mount` man pages
(note that this field usually contains the word "defaults" ). The fifth
and sixth fields are used by the system utilities `dump` and `fsck`
respectively - see the next section for details.

There's also a file called `/etc/mtab`. It lists the currently mounted
partitions in fstab form.

####  Systemd Mount Units

Linux distributions that have adopted the systemd initialization system
have an additional way of mounting filesystems. Instead of using the
`fstab` file for persistent mounting, a filesystem can be configured
using a mount unit file. This mount unit file holds the configuration
details for systemd to persistently mount filesystems.

A systemd mount unit file has a specific naming convention. The file
name refers to the absolute directory it will be mounted on and the file
extension is `.mount`. For the name of the file the first and last
forward slash (/) of the mount path it represents are removed and the
remaining slashes are converted to a dash (-). So if, for example, a
filesystem is mounted to the mount point `/home/user/data/` the mount
unit file must be named `home-user-data.mount`

In the mount file three required sections are defined: `[Unit]`,
`[Mount]` and `[Install]`. An example of a mount unit file
`/etc/systemd/system/home-user-data.mount`:

        [Unit]
        Description=Data for User

        [Mount]
        What=/dev/sda2
        Where=/home/user/data
        Type=ext4
        Options=defaults

        [Install]
        WantedBy=multi-user.target
                

To test the configuration reload the systemctl daemon by using the
command `systemctl daemon-reload` and then manually start the mount unit
file with the command `systemctl start` followed by the mount unit file.
In our example that would be `systemctl start home-user-data.mount`.
Next you can check if the filesystem was mounted correctly by getting
the overview from `mount`. If everything works as expected make the
filesystem mount persistent by enabling the mount unit file with the
command `systemctl enable home-user-data.mount`.

####  Swap

Swap space in Linux is a partition or file that is used to move the
contents of inactive pages of RAM to when RAM becomes full. Linux can
use either a normal file in the filesystem or a swap separate partition
for swap space. A swap partition is faster, but it is easier to change
the size of a swap file (there's no need to repartition the whole hard
disk, and possibly install everything from scratch). When you know how
much swap space you need, you should use a swap partition, but if you
are in doubt, you could use a swap file first, and use the system for a
while so that you can get a feel for how much swap you need, and then
make a swap partition when you're confident about its size. It is
recommended to use a separate partition, because this excludes chances
of file system fragmentation, which would reduce performance. Also, by
using a separate swap partition, it can be guaranteed that the swap
region is at the fastest location of the disk. On current HDDs this is
at the beginning of the platters (outside rim, first cylinders). It is
possible to use several swap partitions and/or swap files at the same
time. This means that if you only occasionally need an unusual amount of
swap space, you can set up an extra swap file at such times, instead of
keeping the whole amount allocated all the time.

The command `mkswap` is used to initialize a mkswap swap partition or a
swap file. The partition or file needs to exist before it can be
initialized. A swap partition is created with a disk partitioning tool
like `fdisk` and a swap file can be created with: /dev/zero

        dd if=/dev/zero of=swapfile bs=1024 count=65535
                

When the partition or file is created, it can be initialized with:

        mkswap {device|file}
                

An initialized swap space is taken into use with `swapon`. This swapon
command tells the kernel that the swap space may be used. The path to
the swap space is given as the argument, so to start swapping on a
temporary swap file one might use the following command:

        swapon /swapfile
                

or, when using a swap partition:

        swapon /dev/hda8
                

Swap spaces may be used automatically by listing them in the file
`/etc/fstab`:

        /dev/hda8 none swap sw 0 0
        /swapfile none swap sw 0 0
                

The startup scripts will run the command `swapon 
            -a`, which will start swapping on all the swap spaces listed
in `/etc/fstab`. Therefore, the swapon command is usually used only when
extra swap is needed. You can monitor the use of swap spaces with free
`free`. It will report the total amount of swap space used:

        $ free
        total used free shared buffers cached
        Mem: 127148 122588 4560 50 1584 69352
        -/+ buffers/cache: 51652 75496
        Swap: 130748 57716 73032
                

The first line of output (`Mem:`) shows the physical memory. The `total`
column does not show the physical memory used by the kernel, which is
loaded into the RAM memory during the boot process. The `used
            ` column shows the amount of memory used (the second line
does not count buffers). The `free
            ` column shows completely unused memory. The `shared` column
shows the amount of memory used by tmpfs (shmem in /proc/meminfo); The
`buffers
            ` column shows the current size of the disk buffer cache.

That last line (`Swap:` ) shows similar information for the swap spaces.
If this line is all zeroes, swap space is not activated.

The same information, in a slightly different format, can be shown by
using `cat` on the file /proc/meminfo `/proc/meminfo`:

        $ cat /proc/meminfo
        total used free shared buffers cached
        Mem: 130199552 125177856 5021696 0 1622016 89280512
        Swap: 133885952 59101184 74784768
        MemTotal: 127148 kB
        MemFree: 4904 kB
        MemShared: 0 kB
        Buffers: 1584 kB
        Cached: 69120 kB
        SwapCached: 18068 kB
        Active: 80240 kB
        Inactive: 31080 kB
        HighTotal: 0 kB
        HighFree: 0 kB
        LowTotal: 127148 kB
        LowFree: 4904 kB
        SwapTotal: 130748 kB
        SwapFree: 73032 kB
                

swapoff To disable a device or swap file, use the `swapoff` command:

        # swapoff /dev/sda3
                

####  UUIDs

The term UUID stands for Universal Unique IDentifier. It's a 128 bit
number that can be used to identify basically anything. Generating such
UUIDs can be done using appropriate software. There are 5 various
versions of UUIDs, all of them use a (pseudo)random element, current
system time and some mostly unique hardware ID, for example a MAC
address. Theoretically there is a very, very remote chance of an UUID
not being unique, but this is seen as impossible in practice.

On Linux, support for UUIDs was started within the e2fsprogs package.
With filesystems, UUIDs are used to represent a specific filesystem. You
can for example use the UUID in `/etc/fstab` to represent the partition
which you want to mount.

Usually, a UUID is represented as 32 hexadecimal digits, grouped in
sequences of 8,4,4,4 and 12 digits, separated by hyphens. Here's what
an fstab entry with a UUID specifier looks like:

        UUID=652b786e-b87f-49d2-af23-8087ced0c828 / ext4 errors=remount-ro,noatime 0 1
                

You might be wondering about the use of UUID's in fstab, since device
names work fine. UUIDs come in handy when disks are moved to different
connectors or computers, multiple operating systems are installed on the
computer, or other cases where device names could change while keeping
the filesystem intact. As long as the filesystem does not change, the
UUID stays the same.

Note the 'as long as the filesystem does not change'. This means, when
you reformat a partition, the UUID will change. For example, when you
use mke2fs to reformat partition `/dev/sda3`, the UUID will be changed.
So, if you use UUIDs in `/etc/fstab`, you have to adjust those as well.

blkid If you want to know the UUID of a specific partition, use
`blkid /path/to/partition`:

        # blkid /dev/sda5
        /dev/sda5: UUID="24df5f2a-a23f-4130-ae45-90e1016031bc" TYPE="swap"
                

**Note**
It is possible to create a new filesystem and still make it have the
same UUID as it had before, at least for 'ext' type filesystems.

        # tune2fs /dev/sda5 -U 24df5f2a-a23f-4130-ae45-90e1016031bc
                        

**Note**
On most Linux distributions you can generate your own UUIDs using the
command `uuidgen`.

**sync**

To improve performance of Linux filesystems, many operations are
done in filesystem buffers, stored in RAM. To actually flush the data
contained in these buffers to disk, the `sync` command is used.

`sync` is called automatically at the right moment when rebooting or
halting the system. You will rarely need to use the command yourself.
`sync` might be used to force syncing data to an USB device before
removing it from your system, for example.

`sync` does not have any operation influencing options, so when you need
to, just execute \"`sync`\" on the command line.
