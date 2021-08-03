## Kernel Components (201.1)


Candidates should be able to utilise kernel components that are
necessary to specific hardware, hardware drivers, system resources and
requirements. This objective includes implementing different types of
kernel images, identifying stable and development kernels and patches,
as well as using kernel modules.

###  Key knowledge Areas:

-   Kernel 2.6.x documentation

-   Kernel 3.x documentation

-   Kernel 4.x documentation

###  Terms and Utilities

-   `/usr/src/linux`

-   `/usr/src/linux/Documentation`

-   `zImage`

-   `bzImage`

-   `xz compression`


##  Different types of kernel images 

The Linux kernel was originally designed to be a monolithic kernel.
Monolithic kernels contain all drivers for all the various types of
supported hardware, regardless if your system uses that hardware. As the
list of supported hardware grew the amount of code that was never used
on any given system grew too. Therefore a system was introduced that
allowed the kernel to load some hardware drivers dynamically. These
loadable device drivers were named \"kernel modules\".

Though the Linux kernel can load and unload modules it does not qualify
as a microkernel. Microkernels are designed such that only the least
possible amount of code is run in supervisor mode NDASH this was never a
design goal for Linux kernels. The Linux kernel is best described as a
hybrid kernel: it is capable of loading and unloading code as
microkernels do, but runs almost exclusively in supervisor mode, as
monolithic kernels do.

It is still possible to build the Linux kernel as a monolithic kernel.
But it is rarely done, as updating device drivers requires a complete
recompile of the kernel. However, building a monolithic kernel has its
advantages too: it may have a smaller footprint as you can download and
build just the parts you need and dependencies are clearer.

When stored on disk most kernel images are compressed to save space.
There are two types of compressed kerneltypes: `zImage` and `bzImage`.

`zImage` and `bzImage` files have different layouts and loading
algorithms. The maximum allowed kernelsize for a `zImage` is 512Kb,
where a `bzImage` does not pose this limit. As a result the `bzImage`
kernel is the preferred image type for larger kernels. `zImage` will be
loaded in low memory and `bzImage` can also be loaded in high memory if
needed.

**Note**
Both `zImage` and `bzImage` use gzip compression. The "bz" in `bzImage`
refers to "*big zImage*" NDASH not to the "bzip" compression algorithm.

##  Overview of numbering schemes for kernels and patches 

The numbering schemes in use for Linux kernels has changed several times
over the years: the original scheme, valid for all kernels up to version
2.6.0, the scheme for kernels version 2.6.0 up to 3.0, the previous
scheme, for kernels 3.0 and later, and the current scheme starting with
version 4.0. In the next sections we discuss each of them.

###   Scheme up to 2.6.0 kernels

Initially, a kernel version number consisted of three parts: major
release number, minor release number and the patch level, all separated
by periods.

The major release was incremented when a major change was made to the
kernel.

The minor release was incremented when significant changes and additions
were made. Even-numbered minor releases, e.g. 2.2, 2.4, were considered
stable releases and odd-numbered releases, e.g. 2.1, 2.3, 2.5 were
considered to be development releases. They were primarily used by
kernel developers and people that preferred bleeding edge functionality
at the risk of instability.

The last part of the kernel version number indicated the patch level. As
errors in the code were corrected (and/or features were added) the patch
level was incremented. A kernel should only be upgraded to a higher
patch level when the current kernel has a functional or security
problem.

###   Kernel Versioning since kernel version 2.6.0 and up to 3.0 

In 2004, after the release of 2.6.0, the versioning system was changed,
and it was decided that a time-based release cycle would be adopted. For
the next seven years the kernel remained at 2.6 and the third number was
increased with each new release (which happend every two or three
months). A fourth number was added to account for bug and security
fixes. An example of this scheme is kernel `2.6.32.71`. The even-odd
numbering system was no longer used.

###   Kernel Versioning from version 3.0 to 4.0 

On 29 May 2011, Linus Torvalds announced the release of kernel version
3.0.0 in honour of the 20th anniversary of Linux. This changed the
numbering scheme yet again. It would still be a time-based release
system but the second number would indicate the release number, and the
third number would be the patch number. For test releases the -rc
designation is used. Following this scheme, `3.2.84` would refer to a
stable kernel release. `3.2-rc4` on the other hand would point to the
fourth release candidate of the `3.2` kernel.

###   Kernel Versioning from 4.0 

In April 2015 kernel version 4.0.0 was released. The versioning system
didn't change this time. At the time of this writing, kernel version
`4.9.2` is the latest stable version available through
<https://kernel.org>. The 4.x kernel did however introduce a couple of
new features. The possibility to perform "Live Patching" being one of
the more noteworthy ones. Live patching offers the possibility to
install kernel patches without the need to reboot the system. This can
be accomplished by unloading and loading appropriate kernel modules.
Every time a new Linux kernel version gets released, it is accompanied
by a `changelog`. These changelog files hold detailed information about
what has changed in this release compared to previous versions.

###   XZ Compression

Every Linux distribution comes with a kernel that has been configured
and compiled by the distribution developers. Most Linux distributions
also offer possibilities to upgrade the kernel binary through some sort
of package system. It is however also possible to compile a kernel for
your system using kernel sources from the previously mentioned website
[kernel.org](https://kernel.org). These kernel sources are packed using
tar and compressed using the *XZ* compression method. XZ is the
successor to LZMA and LZMA2. Recent Linux kernels offer built-in support
for XZ. Depending on the Linux distribution in use, it might be
necessary to install a `xz-utils` or equivalent package to uncompress xz
compressed files. After having downloaded the kernel sources for one of
the available kernels as a `tar.xz` archive, these source files may be
unpacked using the following command line:

        $ tar xvf linux-4.10-rc3.tar.xz
                

**Note**
GNU `tar` needs to be at least version 1.22 for the above command to
work.

##  What are kernel modules 

Linux kernel modules are object files (`.ko` files) produced by the C
compiler but not linked into a complete executable. Kernel modules can
be loaded into the kernel to add functionality when needed. Most modules
are distributed with the kernel and compiled along with it. Every kernel
version has its own set of modules.


Modules are stored in a directory hierarchy under
`/lib/modules/`*kernel-version*, where *kernel-version* is the string
reported by `uname -r` or found in `/proc/sys/kernel/osrelease`, such as
2.6.5-15smp. Multiple module hierarchies are available under
`/lib/modules` in case multiple kernels are installed.

Subdirectories that contain modules of a particular type exist under the
`/lib/modules/` *kernel-version* directory. This grouping is convenient
for administrators, but also enables important functionality within the
`modprobe` command.

###   Typical mudule types 

- block

	-   Modules for a few block-specific devices such as RAID controllers or
    IDE tape drives.

- cdrom

	-   Device driver modules for nonstandard CD-ROM drives.

- fs

	-   Drivers for filesystems such as MS-DOS (the msdos.ko module).

- ipv4

	-   Includes modular kernel features having to do with IP processing,
    such as IP masquerading.

- misc

	-   Anything that does not fit into one of the other subdirectories ends
    up here. Note that no modules are stored at the top of this tree.

- net

	-   Network interface driver modules.

- scsi

	-   Contains driver modules for the SCSI controller.

- video

	-   Special driver modules for video adapters.

Module directories are also referred to as tags within the context of
module manipulation commands.
