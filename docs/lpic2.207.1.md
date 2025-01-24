##  Basic DNS server configuration (207.1)

Candidates should be able to configure BIND to function as an
authoritive and as a recursive, caching-only DNS server. This objective
includes the ability to manage a running server and configure logging.

###   Key Knowledge Areas

-   BIND 9.x configuration files, terms and utilities.

-   Defining the location of the BIND zone files in BIND configuration
    files.

-   Reloading modified configuration and zone file.

-   Awareness of dnsmasq, djbdns and PowerDNS as alternate name servers.

###   Terms and Utilities

-   `/etc/named.conf`

-   `/var/named/`

-   `/usr/sbin/rndc`

-   `/usr/sbin/named-checkconf`

-   `kill`

-   `dig`

-   `host`

##  Name-server components in BIND

Name servers like BIND (Berkeley Internet Name Domain system) are part
of a worldwide DNS system that resolves machine names to IP addresses.

In the early days of the Internet, host name to IP address mappings were
maintained by the Network Information Center (NIC) in a single file
called `HOSTS.TXT`. This file was then distributed by FTP to other
Internet connected hosts.

Due to the vast amount of hosts being connected to the Internet over
time, another name resolving system was developed known as Domain Names.
This system incorporated design goals like distributed updates and local
caching, to increase resolving performance. Because of these features,
every nameserver needs to be specifically configured for it's purpose.
The following terms are apparent when configuring nameserver software
like BIND:

*Zones* are the equivalent of domains. Zone configuration files consist
of hostnames and IP address information. *Nameserver* software responds
to requests on port `53`, and translates DNS (host- or domain-)names to
IP addresses. It can also translate IP addresses into DNS names, this is
called a "reverse DNS lookup" (rDNS). In order for rDNS to work, a so
called pointer DNS record (PTR record) has to exist for the host being
queried.

We distinguish *authoritive* nameservers, *recursive* nameservers and so
called *resolvers*. The authoritive nameserver for a zone is the
nameserver which administrates the zone configuration. It is therefore
sometimes also referred to as the zone *master*. A recursive nameserver
is a nameserver that resolves zones for which it is not authoritive for
at other nameservers. The resolver is the part of the nameserver and DNS
client software which performs the actual queries. In general, these are
libraries as part of DNS software.

Table [Major BIND components](#BINDparts) lists the most relevant parts
of BIND software on a system. Note that directories may vary across
distributions.

|  Component |  Description |
|----|----|
|`/usr/sbin/named`|          the real name server 
| `/usr/sbin/rndc` |             name daemon control program |
|`/usr/sbin/named-checkconf`  | program to check named.conf file for errors 
`named.conf` |                    BIND configuration file |
|`/etc/init.d/bind` |           distribution specific start script |
|`/var/named`|                working directory for `named` |


Resolving is controlled by the file `nsswitch.conf` which
is mentioned in [???](#c2.210).

BIND components will be discussed below.

###   The `named.conf` 

The file `named.conf` is the main configuration file of BIND.
bindnamed.conf It is the first configuration file read by `named`, the
DNS name daemon.

####  Location of `named.conf`

According to LPI the location of the file `named.conf` is in the `/etc`
directory. However, the location may vary across distributions. For
example in the Debian Linux distribution `named.conf` is located in the
`/etc/bind` directory.

###   A *caching-only* name server

caching-only nameserver A caching-only name server resolves names, which
are also stored in a cache, so that they can be accessed faster when the
nameserver is asked to resolve these names again. But this is what
*every* name server does. The difference is that this is the *only* task
a *caching-only* name server performs. It does not serve out zones,
except for a few internal ones.

This is an example of a *caching-only* `named.conf` file. The version
below is taken from the Debian bind package (some comments removed).

        options {
                directory "/var/named";

                // query-source address * port 53;

                // forwarders {
                //      0.0.0.0;
                // };
        };

        // reduce log verbosity on issues outside our control
        logging {
                category lame-servers { null; };
                category cname { null; };
        };

        // prime the server with knowledge of the root servers
        zone "." {
                type hint;
                file "/etc/bind/db.root";
        };

        // be authoritative for the localhost forward and reverse zones, and for
        // broadcast zones as per RFC 1912

        zone "localhost" {
                type master;
                file "/etc/bind/db.local";
        };

        zone "127.in-addr.arpa" {
                type master;
                file "/etc/bind/db.127";
        };

        zone "0.in-addr.arpa" {
                type master;
                file "/etc/bind/db.0";
        };

        zone "255.in-addr.arpa" {
                type master;
                file "/etc/bind/db.255";
        };

        // add entries for other zones below here
                    

The Debian bind package that contains this file, will provide a fully
functional *caching-only* name server. BIND packages of other
manufacturers will provide the same functionality.

####  Syntax

The `named.conf` file contains *statements* that start with a keyword
plus an bind{ bind} opening curly brace "{" and end with a closing curly
brace "}". A statement may contain other statements. The `forwarders`
statement is an example of this. bindforwarders A statement may also
contain IP addresses or the `file` word followed by a filename. These
simple statements bindfile *must* be terminated by a semi-colon (`;`).

All kinds of comments are allowed, e.g., `//` and `#` as end of line
comments. See the bind// bind\# named.conf 5 manual page for details.

**Note**
The ";" is NOT valid as a comment sign in `named.conf`. However, it is a
comment sign in BIND zone bind; files, like the file
`/etc/bind/db.local` from the `named.conf` example above. An example
BIND zone file can be found in [???](#db.local-file)

#### The `options` statement

Of the many possible entries (see named.confbindoptions 5) inside an
`options` statement, only `directory`, `forwarders`, `forward`,
`version` and `dialup` will be discussed below.

**Note**
There can be only *one* `options` statement in a `named.conf` file.

`directory`

-   Specifies the working directory for the name daemon. binddirectory A
    common value is `/var/named`. Also, zone files without a directory
    part are looked up in this directory.

    Recent distributions separate the configuration directory from the
    working directory. In a recent Debian Linux distribution, for
    example, the working directory is specified as `/var/cache/bind`,
    but all the configuration files can be found in `/etc/bind`. All
    zone files can also be found in the latter directory and must be
    specified with their directory part, as can be seen in the
    `named.conf` example above.

`forwarders`

-   The `forwarders` statement contains one or more IP addresses of name
    servers to query. bindforwarders How these IP addresses are used is
    specified by the `forward` statement described below.

    The default is no forwarders. Resolving is done through the
    worldwide (or company local) DNS system.

    Usually the specified name servers are the same the Service Provider
    uses.

`forward`

-   The `forward` works only when bindforward `forwarders` are
    specified.

    Two values can be specified: `forward first;` (default) and
    `forward only;`. With `forward first`, the query is sent first to
    the bindforward first; bindforward only; specified name-server IP
    addresses and if this fails it should perform lookups elsewhere.
    With `forward only`, queries are limited only to the specified
    name-server IP addresses.

    An example with both `forwarders` and `forward`:

            options {
                // ...

                forwarders {
                    123.12.134.2;
                    123.12.134.3;
                }

                forward only;

                // ...
            };
                                    

    In this example bind is told to query *only* the name servers
    `123.12.134.2` and `123.12.134.3`.

`version`

-   It is possible to query the version from a running name server:
    bindversion

            $ dig @ns12.zoneedit.com version.bind chaos txt

            ; <<>> DiG 9.8.3-P1 <<>> @ns12.zoneedit.com version.bind chaos txt
            ; (1 server found)
            ;; global options: +cmd
            ;; Got answer:
            ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 59790
            ;; flags: qr aa rd; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 0
            ;; WARNING: recursion requested but not available

            ;; QUESTION SECTION:
            ;version.bind.          CH  TXT

            ;; ANSWER SECTION:
            VERSION.BIND.       0   CH  TXT "8.4.X"

            ;; Query time: 169 msec
            ;; SERVER: 209.62.64.46#53(209.62.64.46)
            ;; WHEN: Tue Jun 25 11:38:48 2013
            ;; MSG SIZE  rcvd: 60
                                    

    Note that the BIND version is shown in the output. Because some BIND
    versions have known exploits, the BIND version is sometimes kept
    hidden. The `version` specification:

            version "not revealed";
                                    

    or

            version none;
                                    

    inside the `options` statement leads to `not revealed` responses on
    version queries.

`dialup`

-   When a name server sits behind a firewall, that connects to the
    binddialup outside world through a dialup connection, some
    maintenance normally done by name servers might be unwanted.
    Examples of unwanted actions are: sending heartbeat packets, zone
    transfers with a nameserver on the other side of the firewall.

    The following example, also inside the `options` part, stops
    external zone maintenance:

            heartbeat-interval 0;
            dialup yes; // NOTE: This actually *stops* dialups!
                                    

Many more options can be placed inside the options block. Refer to the
manual pages for details.

Depending on the distribution used, a seperate `bind.conf.options` file
might be used which holds all the options for the BIND configuration.
The main configuration file `named.conf` has to include this separate
file though, which can be accomplished by adding the following line to
`named.conf`:

        include "/etc/bind/named.conf.options";
                    

Other separate configuration files like `named.conf.log` or
`named.conf.default-zones` may be nested this way as well.

#### The `logging` statement

The BIND (version 8 and 9) logging system is too elaborate to discuss in
detail here. An important difference between the two has to do with
parsing the log configuration. BIND 8 used to parse the `logging`
statement and start the logging configuration right away. BIND 9 only
establishes the logging configuration *after* the entire configuration
file has been parsed. While starting up, the server sends all logging
messages regarding syntax errors in the configuration file to the
default channels. These errors may be redirected to standard error
output if the `-g` option has been given during startup.

The distinction between *categories* and bindcategory *channels* is an
important part of logging.

A *channel* is an output specification. The `null` channel, for example,
dismisses any output sent to the channel.

A *category* is a type of data. The category `security` is one of many
categories. To log messages of type (*category*) `security`, for
example, to the `default_syslog` channel, use the following:

        logging {
            category security { default_syslog; };
            // ...
        };
                    

To turn off logging for certain types of data, send it to the `null`
channel, as is done in the example `named.conf` shown earlier:

        logging {
                category lame-servers { null; };
                category cname { null; };
        };
                    

This means that messages of types `lame-servers` and `cname` are being
discarded.

There are *reasonable defaults* for logging. This means that a
`named.conf` without `logging` statement is possible.

**Note**
A maximum of *one* `logging` statement is allowed in a `named.conf`
file.

#### Predefined `zone` statements

A zone defined in `named.conf` can be referred to using the "@" symbol
inside the corresponding zone file. bind@ The "@" is called the *current
origin*. For example,

        zone "127.in-addr.arpa" {
                type master;
                file "/etc/bind/db.127";
        };
                    

will result in a *current origin* of `127.in-addr.arpa` that is
available as "@" in file `/etc/bind/db.127`.

Details about zone files, as well as how to create your bindzone file
own `zone` files and statements will be covered in [???](#c2.207.2).

The `named` name server daemon

The `named` name server daemon is the program that communicates with
other name servers to resolve names. It accepts queries, looks in its
cache and queries other name servers if it does not yet have the answer.
Once it finds an answer in its own cache or database or receives an
answer from another nameserver, it sends the answer back to the name
server that sent the query in the first place.

Table [Controlling named](#namedctl) lists ways to control the `named` name
server.

| Method {#namedctl} | See |
| --- | --- |
| The `rdnc` program | [The program](#rndc) |
| Sending signals | [Sending signals to named](#namedsigs)
| Using a start/stop script | [Controlling with a start/stop script](#namedstartstop)

#### The `rndc` program {#rndc}

The `rndc` (Remote Name Daemon Control) program rndc can be used to
control the `named` name server daemon, locally as well as remotely. It
requires a `/etc/rndc.key` file which contains a key.

        key "rndc-key" {
            algorithm hmac-md5;
            secret "tyZqsLtPHCNna5SFBLT0Eg==";
        };

        options {
            default-key "rndc-key";
            default-server 127.0.0.1;
            default-port 953;
        };
                

The name server configuration file `/etc/named.conf` needs to contain
the same key to allow a host to control the name server. The relevant
part of that file is shown below.

        key "rndc-key" {
            algorithm hmac-md5;
            secret "tyZqsLtPHCNna5SFBLT0Eg==";
        };
     
        controls {
            inet 127.0.0.1 port 953
                allow { 127.0.0.1; } keys { "rndc-key"; };
        };
                

The secret itself will never be transmitted over the network. Both ends
calculate a hash using the algorithm declared after the `algorithm`
keyword and compare hashes.

Depending on the distribution used, the configuration files might also
be stored in `/etc/bind/*`. The `rndc.key` file should be owned by
root:bind and have a mode of 640. The main bind configuration file,
`named.conf` should have a line that includes the keyfile. Running the
program `rndc-confgen` will create a key in case none is available on
the system.

A command to the name server can be given as a parameter to rndc, e.g.:
`rndc reload`. This will request the name server to reload its
configuration and zone files. All commands specified in this way are
understood by the name daemon. The help command presents a list of
commands understood by the name server.

While not discussed here `rndc` may be used to manage several name
servers remotely. Consult the man pages and the "BIND 9 Administrator
Reference Manual" for more information on rndc and BIND.

#### The `named-checkconf` utility {#named-checkconf}

`named-checkconf` is a very useful utility that checks the `named.conf`
file for errors. If the `named.conf` file is located in the regular
`/etc/named.conf` location on your distribution you only have to type in
the command to check the file.

        # named-checkconf
                

The location of the named.conf file can be different however (depending
on the distribution you are using). In some cases for example the file
is located at `/etc/bind/named.conf`. The `named-checkconf` utility wil
not automatically recognize locations other than `/etc/named.conf` in
these cases you will have to include path and filename after the
command.

        # named-checkconf /etc/bind/named.conf
                

When the prompt returns without giving any messages it means that
`named-checkconf` didn't find anything wrong with it. The example below
will show what happens when it dit find something wrong. In this case I
made an error by forgetting to add the letter `i` on an `include`
statement.

        [root@localhost etc]# named-checkconf
        /etc/named.conf:56: unknown option 'nclude'
                

The `named-checkconf` utility will only check the `named.conf` file.
Other configuration files called from within the `named.conf` file using
for example the `include` statement will not be checked automatically.
It it possible to check them manually by adding their path and file name
when executing the `named.checkconf` utility.

#### Sending signals to `named` {#namedsigs}

kill: It is possible to send signals to the `named` process to control
its behaviour. A full list of signals can be found in the `named`
manpage. One example is the bindSIGHUP `SIGHUP` signal, that causes
`named` to reload `named.conf` and the database files.

Signals are sent to named with the kill command, e.g.,

        kill -HUP 217
                

This sends a `SIGHUP` signal to a `named` process with process id `217`,
which triggers a reload.

#### Controlling `named` with a start/stop script {#namedstartstop}

Most distributions will come with a start/stop script that allows you to
bindstart bindstop bindreload start, stop or control `named` manually,
e.g., `/etc/init.d/bind` in Debian or `/etc/init.d/named` in Red Hat.

**Note**
Red Hat (based) systems have the `service` command which can be used
instead. `service` uses the same set of parameters, so you might, for
example, say:

        # service named reload
                    

[Table below](#etcInit.dBindArgs) below lists parameters which a
current version of `/etc/init.d/bind` accepts.

|Parameter {#etcInit.dBindArgs}|Description|
|---|---|
|`start`|starts `named`|
|`stop`|stops `named`|
|`reload`|reloads configuration|
|`force-reload`|same as `restart`|

  : `/etc/init.d/bind` parameters

## dnsmasq {#alternatedns}

`dnsmasq` is both a lightweight DNS forwarder and DHCP server. `dnsmasq`
supports static and dynamic DHCP leases and supports BOOTP/TFTP/PXE
network boot protocols.

        $ apt-cache search dnsmasq
        dnsmasq - Small caching DNS proxy and DHCP/TFTP server
        dnsmasq-base - Small caching DNS proxy and DHCP/TFTP server
        dnsmasq-utils - Utilities for manipulating DHCP leases
                
##   djbdns

`djbdns` - Daniel J. Bernstein DNS - was build due to frustrations with
repeated BIND security holes. Besides holding a DNS cache, DNS server
and DNS client `djbdns` also includes several DNS debugging tools. The
source code was released into the public domain in 2007. There have been
several forks, one of which is `dbndns`, the fork of the Debian Project.

##   PowerDNS

PowerDNS is a Dutch supplier of DNS software and services. The PowerDNS
software is open source (GPL), and comes packaged with many
distributions as `pdns`, `powerdns-server` or `pdns-server`. The system
allows multiple backends to allow access to DNS configuration data,
including a simple backend that accepts BIND style files.

        $ apt-cache search pdns
        pdns-backend-geo - geo backend for PowerDNS
        pdns-backend-ldap - LDAP backend for PowerDNS
        pdns-backend-lua - lua backend for PowerDNS
        pdns-backend-mysql - generic MySQL backend for PowerDNS
        pdns-backend-pgsql - generic PostgreSQL backend for PowerDNS
        pdns-backend-pipe - pipe/coprocess backend for PowerDNS
        pdns-backend-sqlite - sqlite backend for PowerDNS
        pdns-backend-sqlite3 - sqlite backend for PowerDNS
        pdns-server - extremely powerful and versatile nameserver
        pdns-server-dbg - debugging symbols for PowerDNS
        pdns-recursor - PowerDNS recursor
        pdns-recursor-dbg - debugging symbols for PowerDNS recursor
        pdnsd - Proxy DNS Server
                    

##  The `dig` and `host` utilities

The Internet Systems Consortium (ICS) has deprecated `nslookup` in
favor of `host` and `dig`. However, `nslookup` is still widely used due
to longevity of older Unix releases. It remains part of most Linux
distributions too.

Both `dig` and `host` commands can be used to query nameservers,
it's a matter of preference which one to use for which occasion. `dig`
has far more options and provides a more elaborate output by default.
The `help` for both commands should give some insights in the
differences:

        $ host
        Usage: host [-aCdlriTwv] [-c class] [-N ndots] [-t type] [-W time]
                    [-R number] [-m flag] hostname [server]
               -a is equivalent to -v -t ANY
               -c specifies query class for non-IN data
               -C compares SOA records on authoritative nameservers
               -d is equivalent to -v
               -l lists all hosts in a domain, using AXFR
               -i IP6.INT reverse lookups
               -N changes the number of dots allowed before root lookup is done
               -r disables recursive processing
               -R specifies number of retries for UDP packets
               -s a SERVFAIL response should stop query
               -t specifies the query type
               -T enables TCP/IP mode
               -v enables verbose output
               -w specifies to wait forever for a reply
               -W specifies how long to wait for a reply
               -4 use IPv4 query transport only
               -6 use IPv6 query transport only
               -m set memory debugging flag (trace|record|usage)
                

        $ dig -h
        Usage:  dig [@global-server] [domain] [q-type] [q-class] {q-opt}
                    {global-d-opt} host [@local-server] {local-d-opt}
                    [ host [@local-server] {local-d-opt} [...]]
        Where:  domain    is in the Domain Name System
                q-class  is one of (in,hs,ch,...) [default: in]
                q-type   is one of (a,any,mx,ns,soa,hinfo,axfr,txt,...) [default:a]
                         (Use ixfr=version for type ixfr)
                q-opt    is one of:
                         -x dot-notation     (shortcut for reverse lookups)
                         -i                  (use IP6.INT for IPv6 reverse lookups)
                         -f filename         (batch mode)
                         -b address[#port]   (bind to source address/port)
                         -p port             (specify port number)
                         -q name             (specify query name)
                         -t type             (specify query type)
                         -c class            (specify query class)
                         -k keyfile          (specify tsig key file)
                         -y [hmac:]name:key  (specify named base64 tsig key)
                         -4                  (use IPv4 query transport only)
                         -6                  (use IPv6 query transport only)
                         -m                  (enable memory usage debugging)
                d-opt    is of the form +keyword[=value], where keyword is:
                         +[no]vc             (TCP mode)
                         +[no]tcp            (TCP mode, alternate syntax)
                         +time=###             (Set query timeout) [5]
                         +tries=###            (Set number of UDP attempts) [3]
                         +retry=###            (Set number of UDP retries) [2]
                         +domain=###           (Set default domainname)
                         +bufsize=###          (Set EDNS0 Max UDP packet size)
                         +ndots=###            (Set NDOTS value)
                         +edns=###             (Set EDNS version)
                         +[no]search         (Set whether to use searchlist)
                         +[no]showsearch     (Search with intermediate results)
                         +[no]defname        (Ditto)
                         +[no]recurse        (Recursive mode)
                         +[no]ignore         (Don't revert to TCP for TC responses.)
                         +[no]fail           (Don't try next server on SERVFAIL)
                         +[no]besteffort     (Try to parse even illegal messages)
                         +[no]aaonly         (Set AA flag in query (+[no]aaflag))
                         +[no]adflag         (Set AD flag in query)
                         +[no]cdflag         (Set CD flag in query)
                         +[no]cl             (Control display of class in records)
                         +[no]cmd            (Control display of command line)
                         +[no]comments       (Control display of comment lines)
                         +[no]question       (Control display of question)
                         +[no]answer         (Control display of answer)
                         +[no]authority      (Control display of authority)
                         +[no]additional     (Control display of additional)
                         +[no]stats          (Control display of statistics)
                         +[no]short          (Disable everything except short
                                              form of answer)
                         +[no]ttlid          (Control display of ttls in records)
                         +[no]all            (Set or clear all display flags)
                         +[no]qr             (Print question before sending)
                         +[no]nssearch       (Search all authoritative nameservers)
                         +[no]identify       (ID responders in short answers)
                         +[no]trace          (Trace delegation down from root)
                         +[no]dnssec         (Request DNSSEC records)
                         +[no]nsid           (Request Name Server ID)
                         +[no]sigchase       (Chase DNSSEC signatures)
                         +trusted-key=####    (Trusted Key when chasing DNSSEC sigs)
                         +[no]topdown        (Do DNSSEC validation top down mode)
                         +[no]multiline      (Print records in an expanded format)
                         +[no]onesoa         (AXFR prints only one soa record)
                global d-opts and servers (before host name) affect all queries.
                local d-opts and servers (after host name) affect only that lookup.
                -h                           (print help and exit)
                -v                           (print version and exit)
                

As demonstrated, the `dig` command provides the broader range of
options. Without options though, the provided information is quite
similar:

        $ host zonetransfer.me
        zonetransfer.me has address 217.147.180.162
        zonetransfer.me mail is handled by 20 ASPMX2.GOOGLEMAIL.COM.
        zonetransfer.me mail is handled by 20 ASPMX3.GOOGLEMAIL.COM.
        zonetransfer.me mail is handled by 20 ASPMX4.GOOGLEMAIL.COM.
        zonetransfer.me mail is handled by 20 ASPMX5.GOOGLEMAIL.COM.
        zonetransfer.me mail is handled by 0 ASPMX.L.GOOGLE.COM.
        zonetransfer.me mail is handled by 10 ALT1.ASPMX.L.GOOGLE.COM.
        zonetransfer.me mail is handled by 10 ALT2.ASPMX.L.GOOGLE.COM.
                

        $ dig zonetransfer.me

        ; <<>> DiG 9.8.4-rpz2+rl005.12-P1 <<>> zonetransfer.me
        ;; global options: +cmd
        ;; Got answer:
        ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 31395
        ;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 2, ADDITIONAL: 1

        ;; QUESTION SECTION:
        ;zonetransfer.me.       IN  A

        ;; ANSWER SECTION:
        zonetransfer.me.    7193    IN  A   217.147.180.162

        ;; AUTHORITY SECTION:
        zonetransfer.me.    7193    IN  NS  ns12.zoneedit.com.
        zonetransfer.me.    7193    IN  NS  ns16.zoneedit.com.

        ;; ADDITIONAL SECTION:
        ns12.zoneedit.com.  1077    IN  A   209.62.64.46

        ;; Query time: 6 msec
        ;; SERVER: 213.154.248.156#53(213.154.248.156)
        ;; WHEN: Thu Jun 27 07:30:36 2013
        ;; MSG SIZE  rcvd: 115
                

`$ man dig`

        NAME
               dig - DNS lookup utility

        SYNOPSIS
               dig [@server] [-b address] [-c class] [-f filename] [-k filename] [-m] [-p port#]
                   [-q name] [-t type] [-x addr] [-y [hmac:]name:key] [-4] [-6] [name] [type]
                   [class] [queryopt...]
                

An important option is `-t` to query for example only the MX or NS
records. This option works for `dig` and `host`. (Look at the man pages
of both commands for the explanation of the other options.)

        $ dig sue.nl

        ; <<>> DiG 9.8.3-P1 <<>> sue.nl
        ;; global options: +cmd
        ;; Got answer:
        ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 60605
        ;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 0

        ;; QUESTION SECTION:
        ;sue.nl.            IN  A

        ;; ANSWER SECTION:
        sue.nl.     299 IN  A   213.154.248.202

        ;; Query time: 52 msec
        ;; SERVER: 8.8.8.8#53(8.8.8.8)
        ;; WHEN: Tue Oct 20 09:55:13 2015
        ;; MSG SIZE  rcvd: 41
                

        $ dig -t NS sue.nl

        ; <<>> DiG 9.8.3-P1 <<>> -t NS sue.nl
        ;; global options: +cmd
        ;; Got answer:
        ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 26099
        ;; flags: qr rd ra; QUERY: 1, ANSWER: 3, AUTHORITY: 0, ADDITIONAL: 0

        ;; QUESTION SECTION:
        ;sue.nl.            IN  NS

        ;; ANSWER SECTION:
        sue.nl.     20361   IN  NS  ns1.transip.nl.
        sue.nl.     20361   IN  NS  ns2.transip.eu.
        sue.nl.     20361   IN  NS  ns0.transip.net.

        ;; Query time: 59 msec
        ;; SERVER: 8.8.8.8#53(8.8.8.8)
        ;; WHEN: Tue Oct 20 10:00:24 2015
        ;; MSG SIZE  rcvd: 108
                

        $ dig -t MX sue.nl

        ; <<>> DiG 9.8.3-P1 <<>> -t MX sue.nl
        ;; global options: +cmd
        ;; Got answer:
        ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 36671
        ;; flags: qr rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 0

        ;; QUESTION SECTION:
        ;sue.nl.            IN  MX

        ;; ANSWER SECTION:
        sue.nl.     299 IN  MX  10 mc.sue.nl.
        sue.nl.     299 IN  MX  20 mx1.sue.nl.

        ;; Query time: 61 msec
        ;; SERVER: 8.8.8.8#53(8.8.8.8)
        ;; WHEN: Tue Oct 20 10:02:01 2015
        ;; MSG SIZE  rcvd: 64
