##  Make and install programs from source (206.1)

Candidates should be able to build and install an executable program
from source. This objective includes being able to unpack a file of
sources.

###   Key Knowledge Areas

- Unpack source code using common compression and archive utilities

- Understand basics of invoking make to compile programs

- Apply parameters to a configure script

- Know where sources are stored by default

###   Terms and Utilities

-   `/usr/src`

-   `gunzip`

-   `gzip`

-   `bzip2`

-   `xz`

-   `tar`

-   `configure`

-   `make`

-   `uname`

-   `install`

-   `patch`

###   Unpacking source code

Most Open Source software is distributed as compressed
tarballs containing source code and build scripts to compile and install
the software. Preferably the source is extracted and compiled in
`/usr/src/` but any location will do.

These tarballs are generally compressed using gzip, bzip2 or
xz. GNU tar supports these compression formats, and makes it easy to
decompress such files. For example, to unpack a gzip compressed tarball:

        $ tar zxvf /path/to/tarball.tar.gz
                

The `z` option tells tar to use the gzip algorithm, and the `x` option
tells tar to extract the file. To extract a bzip2 compressed file use
GNU tar's `j` option:

        $ tar jxvf /path/to/tarball.tar.bz2
                

To extract a xz compressed file use GNU tar's `J` option:

        $ tar Jxvf /path/to/tarball.tar.xz
                

Although GNU tar supports these compression alghorithms,
several other tar implementations don't. To extract compressed tarballs
on machines with such tar implementations, you first need to decompress
the file, and then extract the contents.

For a gzip compressed tarball:

        $ gunzip /path/to/tarball.tar.gz
                

For a bzip2 compressed tarball:

        $ bunzip2 /path/to/tarball.tar.bz2
                

xz For a xz compressed tarball:

        $ unxz /path/to/tarball.tar.xz
                

As an alternative, you can also use the '-d' (decompress) argument to
the `gzip`, `bzip2` and `xz` commands.

After decompression, you can extract the contents by calling tar without
giving a compression argument:

        $ tar xvf /path/to/tarball.tar
                

###   Building from source

Usually the build scripts are generated using GNU autoconf and
automake. automake is used to generate GNU Coding standard compliant
Makefile.in files. autoconf produces self-contained configure scripts
which can then be used to adapt, build and install the software on the
target system.

The usual way of building and installing software from source
looks something like this:

        $ tar zxvf sue-2.0.3.tar.gz
        $ cd sue-2.0.3
        $ ./configure
        $ make
        $ su
        # make install
                

The `./configure` command will check for both optional and mandatory
dependencies. It will also adapt the source code to the target system
(think system architecture, installed libraries, compiler flags, install
directories, \...). If an optional dependency is missing, it will
disable compilation to that dependency. In the case of missing required
dependencies, it will print the error and exit.

According to GNU standards, the commands above would install the "sue"
application under `/usr/local`. If you want to install the application
under some other directory structure, for example `/opt`, the configure
command would look like:

        $ ./configure --prefix=/opt
                

Try `./configure --help` to see all possible configure arguments.

The configure command also generates Makefiles which `make` uses to
compile and install the software. The `Makefile` usually contains
several "build targets" which you can call by giving them as an argument
to make. Often used targets include "all" which is usually the default
action, "clean" to clean up (remove) built object files from the source
tree, and "install" to install the software after the build stage.

It is possible to install the software in a location other than
the build directory. This is for useful if you want to build the
software on one machine, and install it on another:

        $ tar zxvf sue-2.0.3.tar.gz
        $ cd sue-2.0.3
        $ ./configure --prefix=/opt/sue
        $ make DESTDIR=/tmp/sue_tmp install
                

This technique is often used to build software on one machine, and
install it onto multiple others. In the above case, the `/tmp/sue_tmp`
directory would only contain files installed by sue-2.0.3.

If not cross-compiling for another platform, configure will use
`uname` to guess what machine it 's running on. Configure can usually
guess the canonical name for the type of system it's running on. To do
so it runs a script called `config.guess`, which infers the name using
the `uname` command or symbols predefined by the C preprocessor.

        $ cd /tmp/sue_tmp
        $ tar zcf ../sue_2.0.3_built.tgz opt/
                

The c option (as opposed to the previously mentioned x option) to tar
tells it to create a new archive.

If you copy the resulting tarball to the target machines in, let's say,
the `/tmp` directory, you can execute the following commands to install
the sue software into `/opt/sue`:

        # cd /
        # tar zxvf /tmp/sue_2.0.3_built.tgz
                

As alternative to using the make command you can use the install utility
to copy binaries to the required location. When you copy the files with
`install`, permissions and owner/group information will be set
correctly. If the destination file(s) already exists they will be
overwritten. But you can have `install` create a backup of these files
by using the `-b` argument or using the VERSION\_CONTROL enviroment
variable.

###   Patch

`patch` is a program that updates files. In short: apply a diff file on
a original file. `patch` takes a patchfile containing a difference
listing produced by the diff program and applies those differences to
one or more original files, producing patched versions. Normally the
patched versions are put in place of the originals. The names of the
files to be patched are usually taken from the patchfile, but if
there's just one file to be patched it can specified on the command
line as originalfile.

Here is an example of how `patch` works:

**To apply a patch.**

        $ patch -p1 < /path/to/path-x.y.z
                    

**To revert a patch.**

        $ patch -R -p1 < /path/to/patch-x.y.z
                    

**Note**
Patching is not part of the LPIC-2 objectives, but is included here
because it is used frequently when you build from source.
