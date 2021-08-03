##  Configuring an NFS Server (209.2)

Candidates should be able to export filesystems using NFS. This
objective includes access restrictions, mounting an NFS filesystem on a
client and securing NFS.

###   Key Knowledge Areas

- NFS version 3 configuration files

- NFS tools and utilities

- Access restrictions to certain hosts and/or subnets

- Mount options on server and client

- TCP Wrappers

Awareness of NFSv4

###   Terms and Utilities

-   `/etc/exports`

-   `exportfs`

-   `showmount`

-   `nfsstat`

-   `/proc/mounts`

-   `/etc/fstab`

-   `rpcinfo`

-   `mountd`

-   `portmapper`

##  NFS - The Network File System

The abbreviation NFS expands to *Network File System*. With NFS you can
make a remote disk (or only some of Configuring SMB Server NFS it) part
of your local filesystem.

The NFS protocol is being adjusted, a process which has, so far, taken
several years. This has consequences for those using NFS. Modern NFS
daemons will currently run in *kernel space* (part of the running
kernel) and support version 3 of the NFS protocol (version 2 will still
be supported for compatibility with older clients). Older NFS daemons
running in *user space* (which is almost independent of the kernel) and
accepting only protocol version 2 NFS requests, will still be around.
This section will primarily describe kernel-space NFS-servers supporting
protocol version 3 and compatible clients. Differences from older
versions will be pointed out when appropriate.

**Note**
Details about this NFS work-in-progress are in [NFS protocol
versions] below.

###   Client, Server or both?

The system that makes filesystem(s) available to other systems is
called a *server*. The system that connects to a
server is called a *client*. Each system can be configured as server,
client or both.

##  Setting up NFS

This section describes NFS-related software and its configuration.

###   Requirements for NFS

To run NFS, the following is needed:

-   support for NFS (several options) must be built into the 
    *kernel*

-   a *portmapper* must be running 

-   on systems with NFS-server support, an *NFS daemon* and a *mount
    daemon* must be active

-   support daemons may be needed

Each point is discussed in detail below.

###   Configuring the kernel for NFS

When configuring a kernel for NFS, it must be decided whether or not the
system will be a client or a server. A system with a kernel that
contains NFS-server support can also be used as an NFS client.

**Note**
The situation described here is valid for the 2.4.*x* kernel series.
Specifications described here may change in the future.

FIXME new kernel versions

#### NFS-related kernel options

See [Kernel options for NFS](#NFSkernelTable).

#### NFS file system support (CONFIG\_NFS\_FS):

-   If you want to use NFS as a client, select this. LinuxNFS Client If
    this is the only NFS option selected, the system will support NFS
    protocol version 2 only. To use protocol version 3 you will also
    need to select CONFIG\_NFS\_V3. When CONFIG\_NFS\_FS is selected,
    support for an old-fashioned user-space NFS-*server* (protocol
    version 2) is also present. You can do without this option when the
    system is a kernel-space NFS-server server only (i.e., neither
    client nor user-space NFS-server).

####Provide NFSv3 client support (CONFIG\_NFS\_V3):

-   Select this if the client system should be able to make NFS LinuxNFS
    Client v3 connections to an NFS version 3 server. This can only be
    selected if NFS support (CONFIG\_NFS\_FS) is also selected.

#### NFS server support (CONFIG\_NFSD): Kernel space only.

-   When you select this, you get a LinuxNFS Server *kernel-space*
    NFS-server supporting NFS protocol version 2. Additional software is
    needed to control the kernel-space NFS-server (as will be shown
    later). To run an old-fashioned user-space NFS-server this option is
    not needed. Select CONFIG\_NFS instead.

#### Provide NFSv3 server support (CONFIG\_NFSD\_V3):

-   This option adds support for version 3 of the NFS LinuxNFS Server v3
    protocol to the kernel-space NFS-server. The kernel-space NFS-server
    will support both version 2 and 3 of the NFS protocol. You can only
    select this if you also select NFS server support (CONFIG\_NFSD).

When configuring during a compiler build (i.e., make menuconfig, make
xconfig, etc), the options listed above can be found in the *File
Systems* section, subsection *Network File Systems*.

[Kernel options for NFS](#NFSkernelTable) provides an overview of NFS
support in the kernel.

|Description|option(s) |allows / provides|
|----|----|----|
|  NFS file system support   |CONFIG\_NFS\_FS |                      allows both NFS (v2) client and user space NFS (v2) server|
|NFSv3 client support |     CONFIG\_NFS\_FS and CONFIG\_NFS\_V3   |allows NFS (v2 + v3) client|
|NFS server support|        CONFIG\_NFSD |                         provides NFS (v2) kernel server|
|NFSv3 server support|      CONFIG\_NFSD and CONFIG\_NFSD\_V3  |   provides NFS (v2 + v3) kernel server|

Selecting at least one of the NFS kernel options turns on Sun RPC
(Remote Procedure Call) support automatically. RPC This results in a
kernel space RPC input/output daemon. It can be recognised as `[rpciod]`in the process listing.

###   The portmapper

The portmapper is used to interface TCP/IP connections to the
appropriate RPC calls. It is needed for all NFS traffic because not only does it map (incoming) TCP connections to NFS (RPC) calls, it also
can be used to map different NFS versions to different ports on which
NFS is running. Most distributions will install the portmapper if NFS
software (other than the kernel) is being installed.

The portmapper itself need not be configured. Portmapper security,
however, *is* an issue: you are strongly advised to limit access to the
portmapper. This can be NFSportmapper security done using the tcp
wrapper.

####  Securing the portmapper

First, make sure the portmapper has support for the tcp wrapper built-in
(since it isn't started through inetd, portmapper needs its own
built-in tcpwrapper support). You can test this by running
`ldd /sbin/portmap`. The result could be something like

        libwrap.so.0 => /lib/libwrap.so.0 (0x40018000)
        libnsl.so.1 => /lib/libnsl.so.1 (0x40020000)
        libc.so.6 => /lib/libc.so.6 (0x40036000)
        /lib/ld-linux.so.2 => /lib/ld-linux.so.2 (0x40000000)
                        

The line with `libwrap.so.0` (libwrap belongs to the tcp wrapper) shows
that this portmapper is tcp wrapper compiled with tcp-wrapper support.
If that line is missing, get a better portmapper or compile one
yourself.

A common security strategy is blocking incoming portmapper requests by
default, but allowing specific hosts to connect. This strategy will be
described here.

Start by editing the file `/etc/hosts.deny` and adding the following
line:

        portmap: ALL
                    

This denies every system access to the portmapper. It can be extended
with a command:

        portmap: ALL: (echo illegal rpc request from %h | mail root) &
                    

Now all portmapper requests are denied. In the second example, requests
are denied and reported to root.

The next step is allowing only those systems access that *are* allowed
to do so. This is done by putting a line in `/etc/hosts.allow`:

        portmap: 121.122.123.
                        

This allows each host with an IP address starting with the numbers shown
to connect to the portmapper and, therefore, use NFS. Another
possibility is specifying part of a hostname:

        portmap: .example.com
                        

This allows all hosts inside the example.com domain to connect. To allow
all hosts of a NIS workgroup:

        portmap: @workstations
                        

To allow hosts with IP addresses in a subnet:

        portmap: 192.168.24.16/255.255.255.248
                        

This allows all hosts from 192.168.24.16 to 192.168.24.23 to connect
(examples from [???](#Zadok01)).

####  portmap and rpcbind

Some linux distributions use portmap. Other linux distributions use
rpcbind.

The portmap daemon is replaced by rpcbind. Rpcbind has more features,
like ipv6 support and nfs4 support.

###   General NFS daemons {#nfs}

####  The `nfs-utils` package

NFS is implemented as a set of daemons. These NFSrpc.nfsd NFSrpc.mountd
NFSrpc.lockd NFSrpc.statd can be recognized by their name: they all
start with the *rpc.* prefix followed by the name of the daemon. Among
these are: `rpc.nfsd` (only a support program in systems with a kernel
NFS server), `rpc.mountd`, `rpc.lockd` and `rpc.statd`.

The source for these daemons can be found in the `nfs-utils` package
(see [NFS](#nfs) for more information on nfs-utils). It will also
contain the source of other support programs, such as `exportfs`,
`showmount` and `nfsstat`. These will be discussed later in [Exporting
NFS](#exportingNFS) and [Testing NFS](#TestingNFS).

Distributions may provide `nfs-utils` as a ready-to-use package,
sometimes under different names. Debian, for example, provides lock and
status daemons in a special `nfs-common` package, and the NFS and mount
daemons in `nfs-*server` packages (which come in user-space and
kernel-space versions).

Each of the daemons mentioned here can also be secured using the tcp
wrapper. Details in [Securing NFS](#SecuringNFS).

###   NFS server software

####  The NFS daemon

When implementing an NFS server, you can install support for an
*kernel-space* or an *user-space* NFS server, depending on the kernel
NFSkernel space NFSuser space configuration. The `rpc.nfsd` command
(sometimes called `nfsd`) **is** the complete NFS server in user space.
In kernel space, however, it is just a support program that can start
the NFS server in the kernel.

The kernel-space NFS server

-   The kernel-space NFS server is part of the running kernel. A kernel
    NFS server appears as `[nfsd]` in the process list.

    The version of `rpc.nfsd` that supports the NFS server inside the
    kernel is just a support program to control NFS kernel server(s).

The user-space NFS daemon

-   The `rpc.nfsd` program can also contain an old-fashioned user-space
    NFS server (version 2 only). A user-space NFS server *is* a complete
    NFS server. It can be recognized as `rpc.nfsd` in the process list.

####  The mount daemon

The `mountd` (or `rpc.mountd`) mount-daemon handles incoming NFS
(mount) requests. It is required on a system that provides NFS server
support.

The configuration of the mount daemon includes *exporting* (making
available) a filesystem to certain hosts and specifying how they can use
this filesystem.

Exporting filesystems, using the `/etc/exports` /etc/exports file and
the `exportfs` command exportfs will be discussed in [Exporting
NFS].

####  The lock daemon

A lock daemon for NFS is implemented in `rpc.lockd`.

You won't need lock-daemon support when using modern (2.4.x) kernels. FIXME modern kernels
These kernels provide one internally, which can be recognized as
`[lockd]` in Linuxlockd the process list. Since the internal kernel
lock-daemon takes precedence, starting `rpc.lockd` accidentally will do
no harm.

There is no configuration for `rpc.lockd`.

####  The status daemon

According to the manual page, the status daemon `rpc.statd` implements
only a reboot notification service. It is a user-space daemon - even on
systems with kernel-space NFS version 3 support. It can be recognized as
`rpc.statd` in the process listing. It is used on systems with NFS
client and NFS server support.

There is no configuration for `rpc.statd`.

###   Exporting filesystems {#exportingNFS}

Exporting a filesystem, or part of it, makes it available for use by
another system. A filesystem can be exported to a single host, a group
of hosts or to everyone.

Export definitions are configured in the file `/etc/exports` and will be
activated by the /etc/exports `exportfs` command. The current export
list can be queried with the command `showmount --exports`. showmount

**Note**
In examples below the system called `nfsshop` will be the NFS server and
the system called `clientN` one of the clients.

####  The file `/etc/exports`

The file `/etc/exports` contains the definition(s) of filesystem(s) to
be exported, the name of the host that is allowed to access it and how
the host can access it.

Each line in `/etc/exports` has the following format:

            /dir hostname(options) ...
                        

-   Name of the directory to be exported

-   The name of the system (host) that is allowed to access /dir (the
    exported directory). If the name of the system is omitted *all*
    hosts can connect. There are five possibilities to specify a system
    name:

    single hostname

    -  The name of a host that is allowed to connect. Can be a name
        (`clientN`) or an IP address.

    wildcard

    -   A group of systems is allowed. All systems in the `example.com`
        domain will be allowed by the `*.example.com` wildcard.

    IP networks

    -   Ranges of ip numbers or address/subnetmask combinations.

    nothing

    -   Leaving the system part empty is mostly done by accident (see
        the Caution below). It allows *all* hosts to connect. To prevent
        this error, make sure that there is no spacing between the
        system name and the opening brace that starts the options.

    @NISgroup

    -   NIS workgroups can be specified as a name starting with an `@`.

-   Options between braces. Will be discussed further on.

-   More than one system with options can be listed:

            /home/ftp/pub clientN(rw) *.example.com(ro)
                                        

    Explanation: system `clientN` is allowed to read and write in
    `/home/ftp/pub`. Systems in `example.com` are allowed to connect,
    but only to read.

Make sure there is *no space* (not even white) between the hostname and
the specification between braces. There is a lot of difference between

        /home/ftp/pub clientN(rw)
                                

and

        /home/ftp/pub clientN (rw)
                                

The first allows `clientN` read and write access. The second allows
`clientN` access with default options (see `man 5 exports`) and *all
systems* read and write access!

#### Export options

Several export options can be used in `/etc/exports`. Only the most
important will be discussed here. See the exports(5) manual page for a
full list. Two types of options will be listed here: general options and
user/group id options.

`ro` (default)

-   The client(s) has only read access. NFSro

`rw`

-   The client(s) has read and write access. Of course, the NFSrw client
    may choose to mount read-only anyway.

Also relevant is the way NFS handles user and group permissions across
systems. NFS software considers users with the same UID and the same
username as the same users. The same is true for GIDs.

The user `root` is different. Because `root` can read (and write)
everything, root permission over NFS is considered dangerous.

A solution to this is called *squashing*: NFSsquashing all requests are
done as user `nobody` (actually UID `65534`, often called `-2`) and
group `nobody` (GID `65534`).

At least four options are related to squashing: `root_squash`,
NFSroot\_squash `no_root_squash`, NFSno\_root\_squash `all_squash` and
NFSall\_squash `no_all_squash`. NFSno\_all\_squash Each will be
discussed in detail.

`root_squash` (default)

-   All requests by user `root` on `clientN` (the client) will be done
    as user `nobody` on `nfsshop` (the server). This implies, for
    instance, that user `root` on the client can only read files on the
    server that are *world readable*.

`no_root_squash`

-   All requests as `root` on the client will be done as `root` on the
    server.

    This is necessary when, for instance, backups are to be made over
    NFS.

    This implies that root on `nfsshop` completely trusts user root on
    `clientN`.

`all_squash`

-   Requests of any user other than root on `clientN` are performed as
    user `nobody` on `nfsshop`.

    Use this if you cannot map usernames and UID's easily.

`no_all_squash` (default)

-   All requests of a non-root user on `clientN` are attempted as the
    same user on `nfsshop`.

Example entry in `/etc/exports` on system `nfsshop` (the server system):

        /    client5(ro,no_root_squash) *.example.com(ro)
                            

System `nfsshop` allows system `client5` *read-only* access to
everything and reads by user root are done as root on `nfsshop`. Systems
from the `example.com` domain are allowed *read-only* access, but
requests from root are done as user `nobody`, because `root_squash` is
true by default.

Here is an example file:

        # /etc/exports on nfsshop
        # the access control list for filesystems which may be exported
        # to NFS clients.  See exports(5).

        / client2.exworks(ro,root_squash)
        / client3.exworks(ro,root_squash)
        / client4.exworks(ro,root_squash)
        /home client9.exworks(ro,root_squash)
                            

Explanation: `client2`, `client3` and `client4` are allowed to mount the
complete filesystem (`/`: root). But they have read-only access and
requests are done as user `nobody`. The host `client9` is only allowed
to mount the `/home` directory with the same rights as the other three
hosts.

####  The `exportfs` command

Once `/etc/exports` is configured, the export exportfs list in it can be
activated using the `exportfs` command. It can also be used to reload
the list after a change or deactivate the export list. [Exportfs and
fstab](#exportfstab) shows some of the functionality of `exportfs`.

  Command          Description
  ---------------- --------------------------------------------
  `exportfs -r`    reexport all directories
  `exportfs -a`    export or unexport all directories
  `exportfs -ua`   de-activate the export list (unexport all)

  : Overview of `exportfs`

**Note**
Older (user-space) NFS systems may not have the `exportfs` command. On
these systems the export list will be installed automatically by the
mount daemon when it is started. Reloading after a change is done by
sending a `SIGHUP` signal to the running mount-daemon NFSSIGHUP process.

#### Activating an export list

The export list is activated (or reactivated) with the following
command:

        exportfs -r
                            

The `r` originates from the word NFS-r *re-exporting*.

Before the `exportfs -r` is issued, no filesystems are exported and no
other system can connect.

When the export list is activated, the kernel export table will be
filled. The following command will show the kernel export table:

        cat /proc/fs/nfs/exports
                            

The output will look something like:

        # Version 1.1
        # Path Client(Flags) # IPs
        /   client4.exworks(ro,root_squash,async,wdelay) # 192.168.72.4
        /home   client9.exworks(ro,root_squash,async,wdelay) # 192.168.72.9
        /   client2.exworks(ro,root_squash,async,wdelay) # 192.168.72.2
        /   client3.exworks(ro,root_squash,async,wdelay) # 192.168.72.3
                            

Explanation: all named hosts are allowed to mount the root directory
(`client9`: `/home`) of this machine with the listed options. The IP
addresses are listed for convenience.

Also use `exportfs -r` after you have made changes to `/etc/exports` on
a running system.

When running `exportfs -r`, some things will be done in the directory
`/var/lib/nfs`. Files there are easy to corrupt by human intervention
with far-reaching consequences.

#### Deactivating an export list

All active export entries are unexported with the command:

        exportfs -ua
                            

The letters `ua` are an abbreviation for NFS-ua *unexport all*.

After the `exportfs -ua` no exports are active anymore.

####  The `showmount` command {#showmount}

The `showmount` command shows information about the exported file systems.


|Command |         Description|
|----|----|
|  `showmount --exports`|       show active export list|
  |showmount`  |               show names of clients with active mounts|
|  `showmount --directories`  | show directories that are mounted by remote clients|
|  `showmount --all`      |     show both client-names and directories|


`showmount` accepts a host name as its last argument. If present,
`showmount` will query the NFS-server on that host. If omitted, the
current host will be queried (as in the examples below, where the
current host is called `nfsshop`).

**With the `--exports` option.**

showmount lists the currently active export list:

        # showmount --exports
        Export list for nfsshop:
        / client2.exworks,client3.exworks,client4.exworks
        /home client9.exworks
                            

The information is more sparse compared to the output of
`cat /proc/fs/nfs/exports` shown earlier.

**Without options.**

`showmount` will show names of hosts currently connected to the system:

        # showmount
        Hosts on nfsshop:
        client9.exworks
                            

**With the `--directories` option.**

`showmount` will show NFS\--directories names of directories that are
currently mounted by a remote host:

        # showmount --directories
        Directories on nfsshop:
        /home
                            

**With the `--all` option.**

the `showmount` command lists both the remote client (hosts)
and the mounted directories:

        # showmount --all
        All mount points on nfsshop:
        client9.exworks:/home
                            

###   NFS client: software and configuration

An NFS *client* system is a system that does a mount-attempt, using the
`mount` command. The `mount` needs to have support for NFS built-in.
This will generally be the case.

The NFS client-system needs to have appropriate NFS support in the
kernel, as shown earlier (see [Configuring NFS](#NFSkernel)). Next, it
needs a running *portmapper*. Last, software is needed to perform the
remote mounts attempt: the `mount` command.

**Note**
Familiarity with the `mount` command and the file `/etc/fstab` is
assumed in this paragraph. If in doubt, consult the appropriate manual
pages.

The `mount` command normally used NFSmount mount to mount a remote
filesystem through NFS:

        mount -t nfs remote:/there  /here
                    

-   This specifies the filesystem /there on the remote server remote.

-   The mount point /here on the client, as usual.

Example: to mount the `/usr` filesystem, which is on server system
`nfsshop`, onto the local mount-point `/usr`, use:

        mount -t nfs nfsshop:/usr /usr
                    

Fine-tuning of the mount request is done through *options*.

        mount -t nfs -o opts remote:/there /here
                    

-   Several options are possible after the `-o` option selector. These
    options affect either mount attempts or active NFS connections.

`ro` versus `rw`

-   If `ro` is specified the remote NFS filesystem will be mounted
    *read-only*. With the `rw` option the remote filesystem will be made
    available for both reading and writing (if the NFS server agrees).


    The default on the NFS server side (`/etc/exports`) is `ro`, but the
    default on the client side (`mount -t nfs`) is `rw`. The
    server-setting takes precedence, so mounts will be done *read-only*.

**Note**
    `-o ro` can also be written as `-r`; `-o rw` can also be written as
    `-w`.


`rsize=nnn` and `wsize=nnn`

-   The `rsize` option specifies the size for NFSrsize NFSwsize read
    transfers (from server to client). The `wsize` option specifies the
    opposite direction. A higher number makes data transfers faster on a
    reliable network. On a network where many retries are needed,
    transfers may become slower.

    Default values are either `1024` or and `4096`, depending on your
    kernel NFS1024 NFS4096 version. Current kernels accept a maximum of
    up to `8192`. NFS8192 NFS version 3 over `tcp`, which will probably
    production-ready by the time you read this, allows a maximum size of
    `32768`. This size is defined with `NFSSVC_MAXBLKSIZE` in the file
    NFSNFSSVC\_MAXBLKSIZE `include/linux/nfsd/const.h` found in the
    kernel source-archive.

`udp` and `tcp`

-   Specifies the transport-layer protocol for the NFS connection. Most
    NFS version 2 implementations support only `udp`, but `tcp`
    implementations do exist. NFSudp NFStcp NFS version 3 will allow
    both `udp` and `tcp` (the latter is under active development).
    Future version 4 will allow only `tcp`. See [NFS protocol
    versions](#NFSversions).

`nfsvers=n`
 
-   Specifies the NFS version used for the transport (see [NFS protocol
    versions](#NFSversions)). Modern versions of `mount` will use
    version `3` by default. Older implementations that NFSnfsvers= still
    use version `2` are probably numerous.

`retry=`n

-   The `retry` option specifies the number of NFSretry= minutes to keep
    on retrying mount-attempts before giving up. The default is `10000`
    minutes.

`timeo=`n

-   The `timeo` option specifies after how much time a mount-attempt
    times out. The time-out value is NFStimeo= specified in deci-seconds
    (tenth of a second). The default is `7` deci-seconds (0.7 seconds).

`hard` (default) versus `soft`

-   These options control how hard the system will try. NFShard

    `hard`

    :   The system will try indefinitely.

    `soft`

    :   The system will try until an RPC (portmapper) timeout NFSsoft
        occurs.

`intr` versus `nointr` (default)

-   With these options one is able to control whether the user NFSintr
    NFSnointr is allowed to interrupt the mount-attempt.

    `intr`

    :   A mount-attempt can be interrupted by the user if `intr` is
        specified.

    `nointr`

    :   A mount-attempt cannot be interrupted by a user if `nointr` is
        set. The mount request can seem to hang for days if `retry` has
        its default value (10000 minutes).

`fg` (default) and `bg`

-   These options control the *background mounting* facility. It is off
    by default.

    `bg`

    :   NFSbg This turns on *background mounting*: the client first
        tries to mount in the foreground. All retries occur in the
        background.

    `fg`

    :   All attempts occur in the foreground. 

    *Background mounting* is also affected by other options. When `intr`
    is specified, the mount attempt will be interrupted by a an RPC
    timeout. This happens, for example, when either the remote host is
    down or the portmapper is not running. In a test setting the
    backgrounding was only done when a "connection refused" occurred.

Options can be combined using comma's:

        mount -t nfs -o ro,rsize=8192 nfsshop:/usr/share /usr/local/share
                    

A preferred combination of options might be: `hard`, `intr` and `bg`.
The mount will be tried indefinitely, with retries in the background,
but can still be interrupted by the user that started the mount.

Other mount options to consider are `noatime`, `noauto`, `nosuid` or
even `noexec`. See `man 1 mount` and `man 5 nfs`. NFSnoatime NFSnoauto
NFSnosuid NFSnoexec

Of course, all these options can also be specified in `/etc/fstab`. Be
sure to specify the `noauto` option if the filesystem should **not** be
mounted automatically at boot time. The `user` option will allow
non-root users to perform the mount. This is not default. Example entry
in `/etc/fstab`:

        nfsshop:/home /homesOnShop  nfs ro,noauto,user   0  0
                    

Now every user can do

        mount /homesOnShop
                    

You can also use automounters to mount and unmount remote automount
filesystems. However, these are beyond the scope of this objective.

Testing NFS {#TestingNFS}

After NFS has been set up, it can be tested. The following tools can
help: `showmount`, `rpcinfo` and `nfsstat`.

###   The `showmount --exports` command

As shown in [showmount](#showmount), the `showmount
                --exports` command lists the current exports for a
server system. This can be used as a quick indication of the health of
the created NFS system. showmount Nevertheless, there are more
sophisticated ways of doing this.

###   The `/proc/mounts` file

To see which file systems are mounted check /proc/mounts. It will also
show nfs mounted filesystems.

        $ cat /proc/mounts
                    

###   `rpcinfo`

portmapper The `rpcinfo` command reports RPC information. This can be
used to probe the portmapper on a local or a remote rpcinfo system or to
send pseudo requests.

####  rpcinfo: probing a system

The `rpcinfo -p` command lists all registered services the portmapper
knows about. Each *rpc\...* program registers itself at startup with the
portmapper, so the names shown correspond to real daemons (or the kernel
equivalents, as is the case for NFS version 3).

It can be used on the server system `nfsshop` to see if the portmapper
is functioning:

        program vers proto   port
        100003    3   udp   2049  nfs
                        

This selection of the output shows that this portmapper will accept
connections for nfs version 3 on udp.

A full sample output of `rpcinfo -p>` on a server system:

        rpcinfo -p
        program vers proto   port
         100000    2   tcp    111  portmapper
         100000    2   udp    111  portmapper
         100024    1   udp    757  status
         100024    1   tcp    759  status
         100003    2   udp   2049  nfs
         100003    3   udp   2049  nfs
         100021    1   udp  32770  nlockmgr
         100021    3   udp  32770  nlockmgr
         100021    4   udp  32770  nlockmgr
         100005    1   udp  32771  mountd
         100005    1   tcp  32768  mountd
         100005    2   udp  32771  mountd
         100005    2   tcp  32768  mountd
         100005    3   udp  32771  mountd
         100005    3   tcp  32768  mountd
                        

As can be seen in the listing above, the portmapper will accept RPC
requests for versions 2 and 3 of the NFS protocol, both on udp.

**Note**
As can be seen, each RPC service has its own version number. The
`mountd` service, for instance, supports incoming connections for
versions 1, 2 or 3 of mountd on both udp and tcp.

It is also possible to probe `nfsshop` (the server system) from a client
system, by specifying the name of the server system after `-p`:

        rpcinfo -p nfsshop
                        

The output, if all is well of course, will be the same.

####  rpcinfo: making *null* requests

It is possible to test a connection without doing any real work:

> `rpcinfo -u` *remotehost program*

This is like the `ping` command to test a network connection. However,
`rpcinfo -u` works like a real rpc/nfs connection, sending a so-called
*null* pseudo request. The `-u` option forces `rpcinfo` to use udp
transport. The result of the test on `nfsshop`:

        rpcinfo -u nfsshop nfs
        program 100003 version 2 ready and waiting
        program 100003 version 3 ready and waiting
                        

The `-t` options will do the same for tcp transport:

        rpcinfo -t nfsshop nfs
        rpcinfo: RPC: Program not registered
        program 100003 is not available
                        

This system obviously does have support for nfs on udp, but not on tcp.

**Note**
In the example output, the number 100003 is used instead of or together
with the name `nfs`. Name or number can be used in each others place.
That is, we could also have written:

        rpcinfo -u nfsshop 100003
                            

###   The `nfsstat` command

The `nfsstat` command lists statistics (i.e., counters) about
connections. This can be used to see whether something is going on at
all and also to make sure nothing has gone crazy.

[table\_title](#nfsstatTab) provides an overview of relevant options for
`nfsstat`.

           rpc     nfs     both
  -------- ------- ------- -------
  server   `-sr`   `-sn`   `-s`
  client   `-cr`   `-cn`   `-c`
  both     `-r`    `-n`    `-nr`

  : Some options for the `nfsstat` program

Sample output from `nfsstat -sn` on the server host `nfsshop`:

        Server nfs v2:
        null       getattr    setattr    root       lookup     readlink   
        1       0% 3       0% 0       0% 0       0% 41      0% 0       0% 
        read       wrcache    write      create     remove     rename     
        5595   99% 0       0% 0       0% 1       0% 0       0% 0       0% 
        link       symlink    mkdir      rmdir      readdir    fsstat     
        0       0% 0       0% 0       0% 0       0% 7       0% 2       0% 

        Server nfs v3:
        null       getattr    setattr    lookup     access     readlink   
        1     100% 0       0% 0       0% 0       0% 0       0% 0       0% 
        read       write      create     mkdir      symlink    mknod      
        0       0% 0       0% 0       0% 0       0% 0       0% 0       0% 
        remove     rmdir      rename     link       readdir    readdirplus
        0       0% 0       0% 0       0% 0       0% 0       0% 0       0% 
        fsstat     fsinfo     pathconf   commit     
        0       0% 0       0% 0       0% 0       0% 
                    

The `1`'s under both `null` headings are the result of the `rpcinfo -u 
                nfsshop nfs` command shown earlier.

##  Securing NFS 

NFS security has several unrelated issues. First, the NFS protocol and
implementations have some known weaknesses. NFS file-handles are numbers
that should be random, but are not, in NFSsecuring reality. This opens
the possibility of making a connection by guessing file-handles. Another
problem is that all NFS data transfer is done as-is. This means that
anyone able to listen to a connection can tap the information (this is
called sniffing). Bad mount-point names combined with human error can be
a completely different security risk.

###   Limiting access

Both sniffing and unwanted connection requests can be prevented by
limiting access to each NFS server to a set of known, trusted hosts
containing trusted users: within a small workgroup, for instance.
Tcp-wrapper support or firewall software can be used to limit access to
an NFS server.

**The tcp wrapper.**

Earlier on it was shown how to
limit connections to the portmapper from specific hosts. The same can be
done for the NFS related daemons, i.e., `rpc.mountd` and `rpc.statd`. If
your system runs an old-fashioned user-space NFS server (i.e., has
`rpc.nfsd` in the process list), consider protecting `rpc.nfsd` and
possibly `rpc.lockd`, as well. If, on the other hand, your system is
running a modern kernel-based NFS implementation (i.e., has `[nfsd]` in
the process list), you cannot do this, since the `rpc.nfsd` program is
not the one accepting the connections. Make sure tcp-wrapper support is
built into each daemon you wish to protect.

**Firewall software.**

The problem with tcp-wrapper support is that there already is a
connection inside the host at the time that the connection-request is
refused. If a security-related bug exists within either the tcp-wrapper
library or the daemon that contains the
support, unwanted access could be granted. Firewall software
(e.g., iptables) can make the kernel block connections before they enter
the host. You may consider blocking unwanted NFS connections at each NFS
server host or at the entry point of a network to all but acceptable
hosts. Block at least the portmapper port (111/udp and 111/tcp). Also,
considering blocking 2049/udp and 2049/tcp (NFS connections). You might
also want to block other ports like the ones shown with the `rpcinfo -p`
command: for example, the mount daemon ports 32771/udp and 32768/tcp.
How to set up a firewall is shown in detail in [???](#chapterSecurity).

###   Preventing human error

Simple human error in combination with bad naming may also result in a
security risk. You would not be the first person to remove a remote
directory tree because the mount point was not easily recognized as such
and the remote system was mounted with *read-write* permissions.

**Mount *read-only*.**

Mounting a remote filesystem *read-only* can prevent accidental erasure.
So, mount *read-only* whenever possible. If you do need to mount a part
*read-write*, make the part that can be written (erased) as small as
possible.

**Design your mountpoints well.**

Also, name a mount point so that it can easily be recognized as a mount
point. One of the possibilities is to use a special name:

        /MountPoints/nfsshop
                        

###   Best NFS version

Progress has been made in NFS software. Although no software can prevent
human error, other risks (e.g., guessable file-handles and sniffing) can
be prevented with better software.

**Note**
NFS version 4 is a new version of the NFS protocol intended to fix
NFSversion 4 all existing problems in NFS. At the time of this writing
(May 2014) versions 4.0 and 4.1 have been released; version 4.2 is being
developed. More about NFS version 4 and differences between earlier
versions is covered in [NFS protocol versions](#NFSversions).

**Guessable file handles.**

One of the ways to break in a NFS server is to guess so-called
file-handles. The old (32-bit) file-handles (used in NFS version 2) were
rather easy to guess. NFSfile handles Version 3 of the NFS protocol
offers improved security by using 64-bit file-handles that are
considerably harder to guess.

**Version 4 security enhancements.**

Version 4 of the NFS protocol defines encrypted connections. When the
connection is encrypted, getting information by sniffing is made much
harder or even impossible.

Overview of NFS components 

[table\_title](#NFSsoft) provides an overview of the most important
files and software related to NFS.

|program or file  |description|
|----|----|
|The kernel |provides NFS support|
|`portmap`|                            handles RPC requests|
  |`rpc.nfsd` |                                 NFS server control (kernel space) or software (user space)|
|  `rpc.mountd` |                               handles incoming (un)mount requests|
 | `/etc/exports`       |              defines which filesystems are exported|
|`exportfs` command    |                  (un)exports filesystems|
|  `showmount --exports`  |                     shows current exports|
|  The `rpcinfo` command   |                    reports RPC information|
|  The `nfsstat` command   |                    reports NFS statistics|
 | `showmount --all`   |                        shows active mounts to me (this host)|
|  `mount -t nfs          |                     mounts a remote filesystem|
||                              remote:/there   |
||                              /here`          |
| `umount -t nfs -a`    |                      unmounts all remote filesystems|


###   NFS protocol versions 

Currently, there are a lot of changes in the NFS protocol that can
affect the way the system is set up. 
  
|Protocol version |  Current status|      kernel or user space |  udp or tcp transport                                                                |
|----|----|----|----|
|  1  |    never released   ||                                                                                                              
|  2   |               becoming obsolete   |user, kernel |          udp, some tcp impl. exist         |                                                  
|  3 |                 new standard |       kernel  |              udp, tcp: under development                         |                                
|  4 |                 new standard |       kernel    |             tcp                           performance improvements;   mandates strong security;   stateful protocol|

The trends that can be seen in this table 
are: kernel space instead of user space and tcp instead of udp.

**A note on the transport protocol.**

Connections over `tcp` (NFS v3, v4, some v2) are considered better than
connections over `udp` (NFS v2, v3). The `udp` option might be the best
on a small, fast network. But `tcp` allows considerably larger packet
sizes (`rsize`, `wsize`) to be set. With sizes of 64k, `tcp` connections
are reported to be 10% faster than connections over `udp`, which does
not allow sizes that large. Also, `tcp` is a more reliable protocol by
design, compared to `udp`. 

###   NFSv4

NFS version 4 (NFSv4) offers some new features compared to its
predecessors. Instead of exporting multiple filesystems, NFSv4 exports a
single pseudo file system for each client. The origin for this pseudo
file system may be from different filesystems, but this remains
transparent to the client.

NFSv4 offers an extended set of attributes, including support form MS
Windows ACL's. Although NFSv4 offers enhanced security features
compared to previous versions of NFS, and has been around since 2003, it
was never widely adopted. Users are encouraged to implement NFSv4.1
which has been ratified in January 2010. 

