##  Backup Operations (206.2)

Candidates should be able to use system tools to back up important
system data.

###   Key Knowledge Areas

- Knowledge about directories that have to be include in backups

- Awareness of network backup solutions such as Amanda, Bacula, Bareos and
BackupPC

- Knowledge of the benefits and drawbacks of tapes, CDR, disk or other
backup media

- Perform partial and manual backups

- Verify the integrity of backup files

- Partially or fully restore backups

- Awareness of Bareos

###   Terms and Utilities

-   `/bin/sh`

-   `dd`

-   `tar`

-   `/dev/st*` and `/dev/nst*`

-   `mt`

-   `rsync`

###   Why?

Making backups is the sysadmins Pavlov reaction to having at least one
system to administer. But do we still need backups? After all, nowadays
data is often stored on RAID cabinets or "in the cloud".

Well, it depends. First of all superredundant storage will only protect
you against one reason for data-loss, namely hardware failure. But not
against human error, software bugs and natural disasters.

After all, humans are quite unreliable, they might make a mistake or be
malicious and destroy data on purpose. Modern software does not even
pretend to be reliable. A rock-solid program is an exception, not a
rule. Nature may not be evil, but, nevertheless, can be very destructive
sometimes. The most reliable thing is hardware, but it still breaks
seemingly spontaneously, often at the worst possible time.

To protect yourself against any of these threats, a very cheap and
simple control is available: to make regular backups. There is a very
low break-even point between the costs of data loss and those of making
backups. In fact, the control used to be so cheap that employing it
became a solid best practice.

But please note that there are situations in which making a backup is
not necessary. An example is a math-cluster. The results of its
calculation are important and you probably will make backups of these.
But cluster nodes themselves are discardable. Might a node fail you can
simply replace it with a freshly installed one.

So, in conclusion: making backups should always be the result of proper
risk-analysis. But in the overwhelming majority of cases they are a
cheap way of ensuring your data availability and in some cases your data
integrity.

###   What?

What you need to backup should be the result of proper risk analysis. In
olden days most system administrators simply backed up as much as
possible - that may not be such a good idea anymore as it takes a lot of
time to backup and restore large quantities of data. In all situations
you do not need to backup certain parts of the Linux filesystem anyway,
for example the `/proc` and `/sys` filesystems. They only contain data
that the kernel generates automatically, it is never a good idea to back
it up. The `/proc/kcore` file is especially unnecessary, since it is
just an image of your current physical memory; it's pretty large as
well. Some special files that are constantly changed by the operating
system (e.g. `/etc/mtab`) should not be restored, hence not be backed
up. There may be others on your system.

Gray areas include the news spool, log files and many other things in
`/var`. *You must decide what you consider important - do a proper risk
analysis.* Also, consider what to do with the device files in `/dev`.
Most backup solutions can backup and restore these special files, but
you may want to re-generate them with a script or they may be created
when you reinstall a system.

The obvious things to back up are user files (`/home`) and system
configuration files (`/etc`, but possibly other things scattered all
over the filesystem).

Generally it is a good idea to backup everything needed to rebuild the
system as fast as required after a failure - and nothing else. It is
often quite difficult to find out what to backup and what not, hence the
sysadmins paradigm: whilst in doubt, back it up.

###   When?

Depending on the rate of change of the data, this may be anything from
daily to almost never. The latter happens on firewall systems, where
only the log files change daily (but logging should happen on a
different system anyway). So, the only time when a backup is necessary,
for example, is when the system is updated or after a security update.

To determine your minimal backup frequency consider the amount of data
you are confident you can afford to loose without severe consequences
for you and/or your company. Then consider the minimal timespan needed
to create that amount of data. You should make at least one backup
during that timespan. Practical considerations like the time it takes to
make a backup and whether or not you can do any work when a backup is
being made, will restrict the maximum frequency. In the past systems
were mainly used during the day and not at all in weekends. Hence many
companies made incremental backups during the night and a full backup
during the weekend. However, nowadays many systems need to be used 24 x
7 which creates the need for alternate strategies, for example creating
snapshots on disk, which can subsequently be backed up on tape while the
production systems continue their work on the live filesystem.

Backups can take several hours to complete, but, for a successful backup
strategy, human interaction should be minimal. Backups are mostly made
to disk or on tape. In the latter case, the human interaction can be
further reduced by having tape robots that change the tapes for you.
However, make sure to store tapes off-site so any disaster will not take
out your backups. And be sure to protect sensitive data on tapes you
store off-site, for example by encrypting the data stored on them.

###   How?

While the brand or the technology of the hardware and software used for
backups is not important, there are, nevertheless, important
considerations in selecting them. Imagine, for example, the restore
software breaks and the publisher has since gone out of business.

No matter how you create your backups, the two most important parts in a
backup strategy are:

####  Verifying the backup

-   The safest method is to read back the entire backup and compare this
    with the original files. This is very time-consuming and often not
    an option. A faster, and relatively safe method, is to create a
    table of contents (which should contain a checksum per file) during
    the backup. Afterwards, read the contents of the tape and compare
    the two.

####  Testing the restore procedure

-   This means that you *must* have a restore procedure.
    This restore procedure has to specify how to restore anything from a
    single file to the whole system. Every few months, you should test
    this procedure by doing a restore.

####  Where?

If something fails during a backup, the medium will not contain anything
useful. If you made that backup on your only medium you lost your data.
So you should have at least two sets of backup media. But if you store
both sets in the same building, the first disaster that comes along will
destroy all your precious backups along with the running system.

So you should have at least one set stored at a remote site. Depending
on the nature of your data, you could store weekly or daily sets
remotely.

You will need a written plan, the backup plan, which describes what is
backed up, how to restore what is being backed up an any other
procedures surrounding the backup. Do not forget to store a copy of the
backup-plan along with backupplan the backups at the remote site.
Otherwise you cannot guarantee that the system will be back
up-and-running in the shortest possible time.

One important thing to be aware of, as noted in the previous paragraphs,
you need to be able to rebuild your system (or restore certain files) as
fast as required. In some enviroments restore times can be hours because
of slow network lines or other causes. The time lost may be too much and
can defeat the purpose of the backup system. Other solutions for
continuity of service like cluster/failover systems are recommended.

There are different types of backup media, each with their own benefits
and drawbacks. The medium of choice however will often be made based on
total cost. The main types are: Tape, Disk, Optical Media,
Remote/Network

####  Tape


Tape is one of the most used mediums for backup in enterprise
environments. It is low cost and because tapes store passively they have
a low chance for failure and consume little power on standby. A
disadvantage of tape is that it is a streaming medium which means high
access times, especially when a tape robot is used for accessing
multiple tapes. Bandwidth can be high if data is provides/requisted in a
continuous stream. Tape is especially suitable for long term backup and
archiving. If a lot of small files have to be written or restored the
tape will need to be stopped and started and may even need to be
partially rewound frequently to allow processing by the restoring
operating system. This may consume excessive time. In those cases tape
is not the best medium.

####  Disk

Local disk storage is hardly used for backup, (though it is used for
network storage, see below). The advantages are high bandwidth, low
latency and a reasonable price compared to capacity. But it is not
suitable for off-site backup (or the disk has to be manually
disconnected en transported to a safe location). And since disks are
always connected and running, chances for failure are high. Though not
suitable for off-site backup it is sometimes used as intermediate
(buffer) medium between the backup system and an off-site backup server.
The advantage is that fast recovery of recent files is possible and the
production systems won't be occupied by long backup transfers. Another
option, suitable for smaller systems, is using cheap USB bus based
portable disks. These can be spun down and powered off when not in use,
while still retaining their data. They can contain many terabytes of
data and can be taken off-site easily. Also, modern disks employ fast
USB protocols that reduce backup- and restore-time.

####  Optical Media


Optical media like CDROM and DVDR disk are mostly used to backup systems
which don't change a lot. Often a complete image of the system is saved
to disk for fast recovery. Optical disks are low cost and have a high
reliability when stored correctly. They can easily be transported
off-site. Disadvantages are that most are write-once and the storage
capacity is low. Access time and bandwidth are moderate, although mostly
they have to be handled manually by the operator.

####  Remote/Network storage

Network storage is mostly remote disk storage (NAS or SAN). Using data
protection techniques like RAID, the unreliability of disks can be
reduced. Most modern network storage systems use compression and
deduplication to increase potential capacity. Also most systems can
emulate tape drives which makes it easy to migrate from tape. The cost
of the systems can be high depending on the features, reliability and
capacity. Also power costs should be considered because a network
storage system is always on. This type of medium is thus not preferred
for long time backup and archives. Access time and bandwidth can differ
and depend on infrastructure, but are mostly high.

###   Backup utilities

####  rsync

`rsync` is a utility to copy/synchronise files from one location to the
other while keeping the required bandwidth low. It wil look at the files
to copy and the files already present at the destination and uses
timestamps, filesize and an advanced algorithm to calculate which
(portions of) files need to be transferred. Source and destination can
be local or remote and in case of a remote server SSH or `rsync`
protocol can be used for network transfer. `Rsync` is invoked much like
the `cp` command. Recursive mode is enabled with `-r` and archive with
`-a`. A simple example to copy files from a local directory to a remote
directory via SSH:

        rsync -av -e ssh /sue remote:/sue
                    

**Note**
By default `rsync` copies over (relevant parts of) changed files and new
files from a remote system. It does *not* delete files that were deleted
on the remote system. Specify the option `--delete` if you want that
behaviour. Also note that permissions will be copied over correctly, but
if your local UIDs/GIDs do not match te remote set you may end up with
incorrect local permissions still.

####  tar

The `tar` utility is used to combine multiple files and directories into
a continous stream of bytes (and revert the stream into
files/directories). This stream can be compressed, transferred over
network connections, saved to a file or streamed onto a tape device.
When reading files from the stream, permissions, modes, times and other
information can be restored. `Tar` is the most basic way for
transferring files and directories to and from tape, either with or
without compression.

An example of extracting a gzipped `tar` archive, with verbose output
and input data read from a file:

        tar xvzf sue.tgz
                    

Extracting a `tar` archive from a scsi tape drive:

        tar xvf /dev/st0
                    

Creating a archive to file from the directory `/sue`:

        cd /; tar cvf /tmp/sue.tar sue
                    

By default the `tar` utility uses (scsi) tape as
medium. As can be seen in the example above scsi tape devices can be
found in `/dev/st*` or `/dev/nst*`. The latter one is a non rewinding
tape, this means that the tape does not rewind automatically after each
operation. This is an important feature for backups, because otherwise
when using multiple `tar` commands for backups any backup but the last
would be overwritten by the next backup.

Tapes can be controlled by the `mt` command (magnetic tape). The
syntax of this command is: `mt [-h] [-f device] command [count]`. The
option -h (help) lists all possible commands. If the device is not
specified by the -f option, the command will use the environment
variable TAPE as default. More information can be found in the manual
pages.

####  dd

Using the `dd` utility, whole disks/partitions can be transferred
from/to files or other disks/partitions. With `dd` whole filesystems can
be backed-up at once. `dd` will copy data at byte level. Common options
to `dd` are:

if

input file: for the input file/disk/partition

of

output file: for the output file/disk/partition

bs

block size: size of blocks used for transfer, can be optimised
depending on used hardware

count

number of blocks to transfer (dd will read until end-of-file otherwise)

An example of `dd` usage to transfer a 1GB partition to file:

        dd if=/dev/hda1 of=/tmp/disk.img bs=1024 count=1048576
                    

####  `cpio`

The `cpio` utility is used to copy files to and from archives. It can
read/write various archive formats including `tar` and zip. Although it
predates `tar` it is less well known. `cpio` has three modes, input mode
(`-i`) to read an archive and extract the files, output mode (`-o`) to
read a list of files and compress them into an archive and pass-through
mode (`-p`) which reads a list of files and copies these to the
destination directory. The file list is read from `stdin` and is often
provided by `find`. An example of compressing a directory into a cpio
archive:

        %cd /sue; find . | cpio -o > sue.cpio
                    

###   Backup solutions

Complete backup solutions exist which help simplify the administration
and configuration of backups in larger environments. These solutions can
automate backup(s) of multiple servers and/or clients to multiple backup
media. Many different solutions exist, each with their own strengths and
weaknesses. Below you'll find some examples of these solutions.

####  Amanda

AMANDA, the Advanced Maryland Automatic Network Disk
Archiver, is a backup solution that allows the IT administrator to set
up a single master backup server to back up multiple hosts over network
to tape drives/changers or disks or optical media. Amanda uses native
utilities and formats (e.g. `dump` and/or GNU `tar`) and can back up a
large number of servers and workstations running multiple versions of
Linux or Unix.


####  Bacula

Bacula is a set of Open Source, enterprise ready, computer
programs that permit you (or the system administrator) to manage backup,
recovery, and verification of computer data across a network of
computers of different kinds. Bacula is relatively easy to use and
efficient, while offering many advanced storage management features that
make it easy to find and recover lost or damaged files. In technical
terms, it is an Open Source, enterprise ready, network based backup
program. According to Source Forge statistics (rank and downloads),
Bacula is by far the most popular Enterprise grade Open Source program.

####  Bareos

Bareos is a fork of the project Bacula version 5.2 and was
started because of rejection and neglect of community contributions to
the Bacula project. The Bareos backup program is open source and is
almost the same as Bacula, but is does have some additional features
like LTO hardware encryption, bandwidth limitation and new practical
console commands. One focus in Bareos's development is keeping the
obstacles for newcomers as low as possible. Because newcomers are
usually overwhelmed by configuration options, the Bareos project offers
package repositories for popular Linux distributions and Windows.

####  BackupPC

BackupPC is a high-performance, enterprise-grade system
for backing up Linux, WinXX and MacOSX PCs and laptops to a server's
disk. BackupPC is highly configurable and easy to install and maintain.
