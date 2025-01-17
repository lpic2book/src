# Kernel runtime management and troubleshooting (201.3)

Candidates should be able to manage and/or query a 2.6.x, 3.x or 4.x
kernel and its loadable modules. Candidates should be able to identify
and correct common boot and run time issues. Candidates should
understand device detection and management using udev. This objective
includes troubleshooting udev rules.

##  Key Knowledge Areas:

-   Use command-line utilities to get information about the currently
    running kernel and kernel modules.

-   Manually load and unload kernel modules.

-   Determine when modules can be unloaded.

-   Determine what parameters a module accepts.

-   Configure the system to load modules by names other than their file
    name.

-   /proc filesystem

-   Content of /, /boot , and /lib/modules

-   Tools and utilities to analyse information about the available
    hardware

-   udev rules

The following is a partial list of used files, terms, and utilities:

-   `/lib/modules/kernel-version/modules.dep`

-   module configuration files in `/etc`

-   `/proc/sys/kernel/`

-   `/sbin/depmod`

-   `/sbin/rmmod`

-   `/sbin/modinfo`

-   `/bin/dmesg`

-   `/sbin/lspci`

-   `/usr/bin/lsdev`

-   `/sbin/lsmod`

-   `/sbin/modprobe`

-   `/sbin/insmod`

-   `/bin/uname`

-   `/usr/bin/lsusb`

-   `/etc/sysctl.conf`, `/etc/sysctl.d/`

-   `/sbin/sysctl`

-   udevmonitor

-   `udevadm` monitor

-   `/etc/udev`

Customise, build and install a custom kernel and kernel modules {#UsingKernelModules}

kernel modules

In the paragraph [???](#WhatAreKernelModules) you have learned what
kernel modules are. There are various utilities and configuration files
associated with these modules. This paragraph will explain how you can
use these to manage a running kernel and it's modules.

##  Manipulating modules

For each kernel module loaded, display its name, size, use count and a
list of other referring modules. This command yields the same
information as is available in `/proc/modules`. On a particular laptop,
for instance, the command `/sbin/lsmod` reports:

        Module      Size   Used by
        serial_cb   1120   1
        tulip_cb    31968  2
        cb_enabler  2512   4 [serial_cb tulip_cb]
        ds          6384   2 [cb_enabler]
        i82365      22384  2
        pcmcia_core 50080  0 [cb_enabler ds i82365]
                

The format is name, size, use count, list of referring modules. If the
module controls its own unloading via a "can\_unload" routine, then the
user count displayed by lsmod is always -1, irrespective of the real use
count.


###   insmod

Insert a module into the running kernel. The module is located
automatically and inserted. You must be logged in as superuser to insert
modules. It is generally recommended to use `modprobe` instead, since
`insmod` only returns very general error codes and `modprobe` is more
specific about errors. Also, you will need to pass the complete filename
to `insmod
          `, whereas `modprobe` will work with just the module name.

-s

-   Write results to syslog instead of the terminal.

-v

-   Set verbose mode.

Suppose the kernel was compiled with modular support for a specific scsi
card. To verify that this specific module exists, in this case
`sym53c8xx.ko` exists, look for the file `sym53c8xx.ko` in the
`/lib/modules/kernel-version/kernel/drivers/scsi/` directory:


        # insmod sym53c8xx.ko
        # echo $?
        0
                

Modules can depend on other modules. In this example all the
prerequisite modules had been loaded before, so this specific module
loaded successfully. However, ` insmod` does not know about
prerequisites, it simply loads whatever you tell it to load. This may go
wrong if there are missing prerequisites:

        # insmod snd-ens1371.ko
        insmod: error inserting 'snd-ens1371.ko': -1 Unknown symbol in module
        # echo $?
        1
                

The message indicates that the module requires a function or variable
that is missing from the current kernel. This is usually caused by not
having the prerequisite module(s) loaded or compiled into the kernel.

###   rmmod

`device or resource busy`

Unless a module is in use or referred to by another module, the module
is removed from the running kernel. You must be logged in as the
superuser to remove modules.

        # rmmod snd_ac97_codec
        ERROR: Module snd_ac97_codec is in use by snd_ens1371
        # echo $?
        1
                

In this example the module could not be unloaded because it was in use,
in this case by the `snd_ens1371` module. The solution is to remove the
`snd_ens1371` module first:

        # rmmod snd_ens1371
        # rmmod snd_ac97_codec
        # echo $?
        0
              

Issue the command `lsmod` to verify that the modules have indeed been
removed from the running kernel.

###   modprobe

Like `insmod`, `modprobe` is used to insert modules. However, `modprobe`
has the ability to load single modules, modules and their prerequisites,
or all modules stored in a specific directory. The `modprobe` command
can also remove modules when combined with the `-r` option. It also is
more specific in it's error messages than `insmod`.

Modules can be inserted with optional `symbol=value` parameters such as
`irq=5` or `dma=3
          `. Such parameters can be specified on the command line or by
specifying them in the module configuration file, which will be
explained later. If the module is dependent upon other modules these
will be loaded first. The `modprobe` command determines prerequisite
relationships between modules by reading the file `modules.dep` at the
top of the module directory hierarchy, for instance
`/lib/modules/2.6.31/modules.dep`. You must be logged in as the
superuser to insert modules.

-a

-   Load all modules. When used with the -t tag, "all" is restricted to
    modules in the tag directory. This action probes hardware by
    successive module-insertion attempts for a single type of hardware,
    such as a network adapter. This may be necessary, for example, to
    probe for more than one kind of network interface.

-c

-   Display a complete module configuration, including defaults and
    directives found in `/etc/modules.conf` (or `/etc/conf.modules`,
    depending on your version of module utilities.) The `-c` option is
    not used with any other options.

-l

-   List modules. When used with the -t tag, list only modules in
    directory tag.

-r

-   Remove module, similar to `rmmod`. Multiple modules may be
    specified.

-s

-   Display results in `syslog` instead of on the terminal.

`-t tag`

-   Attempt to load multiple modules found in the directory `tag` until
    a module succeeds or all modules in tag are exhausted. This action
    probes hardware by successive module-insertion attempts for a single
    type of hardware, such as a network adapter.

`-v`

-   Set verbose mode.

Loading sound modules using `modprobe`.

        # modprobe snd_ens1371
        # echo $?
        0
        # lsmod
        Module                  Size  Used by
        snd_ens1371            20704  0
        snd_rawmidi            22448  1 snd_ens1371
        snd_seq_device          7436  1 snd_rawmidi
        snd_ac97_codec        112280  1 snd_ens1371
        ac97_bus                1992  1 snd_ac97_codec
        snd_pcm                72016  2 snd_ens1371,snd_ac97_codec
        snd_timer              21256  1 snd_pcm
        snd                    62392  6 snd_ens1371,snd_rawmidi,snd_seq_device,snd_ac97_codec,snd_pcm,snd_timer
        soundcore               7952  1 snd
        snd_page_alloc          9528  1 snd_pcm
                

All prerequisite modules for snd\_ens1371 have been loaded. To remove
both snd\_ac97\_codec and snd\_ens1371 modules, use
`modprobe -r snd_ac97_codec`.

Module configuration is handled in the file `/etc/modules.conf`. If this
file does not exist the `modprobe` utility will try to read the
`/etc/conf.modules` instead. The latter file is the historical name and
is deprecated. It should be replaced by `/etc/modules.conf`.

**Note**
On some systems this file is called `/etc/modprobe.conf` or there are
configuration files in a directory called `/etc/modprobe.d`.

More information on module configuration is given in the section on
[configuring modules](#confmods).

###   modinfo

Display information about a module from its `module-object-file`. Some
modules contain no information at all, some have a short one-line
description, others have a fairly descriptive message.

-a, \--author

-   Display the module's author.

-d, \--description

-   Display the module's description.

-n, \--filename

-   Display the module's filename.

`-fformat_string`, `--format 
              format_string`

-   Let's the user specify an arbitrary format string which can extract
    values from the ELF section in module\_file which contains the
    module information. Replacements consist of a percent sign followed
    by a tag name in curly braces. A tag name of %{filename} is always
    supported, even if the module has no modinfo section.

`-p`, `--parameters`

-   Display the typed parameters that a module may support.

`-h`, `--help`

-   Display a small usage screen.

`-V`, `--version`

-   Display the version of `modinfo`.

What information can be retrieved from the snd-ens1371 module:

        # modinfo snd_ens1371
        filename:       /lib/modules/2.6.31/kernel/sound/pci/snd-ens1371.ko
        description:    Ensoniq/Creative AudioPCI ES1371+
        license:        GPL
        author:         Jaroslav Kysela <perex@perex.cz>, Thomas Sailer <sailer@ife.ee.ethz.ch>
        alias:          pci:v00001102d00008938sv*sd*bc*sc*i*
        alias:          pci:v00001274d00005880sv*sd*bc*sc*i*
        alias:          pci:v00001274d00001371sv*sd*bc*sc*i*
        depends:        snd-pcm,snd,snd-rawmidi,snd-ac97-codec
        vermagic:       2.6.31-gentoo-r10 SMP mod_unload modversions
        parm:           index:Index value for Ensoniq AudioPCI soundcard. (array of int)
        parm:           id:ID string for Ensoniq AudioPCI soundcard. (array of charp)
        parm:           enable:Enable Ensoniq AudioPCI soundcard. (array of bool)
        parm:           spdif:S/PDIF output (-1 = none, 0 = auto, 1 = force). (array of int)
        parm:           lineio:Line In to Rear Out (0 = auto, 1 = force). (array of int)
                

##  Configuring modules

###   /etc/modules.conf

You may sometimes need to control assignments of the resources a module
uses, such as hardware interrupts or Direct Memory Access (DMA)
channels. Other situations may dictate special procedures to prepare
for, or to clean up after, module insertion or removal. This type of
special control of modules is configured in the file
`/etc/modules.conf`.

`keep`

-   kernel modules keep The keep directive, when found before any path
    directives, causes the default paths to be retained and added to any
    paths specified.

`depfile=`*full\_path*

-   kernel modules depfile= This directive overrides the default
    location for the modules dependency file, `modules.dep` which will
    be described in the next section.

`path=`*path*

-   kernel modules path= This directive specifies an additional
    directory to search for modules.

`options` *modulename module-specific-options*

-   kernel modules options Options for modules can be specified using
    the options configuration line in `modules.conf` or on the
    `modprobe` command line. The command line overrides configurations
    in the file. *modulename* is the name of a single module file
    without the `.ko` extension. *Module-specific options* are specified
    as *name=value* pairs, where the name is understood by the module
    and is reported using `modinfo -p`.

`alias` *aliasname* *result*

-   kernel modules alias Aliases can be used to associate a generic name
    with a specific module, for example:

            alias /dev/ppp ppp_generic
            alias char-major-108 ppp_generic
            alias tty-ldisc-3 ppp_async
            alias tty-ldisc-14 ppp_synctty
            alias ppp-compress-21 bsd_comp
            alias ppp-compress-24 ppp_deflate
            alias ppp-compress-26 ppp_deflate
                    

`pre-install` *module command*

-   kernel modules pre-install /etc/init.d/pcmcia This directive causes
    a specified shell command to be executed prior to the insertion of a
    module. For example, PCMCIA services need to be started prior to
    installing the `pcmcia_core` module:

            pre-install pcmcia_core /etc/init.d/pcmcia start
                    

`install` *module command*

-   kernel modules install This directive allows a specific shell
    command to override the default module-insertion command.

`post-install` *module command*

-   kernel modules post-install This directive causes a specified shell
    command to be executed after insertion of the module.

`pre-remove` *module command*

-   kernel modules pre-remove This directive causes a specified shell
    command to be executed prior to removal of module.

`remove` *module command*

-   kernel modules remove This directive allows a specific shell command
    to override the default module-removal command.

`post-remove` *module command*

-   kernel modules post-remove This directive causes a specified shell
    command to be executed after removal of module.

For more detailed information concerning the module-configuration file
see `man modules.conf`.

Blank lines and lines beginning with a `#` are ignored in
`modules.conf`.

###   Module Dependency File

The command `modprobe` can determine module dependencies and install
prerequisite modules automatically. To do this, `modprobe` scans the
first column of `/lib/modules/kernel-version/modules.dep` to find the
module it is to install. Lines in `modules.dep` are in the following
form:

        module_name.(k)o: dependency1 dependency2 ...
            

Find below an example for `thermal` and `processor` modules (which are
part of the ACPI layer):

        /lib/modules/2.6.31/kernel/drivers/acpi/thermal.ko: \
            /lib/modules/2.6.31/kernel/drivers/thermal/thermal_sys.ko
        /lib/modules/2.6.31/kernel/drivers/acpi/processor.ko: \
            /lib/modules/2.6.31/kernel/drivers/thermal/thermal_sys.ko
              

In this case both the `processor` and `thermal` module depend on the
`thermal_sys` module.

All of the modules that are available on the system should be listed in
the `modules.dep` file. They are listed with full path and filenames, so
including their .(k)o extension. Those that are not depending on other
modules are listed without dependencies. Dependencies that are listed
are inserted into the kernel by `modprobe` first, and after they have
been successfully inserted, the subject module itself can be loaded.

The `modules.dep` file must be kept current to ensure the correct
operation of `modprobe`. If module dependencies were to change without a
corresponding modification to `modules.dep`, then `modprobe` would fail
because a dependency would be missed. As a result, `modules.dep` needs
to be (re)created each time the system is booted. Most distributions
will do this by executing `depmod -a` automatically when the system is
booted.

###   depmod

The `depmod -a` procedure is also necessary after any change in module
dependencies.

The `/lib/modules/kernel-version/modules.dep` file contains a list of
module dependencies. It is generated by the `depmod` command, which
reads each module under `/lib/modules/kernel-version` to determine what
symbols the module needs and which ones it exports. By default the list
is written to the file `modules.dep`. The `modprobe` command in turn
uses this file to determine the order in which modules are to be loaded
into or unloaded from the kernel.

`kmod` versus `kerneld`

kmod kerneld Both `kmod` and `kerneld` provide for dynamic loading of
kernel-modules. A module is loaded when the kernel first needs it. For a
description on modules see [???](#sqkernelmodules).

`kerneld` is a daemon, `kmod` is a thread in the kernel itself. The
communication with `kerneld` is done through System V IPC. `kmod`
operates directly from the kernel and does not use System V IPC thereby
making it an optional module.

`kmod` replaces `kerneld` as of Linux kernel 2.2.x.

`kerneld` and `kmod` both facilitate dynamic loading of kernel modules.
Both use `modprobe` to manage dependencies and dynamic loading of
modules.

Manual loading of modules with `modprobe` or `insmod` is possible
without the need for `kmod` or `kerneld`. In both cases, the
kernel-option `CONFIG_MODULES` must be set to enable the usage of
modules.

CONFIG\_KMOD CONFIG\_MODULESTo enable the use of `kmod`, a kernel must
be compiled with the kernel-option `CONFIG_KMOD` enabled. Because `kmod`
is implemented as a kernel module the kernel-option `CONFIG_MODULES`
needs to be enabled too.

###   Building A Custom Kernel


A summary on how to configure and compile a kernel to meet custom needs
follows. You start with the configuration, normally using one of the
`make` targets for configuration (`make` `config`, `xconfig`,
`menuconfig`, `gconfig`, `oldconfig`), see the section on [creating a
.config file](#CreatingAConfigFile).

Once the kernel is configured it can be built with the command
`make zImage/bzImage`. To build the modules, use `make modules` followed
by `make modules_install`. To compile the kernel image and loadable
modules in one step you can use the command `make all`. After
configuring and compiling the kernel it can be installed with
`make install`. Installing the kernel means installing the following
files into the `/boot` directory:

-   `System.map-2.6.x `

-   `config-2.6.x `

-   `vmlinuz-2.6.x `

The `depmod` command builds a `modules.dep` file which is needed by
modprobe to determine the dependencies of the (newly) built modules.

Besides building and installing a kernel on a local machine, you can
also create packages that allow you to distribute your newly built
kernel to other machines. The common package formats are all available,
each has its own `make` parameter:

-   `make` `rpm-pkg`: builds both source and binary RPM packages.

-   `make` `binrpm-pkg`: builds (only) binary kernel RPM package.

-   `make` `deb-pkg`: builds the kernel package as a deb(ian) package.

###   /proc filesystem

troubleshooting/proc The `/proc` filesystem is a pseudo-filesystem,
meaning that its contents are directly presented by the kernel. It
contains directories and other files that reflect the state of the
running system. Some commands read the `/proc` filesystem to get
information about the state of the system. You can extract statistical
information, hardware information, network and host parameters and
memory and performance information. The `/proc` filesystem also allows
you to modify some parameters at runtime by writing values to files.

Contents of `/`, `/boot`, and `/lib/modules`

As an example the contents of these directories on a Debian system are
presented.

Contents of /:

        debian-601a:/$ ls -a
        .    boot  home        lib32       media  proc  selinux  tmp  .ure vmlinuz
        ..   dev   initrd.img  lib64       mnt    root  srv      u8   usr
        bin  etc   lib         lost+found  opt    sbin  sys      u9   var
            

The most important directories are `/bin` which contains the generic
systemwide commands, `/var` which is the top level directory for data
that will be constantly changing (logs etc.), `/srv` which contains data
related to services the system provides (e.g. a webserver), `/tmp` to
hold temporary files, `/mnt` where USB disks, tape-units and other
devices that contain a filesystem can be mounted temporarily, `/lib`,
`/lib32` and `/lib64` to hold modules and other libraries, `/boot` to
hold files used during boot, `/sbin` under which we find special
commands for the system administrator, `/opt` for third party packages,
and `/etc` that contains the configuration files for your system.

The `/usr` directory contains a shadow hierarchy that mimics parts of
the contents of the root directory. Hence, you will find a `/usr/bin`
directory, a `/usr/sbin` directory, a `/usr/lib` directory and a
`/usr/etc` directory. The 'secondary hierarchy' was meant to allow
users to override or enhance the system, for example by allowing them to
put local system administrator commands in `/usr/sbin`, and local system
configuration data in `/usr/etc`. A special case are `/usr/local` and
its subdirectories, which contain yet another shadow hierarchy that
mimics parts of the contents of the root directory, this time containing
very specific (local system) commands and configuration data. Hence, you
will find commands in `/bin`, `/usr/bin` and in `/usr/local/bin`: the
ones in `/bin` will be part of the distribution, the ones in `/usr/bin`
may be commands that are non-mandatory or added later by the system
administrator and finally the ones in `/usr/local/bin` are commands that
are specific to the local system.

**Note**
The `lost+found` directory is used by the filesystem itself.

- Contents of /boot:

        debian-601a:/boot$ ls -a
        .                      debian.bmp                 sarge.bmp
        ..                     debianlilo.bmp             sid.bmp
        coffee.bmp             grub           System.map-2.6.32-5-amd64
        config-2.6.32-5-amd64  initrd.img-2.6.32-5-amd64  vmlinuz-2.6.32-5-amd64
            

The most important are `vmlinuz`, `System.map`, `initrd.img` and
`config` file. The `grub` directory resides here too. Also some bitmap
images live here.

- Contents of `/lib/modules`:

        debian-601a:/lib/modules$ ls -a
        .  ..  2.6.32-5-amd64
            

        debian-601a:/lib/modules/2.6.32-5-amd64$ ls -a
        .      kernel             modules.dep      modules.order    modules.symbols.bin
        ..     modules.alias      modules.dep.bin  modules.softdep  source
        build  modules.alias.bin  modules.devname  modules.symbols  updates
            

See also the section on [the FHS standard](#fhs).

##  Tools and utilities to trace software and their system and library calls

###   strace - trace system calls and signals

        SYNOPSIS
            strace  [  -CdffhiqrtttTvxx  ] [ -acolumn ] [ -eexpr ] ...  [ -ofile ] [ -ppid ]
            ...  [ -sstrsize ] [ -uusername ] [ -Evar=val ] ...  [ -Evar ] ...  [ command  [
            arg ...  ] ]

            strace -c [ -eexpr ] ...  [ -Ooverhead ] [ -Ssortby ] [ command [ arg ...  ] ]
        

`strace` is a useful diagnostic,
instructional, and debugging tool. System administrators, diagnosticians
and trouble-shooters will find it invaluable for solving problems with
programs for which the source is not readily available since they do not
need to be recompiled in order to trace them. Students, hackers and the
overly-curious will find that a great deal can be learned about a system
and its system calls by tracing even ordinary programs. And programmers
will find that since system calls and signals are events that happen at
the user/kernel interface, a close examination of this boundary is very
useful for bug isolation, sanity checking and attempting to capture race
conditions.

In the simplest case `strace` runs the specified command until it exits.
It intercepts and records the system calls which are called by a process
and the signals which are received by a process. The name of each system
call, its arguments and its return value are printed on standard error
or to the file specified with the `-o` option.

By default `strace` reports the name of the system call, its arguments
and the return value on standard error.

Example:

        debian-601a:~$ strace cat /dev/null
        execve("/bin/cat", ["cat", "/dev/null"], [/* 34 vars */]) = 0
        brk(0)                                  = 0xc25000
        access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
        mmap(NULL, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fcac8fb4000
        access("/etc/ld.so.preload", R_OK)      = -1 ENOENT (No such file or directory)
        open("/etc/ld.so.cache", O_RDONLY)      = 3
        fstat(3, {st_mode=S_IFREG|0644, st_size=59695, ...}) = 0
        mmap(NULL, 59695, PROT_READ, MAP_PRIVATE, 3, 0) = 0x7fcac8fa5000
        close(3)                                = 0
        access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
        open("/lib/libc.so.6", O_RDONLY)        = 3
        read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0`\355\1\0\0\0\0\0"..., 832) = 832
        fstat(3, {st_mode=S_IFREG|0755, st_size=1432968, ...}) = 0
        mmap(NULL, 3541032, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7fcac8a38000
        mprotect(0x7fcac8b90000, 2093056, PROT_NONE) = 0
        mmap(0x7fcac8d8f000, 20480, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x157000) = 0x7fcac8d8f000
        mmap(0x7fcac8d94000, 18472, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7fcac8d94000
        close(3)                                = 0
        mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fcac8fa4000
        mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fcac8fa3000
        mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fcac8fa2000
        arch_prctl(ARCH_SET_FS, 0x7fcac8fa3700) = 0
        mprotect(0x7fcac8d8f000, 16384, PROT_READ) = 0
        mprotect(0x7fcac8fb6000, 4096, PROT_READ) = 0
        munmap(0x7fcac8fa5000, 59695)           = 0
        brk(0)                                  = 0xc25000
        brk(0xc46000)                           = 0xc46000
        open("/usr/lib/locale/locale-archive", O_RDONLY) = 3
        fstat(3, {st_mode=S_IFREG|0644, st_size=1527584, ...}) = 0
        mmap(NULL, 1527584, PROT_READ, MAP_PRIVATE, 3, 0) = 0x7fcac8e2d000
        close(3)                                = 0
        fstat(1, {st_mode=S_IFCHR|0620, st_rdev=makedev(136, 1), ...}) = 0
        open("/dev/null", O_RDONLY)             = 3
        fstat(3, {st_mode=S_IFCHR|0666, st_rdev=makedev(1, 3), ...}) = 0
        read(3, "", 32768)                      = 0
        close(3)                                = 0
        close(1)                                = 0
        close(2)                                = 0
        exit_group(0)                           = ?
        

Another very useful feature of `strace` is its ability to connect to a
running process using the `-p` flag. In combination with the `-f` flag
you can connect to say a running daemon that seems to malfunction and
gain insight in what it is actually doing.

###   strings

`strings` - print the strings of printable characters in files.
`strings` can be useful for reading non-text files.

        SYNOPSIS
            strings [-afovV] [-min-len]
                   [-n min-len] [--bytes=min-len]
                   [-t radix] [--radix=radix]
                   [-e encoding] [--encoding=encoding]
                   [-] [--all] [--print-file-name]
                   [-T bfdname] [--target=bfdname]
                   [--help] [--version] file...
        

For each file given, GNU `strings` prints the printable character
sequences that are at least 4 characters long (or the number given with
the options below) and are followed by an unprintable character. By
default, it only prints the strings from the initialized and loaded
sections of object files; for other types of files, it prints the
strings from the whole file. troubleshootingstrings

`strings` is mainly useful for determining the contents of non-text
files, such as executables. Often used to check for names of environment
variables and configurations files used by an executable.

###   ltrace

`ltrace` - a library call tracer

        SYNOPSIS
            ltrace  [-CfhiLrStttV]  [-a  column] [-A maxelts] [-D level] [-e expr] [-l file-
            name] [-n nr] [-o filename] [-p pid] ... [-s strsize] [-u username] [-X  extern]
            [-x   extern]   ...   [--align=column]   [--debug=level]  [--demangle]  [--help]
            [--indent=nr] [--library=filename] [--output=filename] [--version] [command [arg
            ...]]


Similar to the `strace`, that intercepts and
records system calls, `ltrace` intercepts and records the dynamic
library calls which are called by the executed process and the signals
which are received by that process. The program to be traced need not be
recompiled for this, so you can use it on binaries for which you don't
have the source handy. By default, `ltrace` will start the program you
specify on the command line and traces it until the program exits.

Example:

        debian-601a:~$ ltrace cat /dev/null
        __libc_start_main(0x401ad0, 2, 0x7fff5f357f38, 0x409110, 0x409100 <unfinished ...>
        getpagesize()                                                     = 4096
        strrchr("cat", '/')                                               = NULL
        setlocale(6, "")                                                  = "en_US.utf8"
        bindtextdomain("coreutils", "/usr/share/locale")                  = "/usr/share/locale"
        textdomain("coreutils")                                           = "coreutils"
        __cxa_atexit(0x4043d0, 0, 0, 0x736c6974756572, 0x7f4069c04ea8)    = 0
        getenv("POSIXLY_CORRECT")                                         = NULL
        __fxstat(1, 1, 0x7fff5f357d80)                                    = 0
        open("/dev/null", 0, 02)                                          = 3
        __fxstat(1, 3, 0x7fff5f357d80)                                    = 0
        malloc(36863)                                                     = 0x014c4030
        read(3, "", 32768)                                                = 0
        free(0x014c4030)                                                  = <void>
        close(3)                                                          = 0
        exit(0 <unfinished ...>
        __fpending(0x7f4069c03780, 0, 0x7f4069c04330, 0x7f4069c04330, 0x7f4069c04e40) = 0
        fclose(0x7f4069c03780)                                            = 0
        __fpending(0x7f4069c03860, 0, 0x7f4069c04df0, 0, 0x7f4069e13700)  = 0
        fclose(0x7f4069c03860)                                            = 0
        +++ exited (status 0) +++
        

##  The boot process

When using an `initrd`, the system goes through the following steps:

1.  The boot loader loads the kernel and the initial RAM disk.

2.  The kernel converts `initrd` into a "normal" RAM disk and frees the
    memory used by the `initrd` image.

3.  The `initrd` image is mounted read-write as root

4.  The `linuxrc` is executed (this can be any valid executable,
    including shell scripts; it is run with uid 0 and can do everything
    `init` can do)

5.  After `linuxrc` terminates, the "real" root filesystem is mounted

6.  If a directory `/initrd` exists, the `initrd` image is moved there,
    otherwise, `initrd` image is unmounted

7.  The usual boot sequence (e.g. invocation of the `/sbin/init`) is
    performed on the root filesystem

As moving the `initrd` from `/` to `/initrd` does not require to unmount
it, process(es) that use files on the RAMdisk may kept running. All
filesystems that were mounted will remain mounted during the move.
However, if `/initrd` does not exist the move is not made and in that
case any running processes that use files from the `initrd` image will
prevent it from becoming unmounted. It will remain in memory until
forced out of existence by the continuation of the bootprocess.

###   /proc/mounts

Also, even when the move can be made and so filesystems mounted under
`initrd` remain accessible, the entries in `/proc/mounts` will not be
updated. Also keep in mind that if the directory `/initrd` does not
exist it is impossible to unmount the RAM disk image. The image will be
forced out of existence during the rest of the bootprocess, so any
filesystems mounted within it will also disappear and can not be
remounted. Therefore, it is strongly recommendated to unmount all
filesystems before switching from the `initrd` filesystem to the normal
root filesystem, including the `/proc` filesystem.

The memory used for the `initrd` image can be reclaimed. To do this, the
command `freeramdisk` must be used directly after unmounting `/initrd`.

###   boot option

initrd=

Including `initrd` support to the kernel adds options to the boot
command line:

`initrd=`

-   This option loads the file that is specified as the initial RAM
    disk.

`noinitrd`

-   This option causes the `initrd` data to be preserved, but it is not
    converted to a RAM disk and the normal root filesystem is mounted
    instead. The `initrd` data can be read from `/dev/initrd`. If read
    through `/dev/initrd`, the data can have any structure so it need
    not necessarily be a filesystem image. This option is used mainly
    for debugging purposes.

    **Note**
    The `/dev/initrd` is read-only and can be used only once. As soon as
    the last process has closed it, all memory is freed and
    `/dev/initrd` can no longer be accessed.
    :::

`root=/dev/ram`

-   The `initrd` is mounted as root and subsequently `/linuxrc` is
    started. If there is no `/linuxrc` the normal boot procedure will be
    followed. Without using this parameter, the `initrd` would be moved
    or unloaded, however in this case, the root filesystem will continue
    to be the RAM disk. The advantage of this is that it allows the use
    of a compressed filesystem and it is slightly faster.

##  Hardware and Kernel Information

###   uname

`uname` prints system information such as machine type, network
hostname, OS release, OS name, OS version and processor type of the
host. The parameters are: uname

`-a`; `--all`

-   uname -a uname \--all print all information, in the order below,
    except omit -p and -i if these are unknown.

`-s`; `--kernel-name`

-   uname-s uname\--kernel-name prints the kernel name

`-n`; `--nodename`

-   uname-n uname\--nodename prints the network node hostname

`-r`; `--kernel-release`

-   uname-r uname\--kernel-release prints the kernel release

`-v`; `--kernel-version`

-   uname-v uname\--kernel-version prints the kernel build version, date
    and time

`-m`; `--machine`

-   uname-m uname\--machine prints the machine hardware architecture
    name

`-p`; `--processor`

-   uname-p uname\--processor prints the name of the processor type

`-i`; `--hardware-platform`

-   uname-i uname\--hardware-platform prints the name of hardware
    platform

`-o`; `--operating-system`

-   uname-o uname\--operating-system prints the name of the operating
    system

Example:

        debian-601a:~$ uname -a
        Linux debian-601a 2.6.32-5-amd64 #1 SMP Mon Mar 7 21:35:22 UTC 2011 x86_64 GNU/Linux
        

###   /proc/stys/kernel

`/proc/sys/kernel/` is a directory in the `/proc`
pseudo filesystem. It contains files that allow you to tune and monitor
the Linux kernel. Be careful, as modification of some of the files may
lead to a hanging or dysfunctional system. As these parameters are
highly dependant on the kernel verions, it is advisable to read both
documentation and source before actually making adjustments. See also
[the section on the `/proc` filesystem](#procfs).

Some files are quite harmless and can safely be used to obtain
information, for instance to show the version of the running kernel:

     
        debian-601a:~$ cat /proc/sys/kernel/osrelease

Some files can be used to *set* information in the kernel. For
instance, the following will tell the kernel not to loop on a panic, but
to auto-reboot after 20 seconds:

        debian-601a:~$ echo 20 > /proc/sys/kernel/panic

###   lspci

With `lspci` you can display information about all the PCI buses
in the system and all the devices that are connected to them. Keep in
mind that you need to have Linux kernel 2.1.82 or newer. With older
kernels direct hardware access is only available to root. To make the
output of `lspci` more verbose, one or more `-v` paramaters (up to 3)
can be added. Access to some parts of the PCI configuraion space is
restricted to root on many operating systems. So `lspci` features
available to normal users are limited.

Example of `lspci` output on a system running Debian in Virtualbox:

        debian-601a:~$ lspci
        00:00.0 Host bridge: Intel Corporation 440FX - 82441FX PMC [Natoma] (rev 02)
        00:01.0 ISA bridge: Intel Corporation 82371SB PIIX3 ISA [Natoma/Triton II]
        00:01.1 IDE interface: Intel Corporation 82371AB/EB/MB PIIX4 IDE (rev 01)
        00:02.0 VGA compatible controller: InnoTek Systemberatung GmbH VirtualBox Graphics Adapter
        00:03.0 Ethernet controller: Intel Corporation 82540EM Gigabit Ethernet Controller (rev 02)
        00:04.0 System peripheral: InnoTek Systemberatung GmbH VirtualBox Guest Service
        00:05.0 Multimedia audio controller: Intel Corporation 82801AA AC'97 Audio Controller (rev 01)
        00:06.0 USB Controller: Apple Computer Inc. KeyLargo/Intrepid USB
        00:07.0 Bridge: Intel Corporation 82371AB/EB/MB PIIX4 ACPI (rev 08)
        00:0d.0 SATA controller: Intel Corporation 82801HBM/HEM (ICH8M/ICH8M-E) SATA AHCI Controller (rev 02)

###   lsusb

lsusb `lsusb` is similiar to `lspci`, but checks the USB buses and
devices. To make use of `lsusb` a Linux kernel which supports the
`/proc/bus/usb` inferface is needed (Linux 2.3.15 or newer). `lsusb -v`
will provide verbose information.

Example of `lsusb` output as generated on a laptop running Ubuntu:

        ubuntu:/var/log$ lsusb
        Bus 007 Device 003: ID 03f0:0324 Hewlett-Packard SK-2885 keyboard
        Bus 007 Device 002: ID 045e:0040 Microsoft Corp. Wheel Mouse Optical
        Bus 007 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub
        Bus 006 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub
        Bus 005 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub
        Bus 004 Device 002: ID 147e:2016 Upek Biometric Touchchip/Touchstrip Fingerprint Sensor
        Bus 004 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub
        Bus 003 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub
        Bus 002 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
        Bus 001 Device 002: ID 04f2:b018 Chicony Electronics Co., Ltd 2M UVC Webcam
        Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
        

###   lsdev

lsdev `lsdev` displays information about installed hardware. It gathers
information from interupts, DMA files, and interrupts from the `/proc`
directory. `lsdev` gives a quick overview about which device is using
what I/O address and IRQ/DMA channels. Files being used:

    /proc/interrupts

    /proc/ioports

    /proc/dma

Example of `lsdev` output on a Debian based system:

        debian-601a:/var/log$ lsdev
        Device            DMA   IRQ  I/O Ports
        ------------------------------------------------
        0000:00:01.1                 0170-0177 01f0-01f7 0376-0376 03f6-03f6 d000-d00f
        0000:00:03.0                 d010-d017
        0000:00:04.0                 d020-d03f
        0000:00:05.0                 d100-d1ff d200-d23f
        0000:00:0d.0                 d240-d247 d250-d257 d260-d26f
        82801AA-ICH               5
        ACPI                         4000-4003 4004-4005 4008-400b 4020-4021
        ahci                           d240-d247   d250-d257   d260-d26f
        ata_piix              14 15    0170-0177   01f0-01f7   0376-0376   03f6-03f6   d000-d00f
        cascade             4     2
        dma                          0080-008f
        dma1                         0000-001f
        dma2                         00c0-00df
        e1000                          d010-d017
        eth1                     10
        fpu                          00f0-00ff
        i8042                  1 12
        Intel                          d100-d1ff   d200-d23f
        keyboard                     0060-0060 0064-0064
        ohci_hcd:usb1            11
        PCI                          0cf8-0cff
        pic1                         0020-0021
        pic2                         00a0-00a1
        rtc0                      8    0070-0071
        rtc_cmos                     0070-0071
        timer                     0
        timer0                       0040-0043
        timer1                       0050-0053
        vboxguest                 9
        vga+                         03c0-03df
**Note**

On some systems `lsdev` is missing, use `procinfo` instead.

###   sysctl

sysctl sysctl is used to modify kernel paramaters at runtime. The
parameters available are those listed under `/proc/sys/`. The
configuration file can usually be found in `/etc/sysctl.conf`. It is
important to know that modules loaded after `sysctl` is used may
override its settings. You can prevent this by running `sysctl` only
after all modules are loaded.

##  Kernel Runtime Management

With the `dmesg` command you can write kernel messages to standard
output. Or write them to a file using `dmesg > /var/log/boot.messages`.
This can be helpful when it comes to troubleshooting issues with your
system or when you just want to get some information about the hardware
in your system. The output of `dmesg` can usually be found in
`/var/log/dmesg`. Use `dmesg` in combination with `grep` to find
specific information.

###   udev

Candidates should understand device detection and management using
`udev`. This objective includes troubleshooting udev rules

Key Knowledge Areas:

-   udev rules

-   Kernel interfaces

`udev` was designed to make Linux device handling more flexible and safe
by taking device handling out of system space into userspace.

`udev` consists of a userspace daemon (`udevd`) which receives
"uevents" from the kernel. Communication between the userspace daemon
and the kernel is done through the `sysfs` pseudo filesystem. The kernel
sends the aforementioned "uevents" when it detects addition or removal
of hardware, for example when you plug in your camera or USB disk. Based
on a set of rules to match these uevents the kernel provides a dynamic
device directory containing only device files for devices that are
actually present, and can fire up scripts etc. to perform various
actions. Hence, it is possible, for example, to plug in a camera, which
will be automatically detected and properly mounted in the right place.
After that a script might be started that copies all files to the local
disk into a properly named subdirectory that will be created using the
proper rights.

`/etc/udev/`

The `/etc/udev/` directory contains the configuration and the rule files
for the udev utility. The `udev.conf` is the main configuration file for
udev. Here, for instance, the logging priority can be changed.

`udev rules`

`udev` rules are read from files located in the default rules directory.
`/lib/udev/rules.d/`. Custom rules to override these default rules are
specified in the `/etc/udev/rules.d/` directory.

When devices are initialized or removed, the kernel sends an 'uevent'.
These uevents contain information such as the subsystem (e.g. net, sub),
action and attributes (e.g. mac, vendor). `udev` listens to these
events, matches the uevent information to the specified rules, and
responds accordingly.

A `udev` rule consists of multiple key value pairs separated by a comma.
Each key value pair represents either a match key, that matches to
information provided with the uevent or an assign key, which assign
values, names and actions to the device nodes maintained by `udev`:

        SUBSYSTEM=="net", ACTION=="ADD", DRIVERS="?*", ATTR{address}=="00:21:86:9e:c2:c4", 
        ATTR{type}=="1", KERNEL="eth*", NAME=="eth0"
        

The rule specified above would add a device `/dev/eth0` for a network
card with MAC address 00:21:86:9e:c2:c4

As shown, a key value pair also specifies an operator. Depending on the
used operator, different actions are taken. Valid operators are: ==,
Compare for equality, !=, Compare for inequality, =, Assign a value to a
key. Keys that represent a list, are reset and only this single value is
assigned, +=, Add the value to a key finally; disallow any later
changes, which may be used to prevent changes by any later rules

When specifying rules, be careful not to create conflicting rules (e.g.
do not point two different netword cards to the same device name). Also,
changing device names into something else could cause userpsace software
incompatibilities. You have power, use it wisely.

`udevmonitor`

`udevmonitor` will print `udev` and kernel uevents
to standard output. You can use it to analyze event timing by comparing
the timestamps of the kernel uevent and the `udev` event. Usually
`udevmonitor` is a symbolic link to `udevadm`. In some distributions,
this symbolic link no longer exists. To access the monitor on these
systems, use the command `udevadm monitor`.
