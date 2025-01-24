##  Basic Networking Configuration (205.1)

Candidates should be able to configure a network device to be able to
connect to a local, wired or wireless, and a wide-area network. This
objective includes being able to communicate between various subnets
within a single network.


###   Key Knowledge Areas

-   Utilities to configure and manipulate ethernet network interfaces

-   Configuring wireless networks

###   Terms and Utilities

-   `/sbin/route`

-   `/sbin/ifconfig`

-   `/sbin/ip`

-   `/usr/sbin/arp`

-   `/sbin/iw`

-   `/sbin/iwconfig`

-   `/sbin/iwlist`

###   Configuring the network interface

Most network devices are supported by modern kernels. But you will need
to configure your devices to fit into your network. They will need an IP
address (IPv4, IPv6 or both), possibly a number of gateways/routers has
to be made known to allow access to other networks and the default route
needs to be set. Configuring Network Interface These tasks are usually
performed from the routing table network-initialization script each time
you boot the system. The basic tools for this process are `ifconfig`
(where "if" stands `ifconfig` for interface) and `route`. route

The `ifconfig` command is still widely used. It configures an
interface and makes it accessible to the kernel networking layer. An IP
address, submask, broadcast address and various other parameters can be
set. The tool can also be used to activate and de-activate the
interface, also known as "bringing up" and "bringing down" the
interface. An active interface will send and receive IP datagrams
through the interface. The simplest way to IP invoke it is:

        # ifconfig interface ip-address
                

This command assigns `ip-address` to `interface` and activates it. All
other parameters are set to default values. For instance, the default
network mask is derived from the network class of the IP address, such
as 255.255.0.0 for a class B address.

`route` allows you to add or remove routes from the kernel routing
table. It can be invoked as:

        # route {add|del} [-net|-host] target [if]
                

The `add` and `del` arguments determine whether to add or delete the
route to `target`. The `-net` and `-host` arguments tell the route
command whether the target is a network or a host (a host is assumed if
you don't specify). The `if` argument specifies the interface and is
optional, and allows you to specify to which network interface the route
should be directed \-- the Linux kernel makes a sensible guess if you
don't supply this information.

#### The Loopback Interface

TCP/IP implementations include a virtual network interface that can be
used to emulate network traffic between two processes on the same host.
The loopback interface is not connected to any real network, it is
implemented entirely within the operating system's networking software.
Traffic sent to the loopback IP address (often the address 127.0.0.1 is
used) is simply passed back up the network software stack as if it had
been received from another device. The IPv6 address used is ::1, and
commonly the name "localhost" is used as hostname. It is the first
interface to be activated during boot: loopback interface

        # ifconfig lo 127.0.0.1
                

Occasionally, you will see the dummy hostname localhost being used
instead of the IP address. This requires proper configuration of the
`/etc/hosts` file: 127.0.0.1

        # Sample /etc/hosts entry for localhost
        127.0.0.1 localhost
                

To view the configuration of an interface simply invoke `ifconfig` with
the interface name as lo sole argument:

        $ ifconfig lo
        lo        Link encap:Local Loopback inet addr:127.0.0.1
        Mask:255.0.0.0 UP LOOPBACK RUNNING MTU:3924 Metric:1 RX packets:0
        errors:0 dropped:0 overruns:0 frame:0 TX packets:0 errors:0 dropped:0
        overruns:0 carrier:0 Collisions:0
                

This example shows that the loopback interface has been assigned a
netmask of 255.0.0.0 by default. 127.0.0.1 is a class A address.

These steps suffice to use networking applications on a stand-alone
host. After adding these lines to your network initialization script
and ensuring its execution at boot time by rebooting your machine
you can test the loopback interface. For instance, `telnet localhost`
should establish a telnet telnet connection to your host, giving you a
`login:` prompt.

The loopback interface is often used as a test bed during development,
but there are other applications. For example, all applications based on
RPC use the loopback RPC interface to register themselves with the
portmapper daemon at startup. These applications include NIS and NFS.
NIS NFS Hence the loopback interface should always be configured,
whether your machine is attached to a network or not.

####  Ethernet Interfaces

Configuring an Ethernet interface is pretty much the same as the
ethernet interface loopback interface - it just requires a few more
parameters when you use subnetting.

Suppose we have subnetted the IP network, which was originally a class B
network, into class C subnetworks. To make the interface netmask
recognize this, the `ifconfig` invocation would look like this:

        # ifconfig eth0 172.16.1.2 netmask 255.255.255.0
                

This command assigns the eth0 interface an IP address of 172.16.1.2. If
we had omitted the netmask, `ifconfig` would deduce the netmask from the
IP network class, which would result in an incorrect netmask of
255.255.0.0. Now a quick check shows:

        # ifconfig eth0
        eth0      Link encap 10Mps Ethernet HWaddr
                  00:00:C0:90:B3:42 inet addr 172.16.1.2 Bcast 172.16.1.255 Mask
                  255.255.255.0 UP BROADCAST RUNNING MTU 1500 Metric 1 RX packets 0
                  errors 0 dropped 0 overrun 0 TX packets 0 errors 0 dropped 0 overrun 0
                

You can see that `ifconfig` automatically sets the broadcast broadcast
address address (the Bcast field) to the usual value, which is the
host's network number with all the host bits set. Also, the maximum
transmission unit (the maximum size of IP datagrams the MTU kernel will
generate for this interface) has been set to the maximum size of
Ethernet packets: 1,500 bytes. The defaults are usually what you will
use, but all these values can be overridden if required.

###   Routing Through a Gateway

You do not need routing if your host is on a single Ethernet.
Quite frequently however, networks are connected to one
another by gateways. These gateways may simply link two or more
Ethernets, but may also provide a link to the outside world, such as the
Internet. In order to use a gateway, you have to provide additional
routing information to the networking layer.

Imagine two ethernets linked through such a gateway, the host romeo.
Assuming that romeo has already been configured, we just have to add an
entry to the routing table telling the kernel all hosts on the other
network can be reached through romeo. The appropriate invocation of
`route` is shown below; the `gw` keyword tells it that the next argument
denotes a gateway:

``` {#addnetmc}
    # route add -net 172.16.0.0 netmask 255.255.255.0 gw romeo
            
```

Of course, any host on the other network you wish to communicate with
must have a routing entry for our network. Otherwise you would only be
able to send data to the other network, but the hosts on the other
network would be unable to reply.

This example only describes a gateway that switches packets between two
isolated ethernets. Now assume that romeo also has a connection to the
Internet (say, through an additional PPP link). In this case, we want
datagrams to any destination network to be handed to romeo. This can be
accomplished by making it the default gateway: default gateway

``` {#defaultgwmc}
    # route add default gw romeo
            
```

Something that is frequently misunderstood is that only *ONE* default
gateway can be configured. You may have many gateways, but only one can
be the default.

The network name `default` is a shorthand for 0.0.0.0, which denotes the
default route. The default route 0.0.0.0 default route matches every
destination and will be used if a more specific route is not available.

###   The `ip` command

In recent years many people have advocated the use of the newer
command `/sbin/ip`. It too can be used to show or manipulate routing and
network devices, and also can be used to configure or show policy
routing and tunnels. However, the old tools `ifconfig` and `route` can
be used too if that is more convenient. A use case for the `ip` would be
to show the IP addresses used on the network interfaces in a more
concise way compared to `ifconfig`:

        # ip addr show
        1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN 
            link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
            inet 127.0.0.1/8 scope host lo
            inet6 ::1/128 scope host 
               valid_lft forever preferred_lft forever
        2: p8p1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
            link/ether 00:90:f5:b6:91:d1 brd ff:ff:ff:ff:ff:ff
            inet 192.168.123.181/24 brd 192.168.123.255 scope global p8p1
            inet6 fe80::290:f5ff:feb6:91d1/64 scope link 
               valid_lft forever preferred_lft forever
        3: wlan0: <BROADCAST,MULTICAST> mtu 1500 qdisc mq state DOWN qlen 1000
            link/ether 88:53:2e:02:df:14 brd ff:ff:ff:ff:ff:ff
        4: vboxnet0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
            link/ether 0a:00:27:00:00:00 brd ff:ff:ff:ff:ff:ff
                

in contrast to `ifconfig`

        # ifconfig -a
        lo        Link encap:Local Loopback  
                  inet addr:127.0.0.1  Mask:255.0.0.0
                  inet6 addr: ::1/128 Scope:Host
                  UP LOOPBACK RUNNING  MTU:16436  Metric:1
                  RX packets:48 errors:0 dropped:0 overruns:0 frame:0
                  TX packets:48 errors:0 dropped:0 overruns:0 carrier:0
                  collisions:0 txqueuelen:0 
                  RX bytes:4304 (4.2 KiB)  TX bytes:4304 (4.2 KiB)

        p8p1      Link encap:Ethernet  HWaddr 00:90:F5:B6:91:D1  
                  inet addr:192.168.123.181  Bcast:192.168.123.255  Mask:255.255.255.0
                  inet6 addr: fe80::290:f5ff:feb6:91d1/64 Scope:Link
                  UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
                  RX packets:6653 errors:0 dropped:0 overruns:0 frame:0
                  TX packets:7609 errors:0 dropped:0 overruns:0 carrier:0
                  collisions:0 txqueuelen:1000 
                  RX bytes:3843849 (3.6 MiB)  TX bytes:938833 (916.8 KiB)
                  Interrupt:53 

        vboxnet0  Link encap:Ethernet  HWaddr 0A:00:27:00:00:00  
                  BROADCAST MULTICAST  MTU:1500  Metric:1
                  RX packets:0 errors:0 dropped:0 overruns:0 frame:0
                  TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
                  collisions:0 txqueuelen:1000 
                  RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)

        wlan0     Link encap:Ethernet  HWaddr 88:53:2E:02:DF:14  
                  BROADCAST MULTICAST  MTU:1500  Metric:1
                  RX packets:2 errors:0 dropped:0 overruns:0 frame:0
                  TX packets:11 errors:0 dropped:0 overruns:0 carrier:0
                  collisions:0 txqueuelen:1000 
                  RX bytes:330 (330.0 b)  TX bytes:1962 (1.9 KiB)
                

An example of using `ip` as an alternative to `ifconfig` when
configuring a network interface (p8p1):

        # ifconfig p8p1 192.168.123.15 netmask 255.255.255.0 broadcast 192.168.123.255
                

can be replaced by:

        # ip addr add 192.168.123.15/24 broadcast 192.168.123.255 dev p8p1
                

The `ip` can also be used as alternative for the `route` command:

        # ip route add 192.168.123.254/24 dev p8p1
                

        # ip route show
        192.168.123.0/24 dev p8p1  proto kernel  scope link  src 192.168.123.181  metric 1 
        default via 192.168.123.254 dev p8p1  proto static 
                

The output of the `route` command in this case would be:

        # route
        Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
        192.168.123.0   *               255.255.255.0   U     1      0        0 p8p1
        default         192.168.123.254 0.0.0.0         UG    0      0        0 p8p1
                

As another example, to add a static route to network 192.168.1.0 over
eth0, use:

        # ip route add 192.168.1.0/24 dev eth0
                

For more information please read the manual pages of `ip`.

###   ARP, Address Resolution Protocol

In the ISO network model there are seven layers. The Internet
Protocol is a layer 3 protocol and the NIC is a layer 2 device. In a
local network (layer 2) devices know each other by the MAC (Media Access
Control) address. In the IP network (layer 3) devices know each other by
their IP address.

To allow transfer from data to and from layer 3 IP communication
requires a protocol to map between layer 2 and layer 3. This protocol is
known as ARP - the Address Resolution Protocol. ARP creates a mapping
between an IP address and the MAC address where the IP address is
configured.

When IP enabled devices want to communicate, the kernel of the
originating device hands the IP packet to the network interface driver
software and requests to deliver the IP packet to the recipient. The
only way to communicate on a local Ethernet is by means of a MAC
address, IP addresses are of no use there. To find out the MAC address
of the recipient with the proper IP address, the network driver for the
interface on the origination side will send an ARP request. An ARP
request is a broadcast: it is sent to any computer on the local network.
The computer that has the requested IP address will now answer back with
its MAC address. The sender then has al the information needed to
transmit the packet. Also, the MAC and IP addres are stored in a local
cache for future reference.

The command `arp` can be used to show the ARP cache. Example:

        # arp
        Address                  HWtype  HWaddress           Flags Mask            Iface
        10.9.8.126               ether   00:19:bb:2e:df:73   C                     wlan0
                

The cache can be manipulated manually, for example if a host is brought
down you might want to remove it's arp entry. Normally you do not need
to bother as the cache is not overly persistent. See the man pages for
more information on the `arp` command.

**Note**
Additionally, there exists the reverse ARP protocol (RARP). This
protocol is used to allow an Ethernet (layer 2) device which IP
address(es) it has configured. ARP: broadcast IP and receive MAC. RARP:
broadcast MAC and receive IP.



###   Wireless networking

####  iw

`iw` is used to configure wireless devices. It only supports
the nl80211 (netlink) standard. So if `iw` doesnt see your device, this
might be the reason. You should use `iwconfig` (from the
*wireless\_tools* package) and `iwlist` to configure the wireless
device. These are using the WEXT standard. *wireless\_tools* is
deprecated, but still widely supported.

Syntax:

                # iw command
                # iw [options] [object] command
                

Some common options:

dev

-   This is an object and the name op the wireless device should follow
    after this option. with the command `iw dev` you can see the name of
    your device.

link

-   This is a command and gets the link status of your wireless device.

scan

-   This is a command and scans the network for available access points.

connect

-   This is a command which lets you connect to an access point (essid),
    you can specify a channel behind it and/or your password.

set

-   This is a command that lets you set a different interface/mode. For
    instance `ibss` if you want to set the operation mode to Ad-Hoc. Or
    set the power save state of the interface.

Examples:

            # iw dev wlan0 link                 
            # iw dev wlan0 scan                 
            # iw dev wlan0 connect "Access Point"         
            # iw dev wlan0 connect "Access Point" 2432        
            # iw dev wlan0 connect "Access Point"  0:"Your Key"
            # iw dev wlan0 set type ibss            
            # iw dev wlan0 ibss join "Access Point" 2432
            # iw dev wlan0 ibss leave
            # iw dev wlan0 set power_save on
                    

####  `iwconfig`

iwconfig `iwconfig` is similar to `ifconfig`, but is dedicated to the
wireless interfaces. It is used to set the parameters of the network
interface which are specific to the wireless operation (for example :
the frequency). `iwconfig` may also be used to display those parameters,
and the wireless statistics.

All parameters and statistics are device dependent. Each driver will
provide only some of them depending on hardware support, and the range
of values may change. Please refer to the man page of each device for
details.

Syntax:

        # iwconfig [interface]
        # iwconfig interface [options]
                    

Some common options:

- essid

    -   Set the ESSID (or Network Name - in some products it may also be
    called Domain ID). With some cards, you may disable the ESSID
    checking (ESSID promiscuous) with off or any (and on to reenable
    it). If the ESSID of your network is one of the special keywords
    (off, on or any), you should use \-- to escape it.

- mode

    -   Set the operating mode of the device, which depends on the network
    topology. The mode can be Ad-Hoc (the network is composed of one
    cell only and is without an Access Point), Managed (the node
    connects to a network composed of multiple Access Points, with
    roaming), Master (the node is the synchronisation master or acts as
    an Access Point), Repeater (the node forwards packets between other
    wireless nodes), Secondary (the node acts as a backup
    master/repeater), Monitor (the node is not associated with any cell
    and passively monitors all packets on the frequency) or Auto.

Examples:

        # iwconfig wlan0 essid any
        # iwconfig wlan0 essid "Access Point"
        # iwconfig wlan0 essid -- "any"
        # iwconfig wlan0 mode Ad-Hoc
                    

####  iwlist

`iwlist` is used to scan for available wireless networks and
display additional information about them. The syntax is as follows:

        # iwlist [interface] command
                    

`iwlist` can display ESSID's, frequency/channel information, bit-rates,
encryption type, power management information of other wireless nodes in
range. Which information is displayed is hardware dependent.

Some useful options are:

- scan\[ning\]

  -   Returns a list of ad-hoc networks and access points. Depending on
    the type of card, more information is shown, i.e. ESSID, signal
    strength, frequency. Scanning can only be done by root. When a
    non-root users issues the scan command, results from the last scan
    are returned, if available. This can also be achieved by adding the
    option **last**. Furthermore, the option **essid** can be used to
    scan for a specific ESSID. Depending on the driver, more options may
    be available.

- keys/enc\[ryption\]

 -   List the encryption key sizes supported and list all the encryption
    keys set in the device.

