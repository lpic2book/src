##  Creating And Configuring Filesystem Options (203.3)

Candidates should be able to configure automount filesystems using
AutoFS. This objective includes configuring automount for network and
device filesystems. Also included is creating filesystems for devices
such as CD-ROMs.

###   Key Knowledge Areas

-   autofs configuration files

-   UDF and ISO9660 tools and utilities

-   awareness of CD-ROM filesystems (UDF, ISO9660, HFS)

-   awareness of CD-ROM filesystem extensions (Joliet, Rock Ridge, El
    Torito)

-   basic feature knowledge of encrypted filesystems

###   Terms and Utilities

-   `/etc/auto.master`

-   `/etc/auto.[dir]`

-   `mkisofs`

-   `dd`

-   `mke2fs`

###   Autofs and automounter

Automounting is the process in which mounting (and unmounting) of
filesystems is done automatically by a daemon. If the filesystem is not
mounted and a user tries to access it, it will be automatically
(re)mounted. This is useful in networked environments (especially when
not all machines are always on-line) and for removable devices, such as
floppies and CD-ROMs.

The linux implementation of automounting, autofs, consists of automount
a kernel component and a daemon called `automount`. Autofs uses
`automount` to mount local and remote filesystems (over NFS) when needed
and unmount them when they are not being used (after a timeout). Your
`/etc/init.d/autofs` script first looks at `/etc/auto.master`:
/etc/auto.master /etc/init.d/autofs

        # sample /etc/auto.master file
        /var/autofs/floppy /etc/auto.floppy --timeout=2
        /var/autofs/cdrom /etc/auto.cdrom --timeout=6
                

The file contains lines with three whitespace separated fields. The
first field lists the directory in which the mounts will be done. The
second field lists the filename in which we have placed configuration
data for the devices to be mounted, the "supplemental" files. The last
field specifies options. In our example we specified a timeout. After
the timeout period lapses, the automount daemon will unmount the devices
specified in the supplemental file.

The configuration data in the supplemental files may consist of multiple
lines and span multiple devices. The filenames and path to the
supplemental files may be choosen freely. Each line in a supplemental
file contains three fields:

        # sample /etc/auto.floppy file
        floppy -user,fstype=auto :/dev/fd0
                

The first value is the "pseudo" directory. If the device is mounted, a
directory of that name will appear and you can change into it to explore
the mounted filesystem. The second value contains the mount options. The
third value is the device (such as `/dev/fd0`, the floppy drive) which
the "pseudo" directory is connected to.

The configuration files are reread when the automounter is reloaded

        /etc/init.d/autofs reload

Please note that autofs does NOT reload nor restart if the mounted
directory ( eg: `/home` ) is busy. Every entry in `auto.master` starts
it's own daemon.

The "pseudo" directory is contained in the directory which is defined in
`/etc/auto.master`. When users try to access this "pseudo" directory,
they will be rerouted to the device you specified. For example, if you
specify a supplemental file to mount `/dev/fd0` on
`/var/autofs/floppy/floppy`, the command `ls /var/autofs/floppy/floppy`
will list the contents of the floppy. But if you do the command
`ls /var/autofs/floppy`, you don't see anything even though the
directory `/var/autofs/floppy/floppy` should exist. That is because
`/var/autofs/floppy/floppy` does not exist yet. Only when you directly
try to access that directory the automounter will mount it.

Each device should have its own supplementary file. So, for example,
configuration data for the floppy drive and that of the cdrom drive
should not be combined into the same supplementary file. Each definition
in the `/etc/auto.master` file results in spawning its own `automount`
daemon. If you have several devices running under control of the same
automount daemon - which is legit - but one of the devices fails, the
daemon may hang or be suspended and other devices it controls might not
be mounted properly either. Hence it is good practice to have every
device under control of its own automount daemon and so there should be
just one device per supplementary file per entry in the
`/etc/auto.master` file.

####  Automount with systemd

To initiate automount with systemd a unit file should be created in
`/etc/systemd/system`. The unit file should be named after the mount
point. In this example the file is named: mnt.mount because the mount
point is /mnt.

        # cat /etc/systemd/systemd/mnt.mount
        [Unit]
        Description=My new file system

        [Mount]
        What=/dev/sdb1
        Where=/mnt
        Type=ext4
        Options=

        [Install]
        WantedBy=multi-user.target
        

After creating the unit file it should be activated with the command:

        # systemctl start mnt.mount
            

Verify the activated mount point:

        # mount | grep sdb1
        /dev/sdb1 on /mnt type ext4 (rw,relatime,data=ordered)
            

To activate the auto mounting on startup use the command:

        # systemctl enable mnt.mount
            

Initiate a reboot and verify if the partition is mounted. More
information about mounting with systemd can be found in the man page of
systemd.mount(5).

####  Autofs with systemd

To enable autofs with systemd a unit file with the extension
`.automount` should be created in `/etc/systemd/system`. The information
in that file is being controlled and supervised by systemd. The
Automount units should be named after the directions they control. In
this example the name of the automount unit configuration file is:
`mnt.automount`.

        # cat /etc/systemd/system/mnt.automount
        [Unit]
        Description=My new automounted file system.

        [Automount]
        Where=/mnt

        [Install]
        WantedBy=multi-user.target
            

Activate the autofs automount unit.

        # systemctl status mnt.automount
        mnt.automount - My new automounted file system.
        Loaded: loaded (/etc/systemd/system/mnt.automount; disabled; vendor preset: disabled)
        Active: inactive (dead)
            Where: /mnt

        # systemctl enable mnt.automount
        Created symlink from /etc/systemd/system/multi-user.target.wants/mnt.automount to /etc/systemd/system/mnt.automount.

        # systemctl start mnt.automount

        # systemctl status mnt.automount
        mnt.automount - My new automounted file system.
        Loaded: loaded (/etc/systemd/system/mnt.automount; enabled; vendor preset: disabled)
        Active: active (waiting) since Thu 2016-12-29 14:01:57 AST; 1min 2s ago
            Where: /mnt

        Dec 29 14:01:57 sue systemd[1]: Set up automount My new automounted file system..
            

Once it has been started the mount output shows the mount point enabled
with autofs.

        # mount |grep mnt
        systemd-1 on /mnt type autofs (rw,relatime,fd=25,pgrp=1,timeout=0,minproto=5,maxproto=5,direct)
            

The command `lsblk` shows that that disk is not mounted.

        # lsblk
        NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
        sda      8:0    0   30G  0 disk
        |-sda1   8:1    0 28.8G  0 part /
        |-sda2   8:2    0    1K  0 part
        |-sda5   8:5    0  1.3G  0 part [SWAP]
        sdb      8:16   0    1G  0 disk
        |-sdb1   8:17   0 1023M  0 part
            

Let's do a file listing of the /mnt directory.

        # ls /mnt
        lost+found
            

Then execute the command `lsblk` again to verify if partition sdb1 is
mounted on /mnt.

        # lsblk
        NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
        sda      8:0    0   30G  0 disk
        |-sda1   8:1    0 28.8G  0 part /
        |-sda2   8:2    0    1K  0 part
        |-sda5   8:5    0  1.3G  0 part [SWAP]
        sdb      8:16   0    1G  0 disk
        |-sdb1   8:17   0 1023M  0 part /mnt
            

The `mount` command shows the same.

        # mount | grep /mnt
        systemd-1 on /mnt type autofs (rw,relatime,fd=25,pgrp=1,timeout=0,minproto=5,maxproto=5,direct)
        /dev/sdb1 on /mnt type ext4 (rw,relatime,data=ordered)
            

Autofs combined with systemd is now working. See the manpage of
systemd.automount(5) for more configuration options.

###   CD-ROM filesystem

####  Creating an image for a CD-ROM

The usual utilities for creating filesystems on hard-disk CD-ROM
filesystem ISO9660 partitions write an empty filesystem onto them, which
is then mounted and filled with files by the users as they need it. A
writable CD is only writable once so if we wrote an empty filesystem to
it, it would get formatted and remain completely empty forever. This is
also true for re-writable media as you cannot change arbitrary sectors
yet; you must erase the whole disk. The tool to create the filesystem is
called `mkisofs`. A sample usage looks like this: mkisofs

        $ mkisofs -r -o cd_image private_collection/
                    

The option `-r` sets the permissions of all files on the CD to be public
readable and enables Rock Ridge extensions. You probably want to use
this option unless you really know what you're doing (hint: without
`-r` the mount point gets the permissions of private\_collection!).

`mkisofs` will try to map all filenames to the 8.3 format used by DOS to
ensure the highest possible 8.3 filename format compatibility. In case
of naming conflicts (different files have the same 8.3 name), numbers
are used in the filenames and information about the chosen filename is
printed via STDERR (usually the screen). Don't panic: Under Linux you
will never see these odd 8.3 filenames because Linux makes use of the
Rock Ridge extensions which contain the original Rock Ridge file
information (permissions, filename, etc.). Use the option `-J` (MS
Joliet extensions) or use `mkhybrid` if you want to generate a more
Windows-friendly CD-ROM. You can also use `mkhybrid` to create HFS
CD-ROMS HFS Read the man-page for details on the various options.
Another extention is El Torito, which is used to create bootable CD-ROM
filesystems.

Besides the ISO9660 filesystem as created by `mkisofs` there is the UDF
(Universal Disk Format) filesystem. The Optical Storage Technology
Association standardized the UDF filesystem to form a common filesystem
for all (read-only and re-writable) optical media. It was intended to
replace the ISO9660 filesystem.

Tools to create and maintain a UDF filesystem are:

`mkudffs`

-   Creates a new UDF filesystem. Can be used on hard disks as well as
    on CD-R(W).

`udffsck`

-   Used to check the integrity and correct errors on UDF filesystems.

`wrudf`

-   This command is used for maintaining UDF filesystems. It provides an
    interactive shell with operations on existing UDF filesystems: cp,
    rm, mkdir, rmdir, ls,\.... etc.

`cdrwtool`

-   The `cdrwtool` provides facilities to manage CD-RW drives. This
    includes formating new disks, setting the read and write speeds,
    etc.

These tools are part of the UDFtools package.

Reasons why the output of `mkisofs` is not directly sent to the writer
device:

-   mkisofs knows nothing about driving CD-writers;

-   You may want to test the image before burning it;

-   On slow machines it would not be reliable.

One could also think of creating an extra partition and writing the
image to that partition instead to a file. This is possible, but has a
few drawbacks. If you write to the wrong partition due to a typo, you
could lose your complete Linux system. Furthermore, it is a waste of
disk space because the CD-image is temporary data that can be deleted
after writing the CD. However, using raw partitions saves you the time
of deleting 650MB-sized files.

####  Test the CD-image

Linux has the ability to mount files as if they were disk partitions.
This feature is useful to check that the directory layout and
file-access permissions of the CD image loop mount matches your wishes.
Although media is very cheap today, the writing process is still time
consuming, and you may at least want to save some time by doing a quick
test.

To mount the file cd\_image created above on the directory `/cdrom`,
give the command

        $ mount -t iso9660 -o ro,loop=/dev/loop0 cd_image /cdrom
                    

Now you can inspect the files under `/cdrom` - they appear exactly as
they were on a real CD. To unmount the CD-image, just say
`umount /cdrom`.

####  Write the CD-image to a CD

The command `cdrecord` is used to write images to a SCSI CD-burner.
Non-SCSI writers require cdrecord SCSI compatibility drivers, which make
them appear as if they were real SCSI devices.

CD-writers want to be fed a constant stream of data. So, the process of
writing the image to the CD must not be interrupted or the CD may be
corrupted. It is easy to unintentionally interrupt the data stream, for
example by deleting a very large file. Say you delete an old 650 Mb
CD-image - the kernel must update information on 650,000 blocks of the
hard disk (assuming you have a block size of 1 Kb for your filesystem).
That takes some time and will slow down disk activity long enough for
the data stream to pause for a few seconds. However, reading mail,
browsing the web, or even compiling a kernel generally will not affect
the writing process on modern machines.

Please note that no writer can re-position its laser and continue at the
original spot on the CD when it gets disturbed. Therefore any strong
vibrations or other mechanical shocks will probably destroy the CD you
are writing.

You need to find the SCSI-BUS, -ID and -LUN number with busSCSI LUN ID
BUS `cdrecord -scanbus` and use these to write the CD:

        # SCSI_BUS=0 #
        # SCSI_ID=6 # taken from cdrecord -scanbus
        # SCSI_LUN=0 #
        # cdrecord -v speed=2 dev=$SCSI_BUS,$SCSI_ID,$SCSI_LUN \
        -data cd_image

        # same as above, but shorter:
        # cdrecord -v speed=2 dev=0,6,0 -data cd_image
                    

For better readability, the coordinates of the writer are stored in
three environment variables whose names actually make sense: SCSI\_BUS,
SCSI\_ID, SCSI\_LUN.

If you use cdrecord to overwrite a CD-RW, you must add the option
`blank=...` to erase the old content. Please read the blank man page to
learn more about the various methods of clearing the CD-RW.

If the machine is fast enough, you can feed the output of mkisofs
directly into cdrecord:

        # IMG_SIZE=`mkisofs -R -q -print-size private_collection/ 2>&1\
        | sed -e "s/.* = //"`

        # echo $IMG_SIZE

        # [ "0$IMG_SIZE" -ne 0 ] && mkisofs -r\
        private_collection/ \
        | cdrecord speed=2 dev=0,6,0 tsize=${IMG_SIZE}s -data -

        # don't forget the s --^ ^-- read data from STDIN
                    

The first command is an empty run to determine the size of the image
(you need the `mkisofs` from the `cdrecord` distribution for this to
work). You need to specify all parameters you will use on the final run
(e.g. `-J` or `-hfs`). If your writer does not need to know the size of
the image to be written, you can leave this dry run out. The printed
size must be passed as a tsize-parameter to `cdrecord` (it is stored in
the environment variable IMG\_SIZE). The second command is a sequence of
`mkisofs` and `cdrecord`, coupled via a pipe.

####  Making a copy of a data CD

It is possible to make a 1:1 copy of a data CD. But you should be aware
of the fact that any errors while reading the original (due to dust or
scratches) will result in a defective copy. Please note that both
methods will fail on audio CDs!

First case: you have a CD-writer and a separate CD-ROM drive. By issuing
the command

        # cdrecord -v dev=0,6,0 speed=2 -isosize /dev/scd0
                    

you read the data stream from the CD-ROM drive attached as `/dev/scd0`
and write it directly to the CD-writer.

Second case: you don't have a separate CD-ROM drive. In this case you
have to use the CD-writer to read out the CD-ROM first: dd

        # dd if=/dev/scd0 of=cdimage
                    

This command reads the content of the CD-ROM from the device `/dev/scd0`
and writes it into the file `cdimage`. The content of this file is
equivalent to what `mkisofs` produces, so you can proceed as described
earlier in this document (which is to take the file `cdimage` as input
for `cdrecord`).

###   Encrypted file systems

Linux has native filesystem encryption support. You can choose from a
number of symmetric encryption algorithms to encrypt your filesystem
with, namely: Twofish, Advanced Encryption Standard (AES) also known as
Rijndael, Data Encryption Standard (DES) and others. Twofish was also an
AES candidate like Rijndael. Due performance reasons Rijndael was
selected as the new AES standard. Twofish supports 128 bit block size
and keys up to 256 bits. DES is the predecessor of the AES standard and
is now considered as insecure because of the small key size. With
current computing power it is possible to brute force 56 bits (+8 parity
bits) DES keys in a relatively short time frame. AES uses a block size
of 128 bits and a key size of 128, 192 or 256 bits. For many years 128
bits key size was sufficient but with the introduction of quantum
computers the U.S. National Security Agency issued guidance for data
classification up to Top Secret with 256 bits keys. Intel introduced in
2010 the Advanced Encryption Standard New Instructions (AES-NI) set.
This new instruction set performs the encryption and decryption
completely in hardware which helps to lower the risk of side-channel
attacks and greatly improve AES performance. To check if your CPU
supports the AES-NI instruction set use the command:
` grep aes /proc/cpuinfo `. You can check AES-NI kernel support with the
command: ` sort -u /proc/crypto | grep module` and load the driver with
the command: ` modprobe aesni-intel ` as root.

####  Device Mapper

As of linux 2.6 it is possible to use the devicemapper, a generic linux
framework to map one block device to another. Devicemapper is used for
software RAID and LVM. It is used as the filter between the filesystem
on a virtual blockdevice and the encrypted data to be written to a hard
disk. This enables the filesystem to present itself decrypted while
everything read and written will be encrypted on disk. A virtual block
device is created in `/dev/mapper`, which can be used as any other block
device. All data to and from it goes to an encryption or decryption
filter before being mapped to another blockdevice.

####  Device Mapper crypt (dm-crypt)

Device mapper crypt provides a generic way for transparent encryption of
block devices by using the kernel API and can be used in combination
with RAID or LVM volumes. When the user creates a new block device he
can specify several options: symmetric cipher, encryption mode, key and
iv generation mode. Dm-crypt does not store any information in a header
like LUKS does. After encrypting the disk it will be indistinguishable
from a disk with random data. This means that the existence of of
encrypted files deniable in the sense that it can not be proven that
encrypted data exists. The user should keep track of the options that
are used in the dm-crypt setup otherwise it could lead to data loss
since no metadata is available. Only one encryption key can be used to
encrypt and decrypt block devices and no master key can be used. Once
the password of a encrypted block device is lost there is no possibility
to recover the data. Dm-crypt should only be used by advanced users.
Regular users should use LUKS for disk encryption.

####  Linux Unified Key Setup (LUKS)

LUKS is a standard utility on all generic linux distributions. It
provides disk encryption for different type of volumes (plain dm-crypt
volumes, LUKS volumes, etc.). It offers compatibility amongst
distributions and provides secure management of user passwords. It also
provides storage of cryptography options including the master key in the
partition header enabling seamlessly transport or data migration. LUKS
also provides up to 8 different keys per LUKS partition to enable key
escrow (usage of keys per meaning). By creating encrypted partitions on
different Linux distributions the default settings may vary but the
settings are sufficient enough to protect the data on the volume(s).
LUKS is the preferred method for data protection by regular users.

#### Example with dm-crypt

This is an example to set up an encrypted filesystem. All relevant
modules should be loaded at boot time:

        # echo aes >> /etc/modules
        # echo dm_mod >> /etc/modules
        # echo dm_crypt >> /etc/modules
        # modprobe -a aes dm_mod dm_crypt
                

Create the device mapperblock device and use (for example) hda3 for it.
Choose your password using: `cryptsetup -y create crypt /dev/hda3` Map
the device:

        # echo "crypt /dev/hda3 none none" >> /etc/crypttab
        # echo "/dev/mapper/crypt /crypt reiserfs defaults 0 1" >> /etc/fstab
                

Make a filesystem:

        # mkfs.reiserfs /dev/mapper/crypt
                

Now mount your encrypted filesystem. You will be prompted for the
password you chose with cryptsetup. You will be asked to provide it at
every boot:

        # mkdir /crypt
        # mount /crypt
                

#### Example with LUKS

This is an example to create an 512 MiB encrypted LUKS container in a
linux environment.

        # dd if=/dev/urandom of=/root/encrypted bs=1M count=512

Format the sparse file with LUKS and provide a passphrase:

        # cryptsetup -y luksFormat encrypted

        WARNING!
        ========
        This will overwrite data on encrypted irrevocably.
        
        Are you sure? (Type uppercase yes): YES
        Enter passphrase:
        Verify passphrase:
        

Open the container, provide a name and enter the passphrase:

        # cryptsetup luksOpen encrypted encrypted
        Enter passphrase for encrypted:
        

Create a filesystem on the unencrypted container:

        mkfs.ext4 /dev/mapper/encrypted
        mke2fs 1.43.3 (04-Sep-2016)
        Creating filesystem with 522240 1k blocks and 130560 inodes
        Filesystem UUID: 9fb28cc0-5a3e-4e0b-b3cc-3cbd6cf3c8f4
        Superblock backups stored on blocks:
                8193, 24577, 40961, 57345, 73729, 204801, 221185, 401409

        Allocating group tables: done   
        Writing inode tables: done
        Creating journal (8192 blocks): done
        Writing superblocks and filesystem accounting information: done
        

Mount the encrypted container for usage:

        # mount /dev/mapper/encrypted /mnt
        

Encrypted container as filesystem:

        # df -h
        Filesystem             Size  Used Avail Use% Mounted on
        udev                    10M     0   10M   0% /dev
        tmpfs                  792M   26M  767M   4% /run
        /dev/sda1               29G   16G   11G  60% /
        tmpfs                  2.0G  400K  2.0G   1% /dev/shm
        tmpfs                  5.0M     0  5.0M   0% /run/lock
        tmpfs                  2.0G     0  2.0G   0% /sys/fs/cgroup
        tmpfs                  396M   16K  396M   1% /run/user/133
        tmpfs                  396M   20K  396M   1% /run/user/0
        /dev/mapper/encrypted  486M  2.3M  455M   1% /mnt
        

Content of /mnt as any ext4 filesystem:

        # ls /mnt
        lost+found
        

Unmount the encrypted container after usage:

        # umount /mnt
        

Close the encrypted container:

        # cryptsetup luksClose /dev/mapper/encrypted
        
