##  Customizing system startup (202.1)

Candidates should be able to query and modify the behaviour of system
services at various targets / run levels. A thorough understanding of
the systemd, SysV Init and the Linux boot proces is required. This
objective includes interacting with systemd targets and SysV init run
levels.

###   Key Knowledge Areas

-   Systemd

-   SysV init

-   Linux Standard Base Specification (LSB)

###   Terms and Utilities

-   `/usr/lib/systemd/`

-   `/etc/systemd/`

-   `/run/systemd/`

-   `systemctl`

-   `systemd-delta`

-   `/etc/inittab`

-   `/etc/init.d/`

-   `/etc/rc.d/`

-   `chkconfig`

-   `update-rc.d`

-   `init and telinit`

###   Create `initrd` using `mkinitrd`

**Note**

[`mkinitrd` was discussed in a previous section](#c2.201.mkinitrd),
which also discusses how to create such an image manually.


To limit the size of the kernel, often initial ramdisk (initrd) images
are used to preload any modules needed to access the root filesystem.

The `mkinitrd` is a tool which is specific to RPM based distributions
(such as Red Hat, SuSE, etc.). This tool automates the process of
creating an `initrd` file, thereby making sure that the relatively
complex process is followed correctly.

In most of the larger Linux distributions the `initrd` image contains
almost all necessary kernel modules; very few will be compiled directly
into the kernel. This enables the deployment of easy fixes and patches
to the kernel and its modules through RPM packages: an update of a
single module will not require a recompilation or replacement of the
whole kernel, but just the single module, or worst case a few dependent
modules. Because these modules are contained within the `initrd` file,
this file needs to be regenerated every time the kernel is (manually)
recompiled, or a kernel (module) patch is installed. Generating a new
`initrd` image is very simple if you use the standard tool provided on
many distributions:

        # mkinitrd initrd-image kernel-version
                

Useful options for `mkinitrd` include:

`--version`

-   This option displays the version number of the `mkinitrd` utility.

`-f`

-   By specifying this switch, the utility will overwrite any existing
    image file with the same name.

`--builtin=`

-   This causes `mkinitrd` to assume the module specified was compiled
    into the kernel. It will not look for the module and will not show
    any errors if it does not exist.

`--omit-lvm-modules`, `--omit-raid-modules`, `--omit-scsi-modules`

-   Using these options it is possible to prevent inclusion of,
    respectively, LVM, RAID or SCSI modules, even if they are present,
    or the utility would normally include them based on the contents of
    `/etc/fstab` and/or `/etc/raidtab`.

###   Create `initrd` using `mkinitramfs` {#mkinitramfsmc}

Dissatisfied with the tool the RPM based distributions use (`mkinitrd`),
some Debian developers wrote another utility to generate an `initrd`
file. This tool is called `mkinitramfs`. The `mkinitramfs` tool is a
shell script which generates a gzipped cpio image. It was designed to be
much simpler (in code as well as in usage) than `mkinitrd`. The script
consists of around 380 lines of code.

Configuration of mkinitramfs is done through a configuration file:
`initramfs.conf`. This file is usually located in
`/etc/initramfs-tools/initramfs.conf`. This configuration file is
sourced by the script - it contains standard `bash` declarations.
Comments are prefixed by a \#. Variables are specified by:

        variable=value
                

Options which can be used with `mkinitramfs` include:

`-d confdir`

-   This option sets an alternate configuration directory.

`-k`

-   "Keep" the temporary directory used for creating the image.

`-o outfile`

-   Write the resulting image to `outfile`.

`-r root`

-   Override the `ROOT` setting in the `initramfs.conf` file.

**Note**
On Debian(-based) distributions you should *always* use `mkinitramfs` as
`mkinitrd` is broken there for more recent kernels.

###   Setting the root device

Setting the root device is one of the many kernel settings. Kernel
settings originate from or can be overwritten by:

-   defaults as set in the source code,

-   defaults as set by the `rdev` command,

-   values passed to the kernel at boot time, for example
    `root=/dev/xyz`

-   values specified in the GRUB configuration file.

The most obvious to use are block devices like harddisks, SAN storage,
CDs or DVDs. You can even have a NFS mounted root-disk, this requires
usage of `initrd` and setting the `nfs_root_name` and `nfs_root_addrs`
boot options. You can set or change the root device to almost anything
from within the `initrd` environment. In order to do so, make sure that
the `/proc` filesystem was mounted by the scripts in the `initrd` image.
The following files are available in `/proc`:

        /proc/sys/kernel/real-root-dev
        /proc/sys/kernel/nfs-root-name
        /proc/sys/kernel/nfs-root-addrs
                

The `real-root-dev` refers to the node number of the root file system
device. It can be easily changed by writing the new number to it:

        # echo 0x301>/proc/sys/kernel/real-root-dev
                

This will change the real root to the filesystem on `/dev/hda1`. If you
wish to use an NFS-mounted root, the files `nfs-root-name` and
`nfs-root-addrs` have to be set using the appropriate values and the
device number should be set to 0xff:

        # echo /var/nfsroot >/proc/sys/kernel/nfs-root-name
        # echo 193.8.232.2:193.8.232.7::255.255.255.0:idefix \
          >/proc/sys/kernel/nfs-root-addrs
        # echo 255>/proc/sys/kernel/real-root-dev
                

**Note**
If the root device is set to the RAM disk, the root filesystem is not
moved to `/initrd`, but the boot procedure is simply continued by
starting init on the initial RAM disk.

###   The Linux Boot process


There are seven phases distinguishable during boot:

1.  Kernel loader loading, setup and execution

2.  Register setup

3.  Kernel decompression

4.  Kernel and memory initialization

5.  Kernel setup

6.  Enabling of remaining CPU's

7.  Init process creation

The boot process is described in detail at [Gustavo Duarte's "The
Kernel Boot
Process"](http://duartes.org/gustavo/blog/post/kernel-boot-process)

The kernel's final step in the boot process  tries to execute these
commands in order, until one succeeds:

1.  /sbin/init

2.  /etc/init

3.  /bin/init

4.  /bin/sh

If none of these succeed, the kernel will panic.

###   The `init` process

init` is the parent of all processes, it reads the file
`/etc/inittab` and creates processes based on its contents. One of the
things it usually does is spawn `gettys` allowing users to log in. It
also defines "runlevels".

A "runlevel" is a software configuration of the system which allows only
a selected group of processes to exist. runlevel

####  runlevel 0 (reserved)

-   Runlevel 0 is used to halt the system.

####  runlevel 1 (reserved)

-   Runlevel 1 is used to get the system in single user mode. runlevel 1

####  runlevel 2-5

-   Runlevels 2,3,4 and 5 are multi-user runlevels. runlevel 2-5
    multi-user runlevels

####  runlevel 6

-   Runlevel 6 is used to reboot the system. runlevel 6 reboot

####  runlevel 7-9

-   Runlevels 7, 8 and 9 can be used as you wish. Most of the
    Unix(/Linux) variants don't use these runlevels. On a typical
    Debian Linux System for instance, the `/etc/rc<runlevel>.d `
    directories, which we will discuss later, are not available for
    these runlevels, though that would be perfectly legal.

####  runlevel s or S

-   Runlevels s and S are internally the same. It brings runlevel s
    runlevel S the system in "single-user mode". The scripts in the
    `/etc/rcS.d` directory are executed when booting the system.
    Although runlevel S is not meant to be activated by the user, it can
    be.

####  runlevels A, B and C

-   Runlevels A, B and C are so called "on demand" runlevels. If the
    current runlevel is "2" for instance, and an `init A` command is
    executed, the scripts to start or stop processes within runlevel "A"
    are executed but the actual runlevel remains "2".

###   Configuring `/etc/inittab`

As mentioned before `init` reads the file /etc/inittab `/etc/inittab` to
determine what it should do. An entry in this file has the following
format:

id:runlevels:action:process

Included below is an example `/etc/inittab` file.

        # The default runlevel.
        id:2:initdefault:

        # Boot-time system configuration/initialization script.
        # This is run first except when booting in emergency (-b) mode.
        si::sysinit:/etc/init.d/rcS

        # What to do in single-user mode.
        ~~:S:wait:/sbin/sulogin

        # /etc/init.d executes the S and K scripts upon change
        # of runlevel.
        #
        # Runlevel 0 is halt.
        # Runlevel 1 is single-user.
        # Runlevels 2-5 are multi-user.
        # Runlevel 6 is reboot.

        l0:0:wait:/etc/init.d/rc 0
        l1:1:wait:/etc/init.d/rc 1
        l2:2:wait:/etc/init.d/rc 2
        l3:3:wait:/etc/init.d/rc 3
        l4:4:wait:/etc/init.d/rc 4
        l5:5:wait:/etc/init.d/rc 5
        l6:6:wait:/etc/init.d/rc 6
        # Normally not reached, but fall through in case of emergency.
        z6:6:respawn:/sbin/sulogin

        # /sbin/getty invocations for the runlevels.
        #
        # The "id" field MUST be the same as the last
        # characters of the device (after "tty").
        #
        # Format:
        #  <id>:<runlevels>:<action>:<process>
        1:2345:respawn:/sbin/getty 38400 tty1
        2:23:respawn:/sbin/getty 38400 tty2
                    

* id

    -   The id-field uniquely identifies an entry in the file `/etc/inittab`
    and can be 1-4 characters in length. For gettys and other login
    processes however, the id field should contain the suffix of the
    corresponding tty, otherwise the login accounting might not work.

- runlevels

    -   This field contains the runlevels for which the specified action
    should be taken.

* action

    - respawn

       The process will be restarted whenever it terminates, respawn
        (e.g. getty). getty

    - wait
 
      The process will be started once when the specified wait
        runlevel is entered and `init` will wait for its termination.

    - once

        - The process will be executed once when the specified once unlevel is entered.

    - boot

        - The process will be executed during system boot. The boot
        runlevels field is ignored.

   - bootwait

        - The process will be executed during system boot, while bootwait
        `init` waits for its termination (e.g. `/etc/rc)`. The runlevels
        field is ignored.

    - off

        - This does absolutely nothing.

    - ondemand

        - A process marked with an on demand runlevel will be ondemand
        executed whenever the specified ondemand runlevel is called.
        However, no runlevel change will occur (on demand runlevels are
        "a", "b", and "c").

    - initdefault

        -  An initdefault entry specifies the runlevel which should
        initdefault be entered after system boot. If none exists, init
        will ask for a runlevel on the console. The process field is
        ignored. In the example above, the system will go to runlevel 2
        after boot.

    - sysinit

        - The process will be executed during system boot. It will sysinit
        be executed before any boot or bootwait entries. The runlevels
        field is ignored.

    - powerwait

        - The process will be executed when the power goes down. powerwait
        `init` is usually informed about this by a process talking to a
        UPS connected to the computer. UPS `init` will wait for the
        process to finish before continuing.

    - powerfail

        - As for powerwait, except that `init` does powerfail not wait for
        the process' completion.

    - powerokwait

        - This process will be executed as soon as `init 
                                                powerokwait
                                                ` is informed that the
        power has been restored.

    - powerfailnow

        - This process will be executed when `init` powerfailnow is told
        that the battery of the external UPS is almost empty and the
        power is failing (provided that the external UPS and the
        monitoring process are able to detect this condition).

    - ctrlaltdel

        -   The process will be executed when `init` ctrlaltdel receives the
        SIGINT signal. This means that someone on the system console has
        pressed the CTRL-ALT-DEL key CTRL-ALT-DEL combination. Typically
        one wants to execute some sort of shutdown either to get into
        single-user level or to reboot the machine.

    - kbdrequest

        -  The process will be executed when init receives a signal from
        the keyboard handler that a special key combination kbdrequest
        was pressed on the console keyboard. Basically you want to map
        some keyboard combination to the "KeyboardSignal" action. For
        example, to map Alt-Uparrow for this purpose use the following
        in your keymaps file: `alt keycode 103 = KeyboardSignal`.

- process

    -   This field specifies the process that should be executed. If the
    process field starts with a "+", `init` will not do `utmp` and
    `wtmp` accounting. Some `getty`s insist on doing their own
    housekeeping.

####  The `/etc/init.d/rc` script

For each of the runlevels 0-6 there is an entry in `/etc/inittab` that
executes `/etc/init.d/rc ?` where "?" is 0-6, as you can see in
following line from /etc/init.d/rc the earlier example above:

        l2:2:wait:/etc/init.d/rc 2
                    

So, what actually happens is that `/etc/init.d/rc` is called with the
runlevel as a parameter.

The directory `/etc` contains several, runlevel specific, directories
which in their turn contain runlevel specific symbolic links to scripts
in `/etc/init.d/`. Those directories are:

        $ ls -d /etc/rc*
        /etc/rc.boot  /etc/rc1.d  /etc/rc3.d  /etc/rc5.d  /etc/rcS.d
        /etc/rc0.d    /etc/rc2.d  /etc/rc4.d  /etc/rc6.d
                    

As you can see, there also is a `/etc/rc.boot` /etc/rc.boot directory.
This directory is obsolete and has been replaced by the /etc/rcN.d
directory `/etc/rcS.d`. At boot time, the directory `/etc/rcS.d` is
scanned first and then, for backwards compatibility, the `/etc/rc.boot`.

The name of the symbolic link either starts with an "S" or with a "K".
Let's examine the `/etc/rc2.d` directory:

        $ ls /etc/rc2.d
        K20gpm       S11pcmcia   S20logoutd  S20ssh      S89cron
        S10ipchains  S12kerneld  S20lpd      S20xfs      S91apache
        S10sysklogd  S14ppp      S20makedev  S22ntpdate  S99gdm
        S11klogd     S20inetd    S20mysql    S89atd      S99rmnologin
                    

If the name of the symbolic link starts with a "K", the script is called
with "stop" as a parameter to stop the process. This is the case for
`K20gpm`, so the command becomes `K20gpm stop`. Let's find out what
program or script is called:

        $ ls -l /etc/rc2.d/K20gpm
        lrwxrwxrwx 1 root root 13 Mar 23 2001 /etc/rc2.d/K20gpm -> ../init.d/gpm
                    

So, `K20gpm stop` results in `/etc/init.d/gpm stop`. Let's see what
happens with the "stop" parameter by examining part of the script: init
scripts

        #!/bin/sh
        #
        # Start Mouse event server
        ...
        case "$1" in
        start)
           gpm_start
           ;;
        stop)
           gpm_stop
           ;;
        force-reload|restart)
           gpm_stop
           sleep 3
           gpm_start
           ;;
        *)
           echo "Usage: /etc/init.d/gpm {start|stop|restart|force-reload}"
           exit 1
        esac
                    

In the case..esac the first parameter, \$1, is examined and in case its
value is "stop", `gpm_stop` is executed.

On the other hand, if the name of the symbolic link starts with an "S",
the script is called with "start" as a parameter to start the process.

The scripts are executed in a lexical sort order of the filenames.
initorder of scripts

Let's say we have a daemon `SomeDaemon`, an accompanying script
`/etc/init.d/SDscript` and we want `SomeDaemon` to be running when the
system is in runlevel 2 but not when the system is in runlevel 3.

As you know by now this means we need a symbolic link, starting with an
"S", for runlevel 2 and a symbolic link, starting with a "K", for
runlevel 3. We've also determined that the daemon `SomeDaemon` is to be
started after `S19someotherdaemon`, which implicates S20 and K80 since
starting/stopping is symmetrical, i.e. that what is started first is
stopped last. This is accomplished with the following set of commands:

        # cd /etc/rc2.d
        # ln -s ../init.d/SDscript S20SomeDaemon
        # cd /etc/rc3.d
        # ln -s ../init.d/SDscript K80SomeDaemon
                    

Should you wish to manually start, restart or stop a process, it is good
practice to use the appropriate script in `/etc/init.d/`, e.g.
`/etc/init.d/gpm restart` to initiate the restart of the process.

`update-rc.d` {#scupdatercd}

###   update-rc.d

**Note**
This section only applies to Debian (based) distributions

Debian-derived Linux distributions use the `update-rc.d` command to
install and remove the init script links mentioned in the previous
section.

If you have a startup script called "foobar" in `/etc/init.d/` and want
to add it to the default runlevels, you can use:

        # update-rc.d foobar defaults
        Adding system startup for /etc/init.d/foobar ...
         /etc/rc0.d/K20foobar -> ../init.d/foobar
         /etc/rc1.d/K20foobar -> ../init.d/foobar
         /etc/rc6.d/K20foobar -> ../init.d/foobar
         /etc/rc2.d/S20foobar -> ../init.d/foobar
         /etc/rc3.d/S20foobar -> ../init.d/foobar
         /etc/rc4.d/S20foobar -> ../init.d/foobar
         /etc/rc5.d/S20foobar -> ../init.d/foobar
                

`update-rc.d` will create K (stop) links in rc0.d, rc1.d and rc6.d, and
S (start) links in rc2.d, rc3.d, rc4.d and rc5.d.

If you do not want an installed package to start automatically, use
`update-rc.d` to remove the startup links, for example to disable
starting `dovecot` on boot:

        # update-rc.d -f dovecot remove
        Removing any system startup links for /etc/init.d/dovecot ...
         /etc/rc2.d/S24dovecot
         /etc/rc3.d/S24dovecot
         /etc/rc4.d/S24dovecot
         /etc/rc5.d/S24dovecot
                

The `-f` (force) option is required if the rc script still exists. If
you install an updated `dovecot` package, the links will be restored. To
prevent this create "stop" links in the startup runlevel directories:

        # update-rc.d -f dovecot stop 24 2 3 4 5 .
        Adding system startup for /etc/init.d/dovecot ...
         /etc/rc2.d/K24dovecot -> ../init.d/dovecot
         /etc/rc3.d/K24dovecot -> ../init.d/dovecot
         /etc/rc4.d/K24dovecot -> ../init.d/dovecot
         /etc/rc5.d/K24dovecot -> ../init.d/dovecot
                

**Note**
Don't forget the trailing . (dot).


###   Using systemd targets

Instead of predefined runlevels, systemd uses targets to define the
system state. These targets are represented by target units. Target
units end with the `.target` file extensions and their only purpose is
to group together other systemd units through a chain of dependencies.
This also means that, in comparison to the init runlevels, multiple
targets can be active at the same time.

For example, the graphical.target unit, start services as the GNOME
Display Manager but also depends on multi-user.target (which is the
non-graphical system state) which in turn depends on basic.target.

Before we will continue with managing and using the targets you should
know which directories are used to store the default target files and
how you can override them.

As with all units the default target files are stored in
`/usr/lib/systemd`, the files in this directory are created by the
vendor of the software you've installed and these should never be
changed except by installation scripts. The directory where you can
store you custom targets and overrides is `/etc/systemd`, everything
written in this directory takes precendence over the files in
`/usr/lib/systemd`.

There are multiple ways to override or append properties to
unit files. You can create a completely new file with the same name, for
example ssh.server, in the `/etc/systemd/system`. This will override the
complete unit definition. If you only want to append or change some
properties you can create a new directory in `/etc/systemd/system` with
the name of the unit with `.d` appended, for example sshd.server.d. In
this directory you can create files with a `.conf` extension in which
you can place the properties you lik to append or override. Both of
these ways can also be done by using the `systemctl` command, this is
further described in chaper 206.3.

There is also a third location available in which you can place files to
override your unit definitions, this is the `/run/systemd` directory.
Definitions in this directory take precedence over the files in
`/usr/lib/systemd
            ` but not over those in `/etc/systemd`. Overrides in
`/run/systemd` will only be used until the system is rebooted since all
files in `/run/systemd` will be deleted at a reboot of the system.

systemd-delta To get an overview of all overrides active you can use the
`systemd-delta` command. This command can return the following types:

- masked

    -   Masked units, units that can't be started.

- equivalent

    -   Overridden files that do not differ in content.

- redirected

    -   Symbolic links to other unit files.

- overridden

    -   Overridden unit files.

- extended

    -   Extended unit files using a .conf file.

You can also filter by the types above using the `-t` of `--type=`
flags, these take a list of the above types. If you also want to see
unchanged files you can add `unchanged` as a type. Other options you can
use are `--diff=false` if you don't want `systemd-delta` to show the
diffs of overridden files, and `--no-pager` if you don't want the
output piped to a pager.

Now that we know where the unit files are stored and how we can override
them we can take a look at changing system states.

For getting and changing the (default) system state we use the
`systemctl` command. A full explanation of the possibilities for this
command can be found in chapter 206.3.

If we want to get the default target we can run the following command:

        $ systemctl get-default
            

This will output the current default target which is used at boot. To
get a list of all currently loaded target units you can run the
following commandL

        $ systemctl list-units --type=target
            

This will give you a list of all currently active targets. To get all
available target units you can run the following command:

        $ systemctl list-unit-files --type=target
            

If you want to change the default target you can use the
`systemctl set-default` command. For example, to set the default target
to multi-user.target you can run the following command:

        $ systemctl set-default multi-user.target
            

This command will create a symbolic link
`/etc/systemd/system/default.target` which links to the target file in
`/usr/lib/systemd/system`.

A comparison between the init runlevels and the system targets:

|  Runlevel |  Target |Description|
|-----|-----|-----|
|  0 |         runlevel0.target, poweroff.target  |   Shutdown and poweroff the system.|
|  1   |       runlevel1.target, rescue.target   |    Set up a rescue shell.|
 2    |      runlevel2.target, multi-user.target|   Set up a non-graphical multi-user system.
|3     |     runlevel3.target, multi-user.target |  Set up a non-graphical multi-user system.
|4      |    runlevel4.target, multi-user.target  | Set up a non-graphical multi-user system.
|5       |   runlevel5.target, graphical.target    |Set up a graphical multi-user system.
|6        |  runlevel6.target, reboot.target       |Shutdown and reboot the system.


You can also change the system state at runtime, this can be done using
the `systemctl isolate` command. This will stop all services not defined
for the chosen target, and start all the services that are defined for
the target.

For example, to go to rescue mode, you can run the following command:

        $ systemctl isolate rescue.target
            

This will stop all services except those defined for the rescue target.
Note that this command will not notify any logged in users of the
action.

There are also some shortcuts available to change the system state,
these have an added bonus that they will notify the logged in users of
the action. For example, another way to get the system into rescue mode
is the following:

        $ systemctl rescue
            

This will first notify the logged in users of the action and then stop
all services not defined in the target. If you don't want the users to
get notified you can add the `--no-wall` flag.

If your system is too broken to use rescue mode there is also an
emergency mode available. This can be started by using the following
command:

        $ systemctl emergency
            

If you want to start certain services at boot you have to enable them.
You can enable services using the `systemctl enable` command. For
example, to enable sshd you run the following command:

        $ systemctl enable sshd.service
            

To disable the service again you use `systemctl disable`. For example:

        $ systemctl disable sshd.service
            

The unit file of the service defines at which system state the service
will be running. This is configured by setting the `WantedBy=` option
under the `[Install]` section. If this is set to `multi-user.target`
than it will run in both non-graphical as graphical mode.

####  The LSB standard

The Linux Standard Base (LSB) defines an interface for application
programs that are compiled and packaged for LSB-conforming
implementations. Hence, a program which was compiled in an LSB
compatible environment will run on any distribution that supports the
LSB standard. LSB compatible programs can rely on the availability of
certain standard libraries. The standard also includes a list of
mandatory utilities and scripts which define an environment suitable for
installation of LSB-compatible binaries.

The specification includes processor architecture specific information.
This implies that the LSB is a *family* of specifications, rather than a
single one. In other words: if your LSB compatible binary was compiled
for an Intel based system, it will not run on, for example, an Alpha
based LSB compatible system, but will install and run on any Intel based
LSB compatible system. The LSB specifications therefore consist of a
common and an architecture-specific part; "LSB-generic" or "generic LSB"
and "LSB-arch" or "archLSB".

The LSB standard lists which generic libraries should be available, e.g.
`libdl`, `libcrypt`, `libpthread` and so on, and provides a list of
processor specific libraries, like `libc` and `libm`. The standard also
lists searchpaths for these libraries, their names and format (ELF).
Another section handles the way dynamic linking should be implemented.
For each standard library a list of functions is given, and data
definitions and accompanying header files are listed.

The LSB defines a list of 130+ commands that should be available on an
LSB compatible system, and their calling conventions and behaviour. Some
examples are `cp`, `tar`, `kill` and `gzip`, and the runtime languages
`perl` and `python`.

The expected behaviour of an LSB compatible system during system
initialization is part of the LSB specification. So is a definition of
the `cron` system, and are actions, functions and location of the `init`
scripts. Any LSB compliant init script should be able to handle the
following options: `start`, `stop`, `restart`, `force-reload` and
`status`. The `reload` and `try-restart` options are optional. The
standard also lists the definitions for runlevels and listings of user-
and groupnames and their corresponding UID's/GID's.

Though it is possible to install an LSB compatible program without the
use of a package manager (by applying a script that contains only LSB
compliant commands), the LSB specification contains a description for
software packages and their naming conventions.

**Note**
LSB employs the Red Hat Package Manager standard. Debian based LSB
compatible distributions may read RPM packages by using the `alien`
command.


The LSB standards frequently refers to other well known standards, for
example ISO/IEC 9945-2009 (Portable OS base, very Unix like). Any LSB
conforming implementation needs to provide the mandatory portions of the
file system hierarchy as specified in the [Filesystem Hierarchy Standard
(FHS)](http://www.pathname.com/fhs/), and a number of LSB specific
requirements. See also the section on [the FHS standard](#fhs).

####  The bootscript environment and commands

Initially, Linux contained only a limited set of services and had a very
simple boot environment. As Linux aged and the number of services in a
distribution grew, the number of initscripts grew accordingly. After a
while a set of standards emerged. Init scripts would routinely include
some other script, which contained functions to start, stop and verify a
process.

The LSB standard lists a number of functions that should be made
available for runlevel scripts. These functions should be listed in
files in the directory `/lib/lsb/init-functions` and need to implement
(at least) the following functions:

1.  `start_daemon` `[-f] [-n nicelevel] 
                            [-p pidfile]` `pathname` `[args...]`

    runs the specified program as a daemon. The `start_daemon` function
    will check whether the program is already running. If so, it will
    not start another copy of the daemon unless the `-f` option is
    given. The `-n` option specifies a nice level.

2.  `killproc` `[-ppidfile]` `pathname` `[signal]`

    will stop the specified program, trying to terminate it using the
    specified signal first. If that fails, the `SIGTERM` signal will be
    sent. If a program has been terminated, the `pidfile` should be
    removed if the terminated process has not already done so.

3.  `pidofproc` `[-p pidfile]` `pathname`

    returns one or more process identifiers for a particular daemon, as
    specified by the pathname. Multiple process identifiers are
    separated by a single space.

In some cases, these functions are provided as stand-alone commands and
the scripts simply assure that the path to these scripts is set
properly. Often some logging functions and function to display status
lines are also included.

####  Changing and configuring runlevels

Changing runlevels on a running machine requires comparison of the
services running in the current runlevel with those that need to be run
in the new runlevel. Subsequently, it is likely that some processes need
to be stopped and others need to be started.

Recall that the initscripts for a runlevel "X" are grouped in directory
`/etc/rc.d/rcX.d` (or, on newer (LSB based) systems, in
`/etc/init.d/rcX.d`). The filenames determine how the scripts are
called: if the name starts with a "K", the script will be run with the
`stop` option, if the name starts with a "S", the script will be run
with the `start` option. The normal procedure during a runlevel change
is to stop the superfluous processes first and then start the new ones.

The actual init scripts are located in `/etc/init.d`. The files you find
in the `rcX.d` directory are symbolic links which link to these. In many
cases, the start- and stop-scripts are symbolic links to the same
script. This implies that such init scripts should be able to handle at
least the `start` and `stop` options.

For example, the symbolic link named `S06syslog` in `/etc/init.d/rc3.d`
might point to the script `/etc/init.d/syslog`, as may the symbolic link
found in `/etc/init.d/rc2.d`, named `K17syslog`.

The order in which services are stopped or started can be of great
importance. Some services may be started simultaneously, others need to
start in a strict order. For example your network needs to be up before
you can start the `httpd`. The order is determined by the names of the
symbolic links. The naming conventions dictate that the names of init
scripts (the ones found in the `rcN.d` directories) include two digits,
just after the initial letter. They are executed in alphabetical order.

In the early days system administrators created these links by hand.
Later most Linux distributors decided to provide Linux commands/scripts
which allow the administrator to disable or enable certain scripts in
certain runlevels and to check which systems (commands) would be started
in which runlevel. These commands typically will manage both the
aforementioned links and will name these in such a way that the scripts
are run in the proper order.

####  The `chkconfig` command

Another tool to manage the proper linking of start up (init)
scripts is `chckconfig`. On some systems (e.g. SuSE/Novell) it serves as
a front-end for `insserv` and uses the LSB standardized comment block to
maintain its administration. On older systems it maintains its own
special comment section, that has a much simpler and less flexible
syntax. This older syntax consists of two lines, one of them is a
description of the service, it starts with the keyword `description:`.
The other line starts with the keyword `chkconfig:`, and lists the run
levels for which to start the service and the priority (which determines
in what order the scripts will be run while changing runlevels). For
example:

        # Init script for foo daemon
        #
        # description: food, the foo daemon
        # chkconfig: 2345 55 25
        #
        #
                    

This denotes that the `foo` daemon will start in runlevels 2, 3, 4 and
5, will have priority 55 in the queue of initscripts that are run during
startup and priority 25 in the queue of initscripts that are run if the
daemon needs to be stopped.

The `chkconfig` utility can be used to list which services will be
started in which runlevels, to add a service to or to delete it from a
runlevel and to add an entire service to or to delete it from the
startup scripts.

**Note**
We are providing some examples here, but be warned: there are various
versions of `chkconfig` around. Please read the manual pages for the
`chkconfig` command on your distribution first.


`chkconfig` does not automatically disable or enable a service
immediately, but simply changes the symbolic links. If the `cron` daemon
is running and you are on a Red Hat based system which is running in
runlevel 2, the command

        # chkconfig --levels 2345 crond off
                    

would change the administration but would not stop the `cron` daemon
immediately. Also note that on a Red Hat system it is possible to
specify more than one runlevel, as we did in our previous example. On
Novell/SuSE systems, you may use:

        # chkconfig food 2345
                    

and to change this so it only will run in runlevel 1 simply use

        # chkconfig food 1
                    

        # chkconfig --list
                    

will list the current status of services and the runlevels in which they
are active. For example, the following two lines may be part of the
output:

        xdm                       0:off   1:off   2:off   3:off   4:off   5:on    6:off
        xfs                       0:off   1:off   2:off   3:off   4:off   5:off   6:off
                    

They indicate that the xfs service is not started in any runlevel and
the xdm service only will be started while switching to runlevel 5.

To add a new service, let's say the `foo` daemon, we create a new init
script and name it after the service, in this case we might use `food`.
This script is consecutively put into the `/etc/init.d` directory, after
which we need to insert the proper header in that script (either the old
`chkconfig` header, or the newer LSB compliant header) and then run

        # chkconfig --add food
                    

To remove the `foo` service from all runlevels, you may type:

        # chkconfig --del food
                    

Note, that the `food` script will remain in the `/etc/init.d/`
directory.

