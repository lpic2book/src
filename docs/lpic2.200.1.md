##  Measure and Troubleshoot Resource Usage


###   Objectives


Candidates should be able to measure hardware resource and network
bandwidth, identify and troubleshoot resource problems.

##  Key Knowledge Areas:

-   Measure CPU usage

-   Measure memory usage

-   Measure disk I/O

-   Measure network I/O

-   Measure firewalling and routing throughput

-   Map client bandwith usage

-   Match / correlate system symptoms with likely problems

-   Estimate throughput and identify bottlenecks in a system including
    networking

###     Terms and utilities:


-   `iostat`

-   `iotop`

-   `vmstat`

-   `netstat`

-   `ss`

-   `iptraf`

-   `pstree, ps`

-   `w`

-   `lsof`

-   `top`

-   `htop`

-   `uptime`

-   `sar`

-   swap

-   processes blocked on I/O

-   blocks in

-   blocks out

-   network

##  iostat


**Note**
Depending on the version of your Linux distribution it may
be necessary to install a package like Debian `sysstat` to access tools
like `iostat`, `sar`, `mpstat`, etc. The Debian `procps` package contains
utilities like `free`, `uptime`, `vmstat`, `w`, `sysctl`, etc.

The `iostat` command is used for monitoring system input/output
(I/O) device load. This is done by observing the *time* the
devices are active in relation to their *average* transfer
rates. Without any options, the `iostat` command displays
statistics since the last system reboot. When interval and count
arguments are passed to `iostat`, statistics for each specified time
interval are added to the output. The `-y` option can also be
used to suppress statistics since the last reboot.

Usage:

        $ iostat options interval count


Examples:

        $ iostat
        Linux 3.2.0-4-686-pae (debian)  05/07/2013  _i686_  (2 CPU)

        avg-cpu:  %user   %nice %system %iowait  %steal   %idle
        1.25    0.32    3.76    0.20    0.00   94.46

        Device:            tps    kB_read/s    kB_wrtn/s    kB_read    kB_wrtn
        sda              12.21       214.81        17.38     333479      26980

        $ iostat 1 3
        Linux 3.2.0-4-686-pae (debian)  05/07/2013  _i686_  (2 CPU)

        avg-cpu:  %user   %nice %system %iowait  %steal   %idle
        24.24    1.51    7.49    4.97    0.00   61.79

        Device:            tps   Blk_read/s   Blk_wrtn/s   Blk_read   Blk_wrtn
        sda              14.06       249.94       121.22    1337998     648912

        avg-cpu:  %user   %nice %system %iowait  %steal   %idle
        13.13    0.00    6.21    0.60    0.00   80.06

        Device:            tps   Blk_read/s   Blk_wrtn/s   Blk_read   Blk_wrtn
        sda               2.51         4.01        28.86         40        288

        avg-cpu:  %user   %nice %system %iowait  %steal   %idle
        11.11    0.00    5.71    0.00    0.00   83.18

        Device:            tps   Blk_read/s   Blk_wrtn/s   Blk_read   Blk_wrtn
        sda               0.30         0.00         3.20          0         32

        $ iostat -c
        Linux 3.2.0-4-686-pae (debian)  05/07/2013  _i686_  (2 CPU)

        avg-cpu:  %user   %nice %system %iowait  %steal   %idle
        9.16    0.05   17.01    1.37    0.00   72.42


##  iotop


The `iotop` command is similar to the `top` command. It shows I/O
usage information output by the Linux kernel and displays a table of
current I/O usage by processes or threads on the system.

`iotop` displays columns for the I/O bandwidth read and written by each
process/thread during the sampling period. It also displays the
percentage of time the thread/process spent while swapping in and while
waiting on I/O. For each process, its I/O priority (class/level) is
shown. In addition, the total I/O bandwidth read and written during the
sampling period is displayed at the top of the interface.

Usage:

        $ iotop options


Example:

        $ iotop -b |head
    Total DISK READ :       0.00 B/s | Total DISK WRITE :     213.38 M/s
    Actual DISK READ:       0.00 B/s | Actual DISK WRITE:       0.00 B/s
      TID  PRIO  USER     DISK READ  DISK WRITE  SWAPIN      IO    COMMAND
        6 be/4 root        0.00 B/s    0.00 B/s  0.00 % 99.99 % [kworker/u8:0]
      191 be/3 root        0.00 B/s    0.00 B/s  0.00 % 94.14 % [jbd2/sda1-8]
     2976 be/4 root        0.00 B/s  213.38 M/s  0.00 %  0.00 % dd if=/dev/zero of=/tmp/foo
        1 be/4 root        0.00 B/s    0.00 B/s  0.00 %  0.00 % init
        2 be/4 root        0.00 B/s    0.00 B/s  0.00 %  0.00 % [kthreadd]
        3 be/4 root        0.00 B/s    0.00 B/s  0.00 %  0.00 % [ksoftirqd/0]
        5 be/0 root        0.00 B/s    0.00 B/s  0.00 %  0.00 % [kworker/0:0H]


##  vmstat


The `vmstat` command reports virtual memory statistics about processes, memory, paging,
block I/O, traps, and CPU utilization.

Usage:

        $ vmstat options delay count


Example:

        $ vmstat 2 2
        procs ---memory-- ---swap-- -----io---- -system-- ----cpu----
        r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
        0  0      0 109112  33824 242204    0    0   603    26  196  516  7 11 81  1
        0  0      0 109152  33824 242204    0    0     0     2  124  239  0  1 98  0


Please beware that the first row will always show average measurements
since the machine has booted, and should therefore be neglected. Values
which are related to memory and I/O are expressed in kilobytes (1024
bytes). Old (pre-2.6) kernels might report blocks as 512, 2048 or 4096
bytes instead. Values related to CPU measurements are expressed as a
percent of *total* CPU time. Keep this in mind when interpreting
measurements from a multi-CPU system, as on these systems `vmstat`
averages the number of CPUs into the output. All five CPU fields should
add up to a total of 100% for each interval shown. This is independent
of the number of processors or cores. In other words: `vmstat` can NOT
be used to show statistics per processor or core (`mpstat` or `ps`
should be used in that case). `vmstat` will accept delay in seconds and
a number of counts (repetitions) as an argument, but the process and
memory measurement results will always remain to be instantaneous.

The first process column, "r" lists the number of processes currently
allocated to the processor *run* queue. These processes are waiting for
processor run time, also known as CPU time.

The second process column, "b" lists the number of processes currently
allocated to the *block* queue. These processes are listed as being in
*uninterruptable sleep*, which means they are waiting for a device to
return either input or output (I/O).

The first memory column, "swpd" lists the amount of virtual memory
being used expressed in kilobytes (1024 bytes). Virtual memory consists
of swap space from disk, which is considerably slower than physical
memory allocated inside memory chips.

The second memory column, "free" lists the amount of memory currently
not in use, not cached and not buffered expressed.

The third memory column, "buff" lists the amount of memory currently
allocated to buffers. Buffered memory contains raw disk blocks.

The fourth memory column, "cache" lists the amount of memory currently
allocated to caching. Cached memory contains files.

The fifth memory column, "inact" lists the amount of inactive memory.
This is only shown using the `-a` option.

The sixth memory column, "active" lists the amount of active memory.
This is only shown using the `-a` option.

The first swap column, "si" lists the amount of memory being swapped
*in* from disk (per second).

The second swap column, "so" lists the amount of memory being swapped
*out* to disk (per second).

The first io column, "bi" lists the amount of blocks per second being
received from a block device.

The second io column, "bo" lists the amount of blocks per second being
sent to a block device.

The first system column, "in" lists the number of interrupts per second
(including the clock).

The second system column, "cs" lists the number of context switches per
second.

The cpu columns are expressed as percentages of total CPU time.

The first cpu column, "us" (user code) shows the percentage of time
spent running non-kernel code.

The second cpu column, "sy" (system code) shows the percentage of time
spent running kernel code.

The third cpu column, "id" shows the percentage of idle time.

The fourth cpu column, "wa" shows the percentage of time spent waiting
for I/O (Input/Output).

The fifth cpu column, "st" (steal time) shows the percentage of time
stolen from a virtual machine. This is the amount of real CPU time the
virtual machine (hypervisor or VirtualBox) has allocated to tasks other
than running your virtual machine.

##  netstat


The `netstat` command shows network connections, routing tables,
interface statistics, masquerade connections and multicast memberships.
The results are dependant on the first argument:

-   `(no argument given)` - all active sockets of all configured address
    families will be listed.

-   `--route, -r` - the kernel routing tables are
    shown, output is identical to `route -e` (note: in order to use
    `route`, elevated privileges might be needed whereas `netstat -r`
    can be run with user privileges instead).

-   `--groups, -g` - lists multicast group membership information for
    IPv4 and IPv6

-   `--interfaces, -i` - lists all network interfaces and certain
    specific properties

-   `--statistics, -s` - lists a summary of statistics for each
    protocol, similar to SNMP output

-   `--masquerade, -M` - lists masqueraded connections on pre-2.4 kernels.
    On newer kernels, use `cat /proc/net/ip_conntrack` instead. In order for
    this to work, the *ipt\_MASQUERADE* kernel module has to be loaded.
    This applies to 2.x and 3.x kernels.

Usage:

        $ netstat address_family_options options


Examples:

        $ netstat -aln --tcp
        Active Internet connections (servers and established)
        Proto Recv-Q Send-Q Local Address           Foreign Address         State
        tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN
        tcp        0      0 127.0.0.1:25            0.0.0.0:*               LISTEN
        tcp        0      0 0.0.0.0:34236           0.0.0.0:*               LISTEN
        tcp        0      0 0.0.0.0:389             0.0.0.0:*               LISTEN
        tcp        0      0 0.0.0.0:111             0.0.0.0:*               LISTEN
        tcp6       0      0 :::22                   :::*                    LISTEN
        tcp6       0      0 ::1:25                  :::*                    LISTEN
        tcp6       0      0 :::32831                :::*                    LISTEN

        $ netstat -al --tcp
        Active Internet connections (servers and established)
        Proto Recv-Q Send-Q Local Address           Foreign Address         State
        tcp        0      0 *:ssh                   *:*                     LISTEN
        tcp        0      0 localhost:smtp          *:*                     LISTEN
        tcp        0      0 *:34236                 *:*                     LISTEN
        tcp        0      0 *:ldap                  *:*                     LISTEN
        tcp        0      0 *:sunrpc                *:*                     LISTEN
        tcp6       0      0 [::]:ssh                [::]:*                  LISTEN
        tcp6       0      0 localhost:smtp          [::]:*                  LISTEN
        tcp6       0      0 [::]:32831              [::]:*                  LISTEN


##  ss


The `ss` command is used to show socket statistics. It can display
stats for PACKET sockets, TCP sockets, UDP sockets, DCCP sockets, RAW
sockets, Unix domain sockets, and more. It allows showing information
similar to the `netstat` command, but it can display more TCP and state
information.

Most Linux distributions are shipped with `ss`. Being familiar with this
tool helps enhance your understand of what's going on in the system
sockets and helps you find the possible causes of a performance problem.

Usage:

        $ ss options filter


Example:

        $ ss -t -a
        State      Recv-Q Send-Q              Local Address:Port             Peer Address:Port
        LISTEN     0      5                   192.168.122.1:domain                  *:*
        LISTEN     0      128                             *:ssh                     *:*
        LISTEN     0      128                     127.0.0.1:ipp                     *:*
        LISTEN     0      100                     127.0.0.1:smtp                    *:*


##  iptraf


The `iptraf` tool is a network monitoring utility for IP networks and can
be used to monitor the load on an IP network. It intercepts packets on
the network and displays information about the current traffic over it.

`iptraf` gathers data like TCP connection packet and byte counts,
interface statistics and activity indicators, TCP/UDP traffic
breakdowns, and LAN station packet and byte counts. IPTraf features
include an IP traffic monitor which shows TCP flag information, packet
and byte counts, ICMP details, OSPF packet types, and oversized IP
packet warnings.

Usage:

        $ iptraf options


Example:

        $ iptraf


![ The `iptraf` window. ](images/200-iptraf.jpg)

##  ps


Usage:

        $ ps options


The `ps` command shows a list of the processes currently running. These
are the same processes which are being shown by the `top` command. The
GNU version of `ps` accepts three different *kind* of options:

1.  UNIX options - these may be grouped and *must* be preceded by a single dash

2.  BSD options - these may be grouped and must be used *without* a dash

3.  GNU long options - these are preceded by *two* dashes

These options may be mixed on GNU `ps` up to some extent, but bear in
mind that depending on the version of Linux you are working on you might
encounter a less flexible variant of `ps`. The `ps` manpage can be,
depending on the distribution being questioned, nearly 900 lines
long. Because of its versatile nature, you are encouraged to read
through the manpage and try out some of the options `ps` has to offer.

Examples:

        $ ps ef
        PID TTY      STAT   TIME COMMAND
        4417 pts/0    Ss     0:00 bashDISPLAY=:0 PWD=/home/user HOME=/home/user SESSI
        4522 pts/0    R+     0:00  \_ ps efSSH_AGENT_PID=4206 GPG_AGENT_INFO=/home/user/

        $ ps -ef
        UID        PID  PPID  C STIME TTY          TIME CMD
        root         1     0  0 02:02 ?        00:00:01 init [2]
        root         2     0  0 02:02 ?        00:00:00 [kthreadd]
        root         3     2  0 02:02 ?        00:00:01 [ksoftirqd/0]
        root         4     2  0 02:02 ?        00:00:01 [kworker/0:0]
        root         6     2  0 02:02 ?        00:00:00 [migration/0]
        root         7     2  0 02:02 ?        00:00:00 [watchdog/0]


##  pstree


The `pstree` command displays the same processes as `ps` and `top`,
but the output is presented in a tree-like structure. The tree is rooted
at pid (or `init` if pid is omitted), and if a username is specified the
tree will root at all processes owned by that username. `pstree` provides
an easy way to track back a process to its parent process id (PPID).
Output between square brackets prefixed by a number are identical branches
of processes grouped together, the prefixed number represents the
repetition count. Grouped child threads are shown between square
brackets as well but the process name will be shown between curly braces
as an addition. The last line of the output shows the number of children
for a given process.

Usage:

        $ pstree options pid|username


Example:

        $ pstree 3655
        gnome-terminal---bash---pstree
                       |-bash---man---pager
                       |-gnome-pty-helpe
                       `-3*[{gnome-terminal}]


##  w


The `w` command displays information about the users currently logged
on to the machine, their processes and the same statistics as provided
by the `uptime` command.

Usage:

        $ w options user


Example:

        $ w -s
        02:52:10 up 49 min,  2 users,  load average: 0.11, 0.10, 0.13
        USER     TTY      FROM              IDLE WHAT
        user     tty9     :0                49:51  gdm-session-worker [pam/gdm3]
        user     pts/0    :0                0.00s w -s


Option `-s` stands for "short format".

##  lsof


The `lsof` command is used to list information about
*open files* and their corresponding processes. `lsof` will handle
regular files, directories, block special files, character special
files, executing text references, libraries, streams or network files.
By default, lsof will show unformatted output which might be hard to
read but is very suitable to be interpreted by other programs. The `-F`
option plays an important role here. The `-F` option is used to get
output that can be used by programs like C, Perl and awk. Read the
manpages for detailed usage and the possibilities.

Usage:

        $ lsof options names


The names argument acts as a filter here. Without options, `lsof` will
display *all* open files belonging to *all* active processes.

Examples:

        $ sudo lsof /var/run/utmp
        COMMAND    PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
        gdm-simpl 4040 root   10u   REG   0,14     5376  636 /run/utmp

        $ sudo lsof +d /var/log
        COMMAND   PID USER   FD   TYPE DEVICE SIZE/OFF   NODE NAME
        rsyslogd 2039 root    1w   REG    8,1    44399 262162 /var/log/syslog
        rsyslogd 2039 root    2w   REG    8,1   180069 271272 /var/log/messages
        rsyslogd 2039 root    3w   REG    8,1    54012 271269 /var/log/auth.log
        rsyslogd 2039 root    6w   REG    8,1   232316 271268 /var/log/kern.log
        rsyslogd 2039 root    7w   REG    8,1   447350 271267 /var/log/daemon.log
        rsyslogd 2039 root    8w   REG    8,1    68368 271271 /var/log/debug
        rsyslogd 2039 root    9w   REG    8,1     7888 271270 /var/log/user.log
        Xorg     4041 root    0r   REG    8,1    31030 262393 /var/log/Xorg.0.log


This last example causes `lsof` to search for all open instances of
directory `/var/log` and the files and directory it contains at its top
level.

##  free


The `free` command displays a current overview of the total amount of both
physical and swap memory on a system, as well as the amount of free
memory, memory in use and buffers used by the kernel.

The fourth column, called *shared* has been obsolete but is now used to
display the memory used for tmpfs (shmem in /proc/meminfo)

Usage:

        $ free  options


Example:

        $ free -h
                     total       used       free     shared    buffers     cached
        Mem:          502M       489M        13M        50B        44M       290M
        -/+ buffers/cache:       154M       347M
        Swap:         382M       3.9M       379M


##  top


The `top` command provides a "dynamic real-time view" of a running system.

Usage:

        $ top options


Example:

        $ top
        top - 03:01:24 up 59 min,  2 users,  load average: 0.15, 0.19, 0.16
        Tasks: 117 total,   2 running, 115 sleeping,   0 stopped,   0 zombie
        %Cpu(s):  0.9 us,  4.5 sy,  0.1 ni, 94.3 id,  0.1 wa,  0.0 hi,  0.1 si,  0.0 st
        KiB Mem:    514332 total,   497828 used,    16504 free,    63132 buffers
        KiB Swap:   392188 total,        0 used,   392188 free,   270552 cached

          PID USER      PR  NI  VIRT  RES  SHR S  %CPU %MEM    TIME+  COMMAND
         4041 root      20   0  106m  31m 9556 R  30.4  6.3   3:05.58 Xorg
         4262 user      20   0  527m  71m  36m S  18.2 14.3   2:04.42 gnome-shell


Because of its interactive mode, the most important keys while operating
`top` are the *help* keys `h` or `?` and the *quit* key `q`. The
following scheme provides an overview of the most important function
keys and their equivalent alternatives:

        key      equivalent-key-combinations
        Up       alt + \      or  alt + k
        Down     alt + /      or  alt + j
        Left     alt + <      or  alt + h
        Right    alt + >      or  alt + l (lower case L)
        PgUp     alt + Up     or  alt + ctrl + k
        PgDn     alt + Down   or  alt + ctrl + j
        Home     alt + Left   or  alt + ctrl + h
        End      alt + Right  or  alt + ctrl + l


##  htop

Usage:

        $ htop options


The `htop` command is similar to the `top` command, but allows you to
scroll vertically and horizontally, so you can see all the processes
running on the system, along with their full command lines. Tasks
related to processes (killing, renicing) can be done without entering
their PIDs.

Example:

        $ htop


![ The `htop` window. ](images/200-htop.jpg)

##  uptime


The `uptime` command shows how long the system has been running,
how many users are logged on, the system load averages for the past 1, 5
and 15 minutes and the current time. It support the `-V` option for
version information.

Usage:

        $ uptime options


Example:

        $ uptime
        03:03:12 up  1:00,  2 users,  load average: 0.17, 0.18, 0.16


##  sar


The `sar` command collects, reports or saves system activity information.

Usage:

        $ sar options interval count


Examples:

        $ sar
        Linux 3.2.0-4-686-pae (debian)  05/07/2013  _i686_  (2 CPU)

        02:02:34      LINUX RESTART

        02:05:01    CPU     %user     %nice   %system   %iowait    %steal     %idle
        02:15:01    all      0.15      0.00      1.06      0.23      0.00     98.56
        02:25:01    all      0.98      0.83      3.84      0.04      0.00     94.31
        02:35:01    all      0.46      0.00      4.84      0.04      0.00     94.66
        02:45:01    all      0.90      0.00      5.29      0.01      0.00     93.80
        02:55:01    all      0.66      0.00      4.64      0.03      0.00     94.67
        03:05:02    all      0.66      0.00      5.57      0.01      0.00     93.76
        Average:    all      0.64      0.14      4.19      0.06      0.00     94.98


Without options, sar will output the statistics above.

Using the `-d` option sar will output disk statistics.

        $ sar -d
        06:45:01     DEV      tps  rd_sec/s  wr_sec/s  avgrq-sz avgqu-sz   await   svctm   %util
        06:55:01  dev8-0     6.89    227.01     59.67     41.59     0.02    2.63    1.38    0.95
        07:05:01  dev8-0     2.08     17.73     17.78     17.06     0.00    2.19    0.94    0.20
        07:15:01  dev8-0     1.50     12.16     12.96     16.69     0.00    1.35    0.68    0.10
        Average:  dev8-0     3.49     85.63     30.14     33.15     0.01    2.36    1.19    0.42


The `-b` option switch shows output related to I/O and transfer rate
statistics:

        $ sar -b
        06:45:01      tps      rtps      wtps   bread/s   bwrtn/s
        06:55:01     6.89      4.52      2.38    227.01     59.67
        07:05:01     2.08      0.95      1.13     17.73     17.78
        07:15:01     1.50      0.50      1.00     12.16     12.96
        Average:     3.49      1.99      1.50     85.63     30.14


Some of the most important options to be used with `sar` are:

-   `-c` System calls

-   `-p and -w` Paging and swapping activity

-   `-q` Run queue

-   `-r` Free memory and swap over time

## Match / correlate system symptoms with likely problems


To troubleshoot a given problem, one must first be able to distinguish
*normal* system behaviour from *abnormal* system behaviour.

In the [previous section](#terms-and-utilities), a number of very specific
system utilities as well as their utilization is explained. In this
section, the focus lies on correlating these measurements and being able
to detect anomalies, which in turn can be tied to abnormal system
behaviour. Resource related problems have a very distinguishable factor
in common:

They are the result of one or more resources not being able to cope with
the demand during certain circumstances.

These resources might be related, but are not limited to: the CPU,
physical or virtual memory, storage, network interfaces and connections,
or the input/output between one or more of these components.

##  Estimate throughput and identify bottlenecks in a system including networking


To determine whether or not a certain problem is related to a lack of
resources, the problem itself has to be properly formulated first. Then,
this formulated "deviated" behaviour has to be compared to the expected
behaviour which would result from a trouble-free operating system.

If possible, historical data from `sar` or other tools should be
investigated and compared to real-time tools like `top`,
`vmstat`, `netstat` and `iostat`.

Problems reported by either users or reporting tools are often related
to availability: either resources aren't available in an orderly fashion
or are unavailable altogether. Orderly fashion may be interpreted as
"within an acceptable period of time" here. These kinds of issues are
often reported because they are easily noticeable to users&mdash;i.e., it
affects the *user experience*.

Examples of these kinds of issues might be certain files or (web)
applications which aren't accessible or responding within a reasonable
period of time. To adequately analyse such a situation, it may be useful
to establish a *baseline* which dictates the "expected behaviour" of the
program. This baseline should be established on a properly behaving system,
and providing a threshold should also be considered.

If there is no baseline, resource measurements themselves may help
to determine the root cause of a resource-related problem. If one of
the resources mentioned above is at 100% of its capacity, for example,
the existence of abnormal system behaviour should be easy to explain;
finding the precise *source* of the issue, however, may require a bit more
effort. The utilities presented in the previous chapter should be helpful
here as well.

Examples:

        $ top
        $ vmstat
        $ iostat
        $ netstat


Identifying bottlenecks in a networking environment requires several
steps. A best practice approach could be outlined as follows:

-   Create a map of the network

-   Identify time-dependent behaviour

-   Identify the problem

-   Identify deviating behaviour

-   Identify the cause
