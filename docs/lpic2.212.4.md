##  Security tasks (212.4)

Candidates should be able to receive security alerts from various
sources, install, configure and run intrusion detection systems and
apply security patches and bugfixes.

###   Key Knowledge Areas:

- Tools and utilities to scan and test ports on a server

- Locations and organizations that report security alerts as Bugtraq,
CERT, or other sources

- Tools and utilities to implement an intrusion detection system (IDS)

- Awareness of OpenVAS and Snort

###   Terms and utilities:

-   `telnet`

-   `nmap`

-   `fail2ban`

-   `nc`

-   `OpenVAS`

-   `Snort IDS`

##  `nc` (netcat)

###   Description

Netcat (nc) is a very versatile network tool. Netcat is a
computer networking service for reading from and writing to network
connections using TCP or UDP. Netcat is designed to be a dependable
\"back-end\" device that can be used directly or easily driven by other
programs and scripts. At the same time, it is a feature-rich network
debugging and investigation tool. Netcat's features are numerous;
Netcat can, for instance, be used as a proxy or portforwarder. It can
use any local source port, or use loose source-routing. It is commonly
referred to as the TCP/IP Swiss army knife.

Some of the major features of netcat are:

-   Outbound or inbound connections, TCP or UDP, to or from any ports

-   Full DNS forward/reverse checking, with appropriate warnings

-   Ability to use any local source port

-   Ability to use any locally-configured network source address

-   Built-in port-scanning capabilities, with randomizer

-   Built-in loose source-routing capability

-   Can read command line arguments from standard input

-   Slow-send mode, one line every N seconds

-   Hex dump of transmitted and received data

-   Optional ability to let another program service establish
    connections

-   Optional telnet-options responder

telnet Because netcat does not make any assumptions about the protocol
used across the link, it is better suited to debug connections than
`telnet`.

###   Example netcat. Using netcat to perform a port scan

With the -z option netcat will perform a portscan on the ports given on
the command line. By default netcat will produce no output. When
scanning only one port the exit status indicates the result of the scan,
but with multiple ports the exit status will allways be \"0\" if one of
the ports is listening. For this reason using the \"verbose\" option
will be useful to see the actual results:

        # nc -vz localhost 75-85
        nc: connect to localhost port 75 (tcp) failed: Connection refused
        nc: connect to localhost port 76 (tcp) failed: Connection refused
        nc: connect to localhost port 77 (tcp) failed: Connection refused
        nc: connect to localhost port 78 (tcp) failed: Connection refused
        Connection to localhost 79 port [tcp/finger] succeeded!
        Connection to localhost 80 port [tcp/http] succeeded!
        nc: connect to localhost port 81 (tcp) failed: Connection refused
        nc: connect to localhost port 82 (tcp) failed: Connection refused
        nc: connect to localhost port 83 (tcp) failed: Connection refused
        nc: connect to localhost port 84 (tcp) failed: Connection refused
        nc: connect to localhost port 85 (tcp) failed: Connection refused
                    

The man page of netcat shows some more examples on how to use netcat.

Netcat can easily be used in scripts for a lot of tests you want to run
automated.

##  The `fail2ban` command

###   Description

`Fail2ban` scans log files like `/var/log/pwdfail` or
`/var/log/apache/error_log`, and bans IP addresses that cause too many
rejected password attempts. It updates firewall rules to block the IP
addresses.

Fail2ban's main function is to block IP addresses that belong to hosts
that may be trying to breach the system's security. It determines these
by monitoring log files (e.g. `/var/log/pwdfail`, `/var/log/auth.log`,
etc.) and bans any host IP that does too many login attempts or performs
any other unwanted action within a time frame set by the administrator.
Fail2ban is typically configured to unban a blocked host after a certain
period, so as to not \"lock out\" any genuine connections. An unban time
of several minutes is usually sufficient to prevent a network connection
from being flooded by malicious attempts, as well as to reduce the
likelihood of a successful dictionary attack.

##  The `nmap` command

###   Description

`nmap` is a network exploration tool and nmap security scanner. It
can be used to scan a network, determine which hosts are up and what
services they are offering.

`nmap` supports a large number of scanning techniques network scanning
nmapnetwork scanning such as: UDP, TCP connect(), TCP SYN (half open),
ftp proxy (bounce TCP SYN bounce attack reverse-ident ping sweep ACK
sweep Xmas Tree SYN sweep NULL Scan nmapTCP SYN nmapbounce attack
nmapreverse-ident nmapping sweep nmapACK sweep nmapXmas Tree nmapSYN
sweep nmapNULL Scan attack), Reverse-ident, ICMP (ping sweep), FIN, ACK
sweep, Xmas Tree, SYN sweep, IP Protocol and Null scan.

If you have built a firewall, and you wish to check that no ports are
open nmaptesting a firewall that you do not want open, `nmap` is the
tool to use.

###   Using the `nmap` command

If a machine gets infected by a rootkit, some system utilities like
`top`, `ps` and `netstat` will usually be replaced by the attacker. The
modified versions of these commands aide the attacker by not showing all
available processes and listening ports. By performing portscans against
our host we can explore which ports are open, and compare this with a
list of known services. As an example, here's an example of a TCP
portscan against our localhost:

        $ nmap -sT localhost

        Starting Nmap 6.25 ( http://nmap.org ) at 2020-05-08 11:51 CEST
        Nmap scan report for localhost (127.0.0.1)
        Host is up (0.0011s latency).
        Other addresses for localhost (not scanned): 127.0.0.1
        Not shown: 993 closed ports
        PORT     STATE SERVICE
        22/tcp   open  ssh
        25/tcp   open  smtp
        53/tcp   open  domain
        443/tcp   open  http
        389/tcp  open  ldap

        Nmap done: 1 IP address (1 host up) scanned in 0.20 seconds
                    

**Note**
By default, `nmap` will only scan the 1000 most common ports. Use the
`-p 1-65535` or `-p -` switch to scan all available ports.

Let's perform the same scan, using the UDP protocol:

        $ nmap -sU localhost
        You requested a scan type which requires root privileges.
        QUITTING!
                

Nmap is a very powerful network scanner, but some options require root
privileges. If you would perform the command `nmap 
                localhost` both as root and using your own privileges,
nmap would use the `-sS` option as root and the `-sT` when run with
normal user privileges.

Now, let's run the UDP scan again using root privileges trough sudo:

    $ sudo nmap -sU localhost

    Starting Nmap 7.60 ( https://nmap.org ) at 2020-05-08 12:42 CEST
    Nmap scan report for localhost (127.0.0.1)
    Host is up (0.0000090s latency).
    Other addresses for localhost (not scanned): ::1
    Not shown: 998 closed ports
    PORT     STATE SERVICE
    111/udp  open  rpcbind
    2049/udp open  nfs

    Nmap done: 1 IP address (1 host up) scanned in 1.62 seconds
                    

Nmap is a very versatile and powerful tool, and offers a variety of
options regarding its capabilities. Nmap can, for example, be used for
active TCP/IP stack fingerprinting to determine the remote OS. You need
administrator rights to do this:

    jos@xml:~$ nmap -A lpic2.unix.nl

    Starting Nmap 7.60 ( https://nmap.org ) at 2020-05-08 12:46 CEST
    Nmap scan report for lpic2.unix.nl (149.210.155.120)
    Host is up (0.011s latency).
    Other addresses for lpic2.unix.nl (not scanned): 2a01:7c8:aab3:101::8080
    rDNS record for 149.210.155.120: 149-210-155-120.colo.transip.net
    Not shown: 995 filtered ports
    PORT     STATE  SERVICE    VERSION
    25/tcp   closed smtp
    80/tcp   closed http
    443/tcp  open   ssl/ssl    Apache httpd (SSL-only mode)
    | http-methods:
    |_  Potentially risky methods: TRACE
    |_http-server-header: Apache/2.4.43 (FreeBSD) OpenSSL/1.1.1d-freebsd
    |_http-title: Maintenance
    | ssl-cert: Subject: commonName=lpic2.unix.nl
    | Subject Alternative Name: DNS:lpic2.unix.nl
    | Not valid before: 2020-05-06T08:18:57
    |_Not valid after:  2020-08-04T08:18:57
    |_ssl-date: TLS randomness does not represent time
    2222/tcp open   ssh        OpenSSH 7.8 (FreeBSD 20180909; protocol 2.0)
    | ssh-hostkey:
    |   2048 98:60:f4:d9:52:42:79:9c:81:bc:04:09:1b:97:3d:d3 (RSA)
    |   256 04:d7:19:2d:c9:81:b4:26:c6:22:46:b0:f8:98:10:c8 (ECDSA)
    |_  256 48:a7:4f:e9:c1:89:d0:67:8e:44:ab:29:a9:70:1c:b7 (EdDSA)
    8080/tcp closed http-proxy
    Service Info: OS: FreeBSD; CPE: cpe:/o:freebsd:freebsd

    Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
    Nmap done: 1 IP address (1 host up) scanned in 18.04 seconds
                    

As you can tell from the output, the tested machine was the machine
which host this website.

Please consult the manpage of `nmap(1)` to learn more about its
features. nmapoptions

##  OpenVAS

OpenVAS The Open Vulnerability Assessment System (OpenVAS) is an open
source framework of several services and tools offering a comprehensive
and powerful vulnerability scanning and vulnerability management
solution.

The actual security scanner is accompanied with a daily updated feed of
Network Vulnerability Tests (NVTs), over 50,000 in total (as of May
2020).

Detailed information about OpenVAS can be found at: [Openvas - Open
vulnerability assessment system community
site](http://www.openvas.org/index.html).

##  The Snort IDS (Intrusion Detection System) 

Snort Snort is an open source network intrusion detection system (NIDS)
capable of performing real-time traffic analysis and packet logging on
IP networks. It can perform protocol analysis, content
searching/matching and can be used to detect a variety of attacks and
probes, such as buffer overflows, stealth port scans, CGI attacks, SMB
probes, OS fingerprinting attempts and much more. Snort uses a flexible
rules language to describe traffic that it should collect or pass, as
well as a detection engine that utilizes a modular plugin architecture.
Snort has a real-time alerting capability as well, incorporating
alerting mechanisms for syslog, a user-specified file, a UNIX socket or
WinPopup messages to Windows clients using Samba's smbclient. Snort has
three primary uses. It can be used as a straight packet-sniffer like
tcpdump, a packet-logger (useful for network traffic debugging, etc), or
as a full blown network-intrusion detection system. Snort logs packets
in either tcpdump binary format or in Snort's decoded ASCII format to
logging directories that are named based on the IP address of the
foreign host.

###   Basic structure of Snort rules

All Snort rules have two logical parts: rule *header* and rule
*options*.

The rule header contains information about what action a rule takes. It
also contains criteria for matching a rule against data packets. The
options part usually contains an alert message and information about
which part of the packet should be used to generate the alert message.
The options part contains additional criteria for matching a rule
against data packets. A rule may detect one type or multiple types of
intrusion activity. Intelligent rules should be able to apply to
multiple intrusion signatures.

###   Structure of Snort rule headers

The action part of the rule determines the type of action taken when
criteria are met and a rule is exactly matched against a data packet.
Typical actions are generating an alert or log message or invoking
another rule. You will learn more about actions later in this chapter.

The protocol part is used to apply the rule on packets for a particular
protocol only. This is the first criterion mentioned in the rule. Some
examples of protocols used are IP, ICMP, UDP etc.

The address parts define source and destination addresses. Addresses may
be a single host, multiple hosts or network addresses. You can also use
these parts to exclude some addresses from a complete network. More
about addresses will be discussed later. Note that there are two address
fields in the rule. Source and destination addresses are determined
based on direction field. As an example, if the direction field is
"-\>", the Address on the left side is source and the Address on the
right side is destination.

In case of TCP or UDP protocol, the port parts determine the source and
destination ports of a packet on which the rule is applied. In case of
network layer protocols like IP and ICMP, port numbers have no
significance.

The direction part of the rule actually determines which address and
port number is used as source and which as destination.

Just some examples:

        alert icmp any any -> any any (msg: "Ping with TTL=100";  ttl: 100;)
        alert udp any 1024:2048 -> any any (msg: "UDP ports";)
        alert tcp 192.168.2.0/24 23 <> any any (content: "confidential"; msg: "Detected confidential";)
        log udp any !53 -> any any log udp
                    

Detailed information about Snort can be found at: [Snort
IDS](https://www.snort.org).

##  Intrusion Detection and Prevention Systems 

When talking about Intrusion Detection Systems (IDS), we can make a
distinction between Host Intrusion Detection Systems (HIDS) and Network
Intrusion Detection Systems (NIDS). A HIDS alerts when a host is
suffering from suspicious activities. A NIDS usually inspects network
traffic, preferably at a low level and alerts if suspicious traffic is
detected.

Some IDS systems can be configured in a way that they do not only send
out an alert, but also prevent access to a certain resource. This
resource can either be a TCP/IP or UDP port, a physical port on a
network device or complete access to a certain host or network segment
trough a router or firewall. Since these systems not only detect, but
also prevent they are called Intrusion Prevention Systems (IPS). As well
as with IDS systems, we can distinguish HIPS from NIPS systems.

Both intrusion detection and intrusion prevention systems use a system
of definitions for detection. These definitions describe certain
characteristics that when met, trigger off an alert or countermeasure.
If a detection takes place and is correct, we call this a *true
positive*. If a detection takes place but is inaccurate, this is called
a *false positive.*. When the system does not detect something that does
not occur, this is called a true negative. When there actually is an
event which is not detected by the system, this is called a false
negative.

Often, the detection capabilities of the IDS are expanded by using
heuristic detection methods. In order for these to be both effective and
accurate, the system needs to be trained. During this period, a lot of
false positives may be detected which isn't a bad thing. But the system
needs to be tweaked so the amount of false positives will be reduced to
a minimum. A false negative is equal to having no IDS in place, and is
the most undesirable behavior for an IDS.

##  Keeping track of security alerts

Security alerts are warnings about vulnerabilities in certain pieces
security alerts of software. Those vulnerabilities can result in a
decrease of your vulnerability service level because certain individuals
are very good at misusing those vulnerabilities. This can result in your
system being hacked or blown out of the water.

Most of the time there is already a solution for the problem or someone
is already working on one, as will be described in the rest of this
section.

###   Bugtraq {#sqbugtraq}

BugTraq is a full disclosure moderated mailing-list at
[securityfocus.com](http://www.securityfocus.com) for detailed
discussion and announcement of computer security vulnerabilities: what
they are, how to exploit them and how to fix security vulnerabilities
them.

####  Bugtraq website

The [SecurityFocus](http://www.securityfocus.com) website brings
together many different resources related to security. One of them is
the securityfocus Bugtraq mailing list. There also is a Bugtraq FAQ.

####  How to subscribe to Bugtraq

Use the webform at <http://www.securityfocus.com/> to subscribe to any
of the SecurityFocus mailing lists.

###   CERT

####  Description

The CERT Coordination Center (CERT/CC) is a center of Internet CERT
security expertise, at the Software Engineering Institute, a SEI
federally funded research and development center operated by Carnegie
Mellon University. They study Internet security Carnegie Mellon
vulnerabilities, handle computer security incidents, publish security
alerts, research long-term changes in networked systems and develop
information and training to help you improve security at your site.

####  Website

CERT maintains a website called CERThttp://www.cert.org [The CERT
Coordination Center](http://www.cert.org) CERThttp://www.cert.org

####  How to subscribe to the CERT Advisory mailing list

See the us-cert.gov [lists and feed
page](https://www.us-cert.gov/mailing-lists-and-feeds) to sign up for
the CERT Advisory mailing list or the RSS feeds issued on diverse NCAS
publications.

###   CIAC

####  Description

CIAC is the U.S. Department of Energy's Computer Incident Advisory CIAC
Capability. Established in 1989, shortly after the Internet Worm, CIAC
provides various computer security services free of charge to employees
and contractors of the DOE, such as: Incident Handling consulting,
Computer Security Information, On-site Workshops, White-hat Audits.

####  Website

There is a [CIAC
Website](http://energy.gov/cio/office-chief-information-officer/services/incident-management).

####  Subscribing to the mailing list

CIAC has several self-subscribing mailing lists for electronic
CIACsubscribing publications:

CIAC-BULLETIN for Advisories, highest priority - time critical
CIACBULLETIN information, and Bulletins, important computer security
information.

CIAC-NOTES for Notes, a collection of computer security articles.
CIACNOTES

SPI-ANNOUNCE for official news about Security Profile Inspector
CIACSPI-ANNOUNCE (SPI) software updates, new features, distribution and
availability.

SPI-NOTES, for discussion of problems and solutions regarding the
CIACSPI-NOTES use of SPI products.

The mailing lists are managed by a public domain software package called
ListProcessor, which ignores E-mail header subject lines. To subscribe
(add yourself) to one of the mailing lists, send requests of the
following form: subscribe list-name LastName, FirstName, PhoneNumber as
the E-mail message body, substituting CIAC-BULLETIN, CIAC-NOTES,
SPI-ANNOUNCE or SPI-NOTES for "list-name" and valid information for
"LastName" "FirstName" and "PhoneNumber." Send to:
ciac-listproc\@llnl.gov. CIAC ciac-listproc\@llnl.gov

You will receive an acknowledgment containing address and initial PIN,
and information on how to change either of them, cancel your
subscription or get help.

####  Unsubscribing from the mailing list

To be removed from a CIAC mailing list, send the following request via
CIAC unsubscribe E-mail to ciac-listproc\@llnl.gov: unsubscribe
list-name.

Testing for open mail relays with telnet

###   Description

An open mail relay is a mail server that accepts SMTP connections open
relay from anywhere and will forward emails to any domain. This means
that everyone can connect to port 25 on that mail server and send mail
to whomever they want. As a result your server's IP might end up on
anti-spam blacklists. blacklisting

###   Testing for open mail relaying

open relay how to testTesting a mail relay can be done by delivering an
email for a recipient to a server that's not supposed to do any
relaying for the recipients domain. If the server accepts AND delivers
the email it is an open relay.

In the following example we use `telnet` to connect to a SMTP server
running on port 25:

        $ telnet localhost 25
        Trying ::1...
        Connected to localhost.
        Escape character is '^]'.
        220 linux.mailserver ESMTP Exim 4.80 Wed, 03 Jul 2019 08:08:06 -0500
        MAIL FROM: bob@example.com
        250 OK
        RCPT TO: root@localhost
        250 Accepted
        DATA
        354 Enter message, ending with "." on a line by itself
        Open Mail Relay test message
        .
        250 OK id=1UuMnI-0001SM-Pe
        QUIT
        221 linux.mailserver closing connection
        Connection closed by foreign host.
                    

The message is accepted because the mailserver is configured to accept
connections that origin from the local host, and because
`root@localhost` is a valid email address according to the SMTP server.

Telnet is not considered very suitable as a remote login protocol
because all data is being transmitted in clear text across the network.
But the `telnet` command is very useful for checking open ports. The
target port can be given as an argument, as can be seen in the example
above.
