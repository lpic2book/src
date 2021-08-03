##  Create and maintain DNS zones (207.2)

Candidates should be able to create a zone file for a forward or reverse
zone and hints for root level servers. This objective includes setting
appropriate values for records, adding hosts in zones and adding zones
to the DNS. A candidate should also be able to delegate zones to another
DNS server.

###   Key Knowledge Areas

-   BIND 9 configuration files, terms and utilities

-   Utilities to request information from the DNS server

-   Layout, content and file location of the BIND zone files

-   Various methods to add a new host in the zone files, including
    reverse zones

###   Terms and Utilities

-   `/var/named/*`

-   zone file syntax

-   resource record formats

-   `named-checkzone`

-   `named-compilezone`

-   `masterfile-format`

-   `dig`

-   `nslookup`

-   `host`

##  Zones and reverse zones

There are *zones* and *reverse zone reverse zone zones*. Each
`named.conf` will contain definitions for both.

Examples of zones are `localhost` (used internally) and `example.com`
(an external example which does not necessarily exist in reality).
Examples of reverse zones are `127.in-addr.arpa` (used internally), and
`240.123.224.in-addr.arpa` (a real-world example).

How zones are related to reverse zones is shown below.

###   The `db.local` file {#db.local-file}

A special domain, `localhost`, will be predefined in most
cases.

Here is the corresponding zone file `/etc/bind/db.local` called from the
example `named.conf` shown earlier in this chapter.

        ;
        ; BIND data file for local loopback interface
        ;
        $TTL    604800
        @   IN  SOA localhost. root.localhost. (
                      1     ; Serial
                 604800     ; Refresh
                  86400     ; Retry
                2419200     ; Expire
                 604800 )   ; Negative Cache TTL
        ;
        @   IN  NS      localhost.
        @   IN  A       127.0.0.1
                    

The `@` contains the name of the zone. It is called bind@ the *current
origin*. A `zone` statement in `named.conf` defines that *current
origin*, as is seen in this part of the named.conf file we saw earlier:

        zone "localhost" {
                type master;
                file "/etc/bind/db.local";
        };
                    

So in this case the zone is called `localhost` and all current origins
in the zone file will become bindlocalhost `localhost`.

Other parts of a zone file will be explained in [Zone
files](#DNSZoneFiles) below.

###   The `db.127` file

To each IP range in a zone file, there is a corresponding binddb.127
*reverse zone* that is described in a *reverse zone file*. Here is the
file `/etc/bind/db.127`:

        ;
        ; BIND reverse data file for local loopback interface
        ;
        $TTL    604800
        @   IN  SOA localhost. root.localhost. (
                      1     ; Serial
                 604800     ; Refresh
                  86400     ; Retry
                2419200     ; Expire
                 604800 )   ; Negative Cache TTL
        ;
        @       IN  NS      localhost.
        1.0.0   IN  PTR     localhost.
                    

This is the calling part from `named.conf`:

        zone "127.in-addr.arpa" {
                type master;
                file "/etc/bind/db.127";
        };
                    

As can be seen, the *current origin* will be `127.in-addr.arpa`, so all
`@`'s in the reverse zone file will be replaced by `127.in-addr.arpa`.

But there is more: all host names that do not end in a dot get the
current origin appended. This is **important**, so I repeat:

> all *host names that do not end in a dot* get the *current origin*
> appended. bindcurrent origin

As an example: `1.0.0` will become `1.0.0.127.in-addr.arpa`.

Normal IP addresses (e.g. 127.0.0.1) do not get the current origin
appended.

Again, details about the reverse zone file will be discussed below.

###   The hints file

The `localhost` and `127.in-addr.arpa` zones are for internal use within
a system.

In the outside world, zones are hierarchically organized. The root zone
(denoted with a dot: `.`) is listed in bindhint a special hints file.
The following zone statement from `named.conf` reads a root zone file
called `/etc/bind/db.root`

        zone "." {
            type hint;
            file "/etc/bind/db.root";
        };
                    

By the way, note the type: `hint`! It is a special type for the root
zone. Nothing else is stored in this file, and it is not updated
dynamically.

Here is a part from the `db.root` file.

        ; formerly NS.INTERNIC.NET
        ;
        .                        3600000  IN  NS    A.ROOT-SERVERS.NET.
        A.ROOT-SERVERS.NET.      3600000      A     198.41.0.4
        ;
        ; formerly NS1.ISI.EDU
        ;
        .                        3600000      NS    B.ROOT-SERVERS.NET.
        B.ROOT-SERVERS.NET.      3600000      A     128.9.0.107          
                    

Note the dot at the left, this is the root zone!

Either your distribution or you personally must keep the root zone file
current. You can look at `ftp.rs.internic.net` for a new version. Or,
you could run something like

        dig @a.root-servers.net . ns > roothints
                    

This will create a new file.

You can also run

        dig @a.root-servers.net . SOA
                    

You can do this periodically to see if the SOA version number (see
below) has changed.

###   Zone files

The root zone knows about all top-level domains directly under it, e.g.
the `edu` and `org` domains as well as the country-specific domains like
`uk` and `nl`.

If the `example.org` domain (used here for illustration purposes) were a
real domain, it would not be handled by the root name servers. Instead,
the nameservers for the `org` domain would know all about it. This is
called *delegation*: the root name servers have *delegated* authority
for zones under `org` to the name servers for the `org` zone. Doing
delegation yourself will be explained later in [Delegating a DNS
zone](#DNSdelegation).

A zone file is read from the `named.conf` file with a zone statement
like

        zone "example.org" IN {
            type master;
            file "/etc/bind/exampleorg.zone";
        };
                    

This is an example zone file for the zone `example.org`.

        $TTL 86400
        @      IN  SOA lion.example.org. dnsmaster.lion.example.org. (
                   2001110700    ; Ser: yyyymmhhee (ee: ser/day start 00)
                        28800    ; Refresh
                         3600    ; Retry
                       604800    ; Expiration
                        86400 )  ; Negative caching
               IN  NS       lion.example.org.
               IN  NS       cat.example.org.

               IN  MX   0   lion.example.org.
               IN  MX  10   cat.example.org.

        lion   IN   A       224.123.240.1
               IN  MX   0   lion.example.org.
               IN  MX  10   cat.example.org.

        doggy  IN   A       224.123.240.2
        cat    IN   A       224.123.240.3

        ; our laptop
        bird   IN   A       224.123.240.4
                    

Let's examine this file in detail.

####  The `$TTL` statement

The `$TTL` is the *default Time To Live* for the zone. When a name
server requests information about this zone, it also gets the TTL. After
the TTL is expired, it should renew the data in the cache.

        $TTL 3h
                        

This sets the default TTL to 3 hours, and

        $TTL 86400
                        

this one to 86400 seconds (same as `1d` (1 day)).

**Note**
Since BIND version 8.2 each zone file should start with a default TTL. A
default value is substituted and a warning generated if the TTL is
omitted. The change is defined in RFC2308.

At the same time, the last SOA time field changed meaning. Now it is the
negative caching value, which is explained below.

####  The `SOA` resource record

The acronym SOA means *Start Of Authority*. It tells the outside world
that this name server is the authoritative name server to query about
this domain. The SOA record should contain the administrator contact
address as well as a time-out setting for slave nameservers. Declaring a
SOA record serves two aspects: first, the parent zone `org` has
*delegated* (granted) the use of the `example.org` domain to us, the
second is that we claim to be the authority over this zone.

The SOA record is mandatory for every DNS zone file, and should be the
first specified Resource Record (RR) of a zone file as well.

Earlier we saw the following `SOA` record:

        @  IN  SOA lion.example.org. dnsmaster.lion.example.org. (
               2001110700    ; Ser: yyyymmhhee (ee: ser/day start 00)
                    28800    ; Refresh
                     3600    ; Retry
                   604800    ; Expiration
                     3600 )  ; Negative caching
                        

Elements of these `SOA` lines are

`@`

-   the current origin, which expands to `example.org` (see the
    named.conf file).

`IN`

-   the Internet data class. From rfc4343: *\"As described in \[STD13\]
    and \[RFC2929\], DNS has an additional axis for data location called
    CLASS. The only CLASS in global use at this time is the \"IN\"
    (Internet) CLASS.\"*

`SOA`

-   start of authority - that's what this section is about.

`lion.example.org.`

-   the name of the machine that has the master (see [Master and slave
    servers](#DNSMasterVsSlave)) name server for this domain.

dnsmaster.lion.example.org.

-   The email address of the person to mail in case of trouble, with the
    commercial at symbol (`@`) normally in the email address replaced by
    a dot. Uncovering the reason for this is left as an exercise for the
    reader (something with current origin \.....?)

`(`*five numbers*`)`

-   -   The first number is the serial number. For a zone definition
        that never changes (e.g., the `localhost` zone) a single `1` is
        enough.

        For zones that do change, however, another format is rather
        common: *yyyymmddee*. That is, 4 digits for the year, two for
        the month, two for the day, plus two digits that start with `00`
        and are incremented every time something is changed. For example
        a serial number of

                2001110701
                                                            

        corresponds to the second (!) change on the 7th of November in
        the year 2001. The next day, the first change will get the
        serial number `2001110800`.

        **Note**
        Each time something is changed in a zone definition, the serial
        number must grow (by at least one). If the serial number does
        not grow, changes in the zone will go unnoticed.
        :::

    -   The second number is the refresh rate. This is how frequently a
        slave server (see below) should check to see whether data has
        been changed.

        Suggested value in rfc1537: `24h`

    -   The third number is the retry value. This is the time a slave
        server must wait before it can retry after a refresh or failure,
        or between retries.

        Suggested value in rfc1537: `2h`

    -   The fourth number is the expiration value. If a slave server
        cannot contact the master server to refresh the information, the
        zone information expires and the slave server will stop serving
        data for this zone.

        Suggested value in rfc1537: `30d`

    -   The fifth number is the negative caching value TTL. Negative
        caching means that a DNS server remembers that it could not
        resolve a specific domain. The number is the time that this
        memory is kept.

        Reasonable value: `1h (3600s)`

####  The `A` resource record

The `A` record is the *address* record. It connects an IP address to a
hostname. An example record is

        lion   IN   A       224.123.240.1
                        

This connects the name `lion.example.org` (remember that the current
origin `example.org` is added to any name that does not end in a dot) to
the IP address `224.123.240.1`.

**Note**
Each `A` record should have a corresponding `PTR` record. This is
described in [Reverse zone files](#DNSReverseZoneFiles).

The A record is used by IPv4, the current version of the IP protocol.
The next generation of the protocol, IPv6, has an `A6` record type. IPv6
is not discussed here.

####  The `CNAME` resource record

A `CNAME` (Canonical Name) record specifies another name for a host with
an A record. BIND 8 used to allow multiple CNAME records, by accepting
an option called `multiple-cnames`. From BIND 9.2 onward though, the
CNAME rules are strictly enforced in compliance to the DNS standards. An
example of a combined `A` and `CNAME` record is

        cat   IN  A     224.123.240.3
        www   IN  CNAME cat.example.org.
                        

This makes `www.example.org` point to `cat.example.org`.

####  The `NS` resource record

Specifies a name server for the zone. For example

        @    IN SOA .....

             IN  NS    lion.example.org.
             IN  NS    cat.example.org.
                        

The first thing that catches the eye is that there is nothing before the
IN tag in the NS lines. In this case, the current origin that was
specified earlier (here with the `SOA`) is still valid as the current
origin.

**Note**
There should be at least two independent name servers for each domain.
Independent means connected to separate networks, separate power lines,
etc. See [Master and slave servers](#DNSMasterVsSlave) below.

####  The `MX` resource record

The MX (Mail Exchanger) record system is used by the mail transfer
system, e.g., the `sendmail` and `postfix` daemons. Multiple MX records
may be provided for each domain. The number after the `MX` tag is the
priority. A priority of 0 is the *highest* priority. The higher the
number, the lower the priority. Priority 0 will be used for the host
where the mail is destined to. If that host is down, another host with a
lower priority (and therefore a higher number) will temporarily store
the mail.

Example entries:

        lion   IN   A       224.123.240.1
               IN  MX   0   lion.example.org.
               IN  MX  10   cat.example.org.
                        

So this example specifies that mail for `lion.example.org` is first sent
to `lion.example.org`. If that host is down, `cat.example.org` is used
instead.

To distribute mail equally among two hosts, give them the same priority.
That is, if another host with priority `10` is added, they will both
receive a share of mail when `lion.example.org` is down.

####  MXing a domain

Mail can be delivered to a host, as was shown in the previous section.
But the Mail Transfer Agent (MTA) and the DNS can be configured in such
a way that a host accepts mail for a domain.

Considering our example, host `lion.example.org` can be configured to
accept mail for `example.org`.

To implement this, place MX records for `example.org` in the
`example.org` zone file, e.g.:

        ; accept mail for the domain too
        example.org.  IN  MX   0   lion.example.org.
        example.org.  IN  MX  10   cat.example.org.
                        

Mail addressed to `example.org` will only be accepted by the MTA on
`lion.example.org` host if the MTA is configured for this.

###   Reverse zone files {#DNSReverseZoneFiles}

Each IP range has a *reverse zone*, that consists of part of the IP
numbers in reverse order, plus `in-addr.arpa`. This system is among
other things used to check whether a host name belongs to a specific
address.

Our `example.org` domain uses the IP range `224.123.240.`*x*. The
corresponding *reverse zone* is called `240.123.224.in-addr.arpa`. In
`named.conf` this could be the corresponding entry:

        zone "240.123.224.in-addr.arpa" IN {
            type master;
            file "/etc/bind/exampleorg.rev";
        };
                    

An example `/etc/bind/exampleorg.rev` (corresponding to the
`example.org` domain we saw earlier) is:

        $TTL 86400
        @      IN  SOA lion.example.org. dnsmaster.lion.example.org. (
                   2001110700    ; Ser: yyyymmhhee (ee: ser/day start 00)
                        28800    ; Refresh
                         3600    ; Retry
                       604800    ; Expiration
                         3600 )  ; Negative caching
               IN  NS       lion.example.org.
               IN  NS       cat.example.org.

        1      IN   PTR     lion.example.org.
        2      IN   PTR     doggy.example.org.
        3      IN   PTR     cat.example.org.
        4      IN   PTR     bird.example.org.
                    

The current origin is `240.123.224.in-addr.arpa`, so the entry for bird
actually is

        4.240.123.224.in-addr.arpa IN PTR bird.example.org.
                    

####  The `PTR` record

The `PTR` record connects the reverse name
(`4.240.123.224.in-addr.arpa`) to the name given by the A record
(`bird.example.org`).

###   IPv6 records

####  The IPv6 address format

IPv6 addresses are 128 bit addresses rather than IPv4's 32 bits. They
are notated as 8 groups of 16-bit values, written in 4 hexadecimal
numbers per part, separated by a colon. For the sake of readability
leading zero's in every part may be omitted, and parts consisting of
zero's only may be completely omitted. The latter may only be done once
per address because multiple occurrences would create an ambiguous
representation.

For example: `2001:0db8:0000:0000:0000:ff00:0042:8329` can be rewritten
to `2001:db8::ff00:42:8329`.

The localhost (loopback) address `0:0:0:0:0:0:0:1` can be reduced to
`::1`

####  The AAAA record

Where the `A` record is used for IPv4, the `AAAA` record is used for
IPv6. It resolves a hostname to an IPv6 address in the same way as an
`A` record does for IPv4.

        lion   IN   AAAA    2001:db8::ff00:42:8329
                        

**Note**
Note: Another format used to resolve IPv6 address records was the A6
record. While supported by the current BIND versions it is considered
\"historic\" by RFC6563

####  The PTR record

For reverse resolution IPv6 address are represented in another format,
with every hexadecimal digit separated by a dot. Our example above
becomes:
`2.0.0.1.0.d.b.8.0.0.0.0.0.0.0.0.0.0.0.0.f.f.0.0.0.0.4.2.8.3.2.9`

The IPv6 PTR record is that address in exact reverse order with the
domain `ip6.arpa` appended. The above address becomes:
`9.2.3.8.2.4.0.0.0.0.f.f.0.0.0.0.0.0.0.0.0.0.0.0.8.b.d.0.1.0.0.2.ip6.arpa`

Part of that domain may be delegated, just as IPv4 addresses. In
`named.conf` this could be the corresponding entry:

        zone "0.0.0.0.0.0.0.0.8.b.d.0.1.0.0.2.ip6.arpa" IN {
            type master;
            file "/etc/bind/exampleorg-ip6.rev";
        };
                        

The corresponding file should look like the following file:

        $TTL 86400
        @      IN  SOA lion.example.org. dnsmaster.lion.example.org. (
                   2001110700    ; Ser: yyyymmhhee (ee: ser/day start 00)
                        28800    ; Refresh
                         3600    ; Retry
                       604800    ; Expiration
                        86400 )  ; Negative caching
               IN  NS       lion.example.org.
               IN  NS       cat.example.org.

        9.2.3.8.2.4.0.0.0.0.f.f.0.0.0.0      IN   PTR     lion.example.org.
                        

As both IPv4 and IPv6 PTR records are in different zones (i.e.
`in-addr.arpa` and `ip6.arpa`) they should be defined in separate zone
files.

##  Master and slave servers

Each zone (except the ones local to the machine, such as `localhost`)
must have at least one *master* name server. It can be supported by one
or more *slave* name servers.

There should be two independent name servers for each zone. Independent
means connected to a different network and other power supplies. If one
power plant or network fails the resolving names from the zone must
still be possible. A good solution for this is one master and one slave
name server at different locations.

Both *master* and *slave* name servers are *authoritative* for the zone
(if the zone was delegated properly, see [Delegating a DNS
zone](#DNSdelegation)). That is, they both give the same answers about
the zone.

The data of a zone originates from a *master* name server for that zone.
The *slave* name server copies the data from the master. *Other* name
servers can contact either a master or a slave to resolve a name.

This implies that the configuration must handle

-   slave name server access control on the master

-   other name server access control on both master and slave name
    servers

###   Configuring a master

A zone definition is defined as *master* by using the

        type master;
                    

statement inside a zone definition. See, for example, this zone
statement (in `named.conf`) that defines the `example.org` master.

        zone "example.org" IN {
        type master;
        file "/etc/bind/exampleorg.zone";
        };
                    

Of course, the `exampleorg.zone` file must be created as discussed
earlier.

There can be multiple independent master name servers for the same zone.

A `notify` statement controls whether or not the master sends DNS NOTIFY
messages upon change of a master zone. The `notify` statement can be put
in a `zone` statement as well as in an `options` statement. If one is
present in both the `zone` and `options` statements, the former takes
precedence. When a slave receives such a NOTIFY request (and supports
it), it initiates a zone transfer to the master immediately to update
the zone data. The default is `notify yes;`. To turn it off (e.g. when a
zone is served by masters only) set `notify
                no;`.

How does the master know which slave servers serve the same zone? It
inspects the `NS` records defined for the zone. In other words: the `NS`
record for a zone should specify all slaves for that zone. Extra slave
servers can be specified with the `also-notify` statement (see the
named.conf(5) manpage).

**Note**
Older versions of BIND used the term *primary* instead of *master*.

###   Configuring a slave

A zone definition is defined as *slave* by using the

        type slave;
                    

statement inside a zone definition, accompanied by the IP address(es) of
the master(s). Here, for example, is the zone statement (in
`named.conf`), which defines a `example.org` slave:

        zone "example.org" IN {
            type slave;
            masters { 224.123.240.1; }; // lion
            file "db.example.org";
        };
                    

The file `db.example.org` is created by the slave name server itself.
The slave has no data for `example.org`. Instead, a slave receives its
data from a master name server and stores it in the specified file.

Note that the filename has no directory component. Hence it will be
written in the BIND working directory given by the `directory` option in
`named.conf`. For instance, `/var/cache/bind` or `/var/named`. The name
server must have write access to the file.

**Note**
Older versions of BIND used the term *secondary* instead of *slave*.

###   A `stub` name server

A stub zone is like a slave zone, except that it replicates only the
`NS` records of a master zone instead of the entire zone. In other
words, the DNS server hosting the stub zone is only a source of
information on the authoritative name servers. This server must have
network access to the remote DNS server in order to copy the
authoritative name server information.

The purpose of stub zones is two fold:

-   *Keep delegated zone information current.* By updating a stub zone
    for one of its child zones regularly, the DNS server that hosts the
    stub zone will maintain a current list of authoritative DNS servers
    for the child zone.

-   *Improve name resolution.* Stub zones make it possible for a DNS
    server to perform name resolution using the stub zone's list of
    name servers, without having to use forwarding or root hints.

Creating subdomains

There are two ways to create a subdomain: inside a zone or as a
delegated zone.

The first is to put a subdomain inside a normal zone file. The subdomain
will not have its own `SOA` and `NS` records. This method is not
recommended - it is harder to maintain and may produce administrative
problems, such as signing a zone.

The other method is to *delegate* the subdomain to a separate zone. This
is described in the next section.

###   Delegating a DNS zone {#DNSdelegation}

A real, independent subdomain can be created by configuring the
subdomain as an independent zone (having its own `SOA` and `NS` records)
and delegating that domain from the parent domain.

A zone will only be *authoritative* if the parent zone has delegated its
authority to the zone. For example, the `example.org` domain was
delegated by the `org` domain.

Likewise, the `example.org` domain could delegate authority to an
independent `scripts.example.org` domain. The latter will be independent
of the former and have its own `SOA` and `NS` records.

Let's look at an example file of the `scripts.example.org` zone:

        $ORIGIN scripts.example.org.
        ctl  IN  A  224.123.240.16
             IN MX   0 ctl
             IN MX  10 lion.example.org.
        www  IN CNAME ctl
        perl IN  A  224.123.240.17
             IN MX   0 perl
             IN MX  10 ctl
             IN MX  20 lion.example.org.
        bash IN  A  224.123.240.18
             IN MX  0 bash
             IN MX  10 ctl
             IN MX  20 lion.example.org.
        sh   IN CNAME bash
                    

Nothing new, just a complete zone file.

But, to get it authoritative, the parent domain, which is `example.org`
in this case, must *delegate* its authority to the `scripts.example.org`
zone. This is the way to delegate in the `example.org` zone file:

        scripts  2d IN NS ctl.scripts.example.org.
                 2d IN NS bash.scripts.example.org.
        ctl.scripts.example.org.  2d IN  A 224.123.240.16
        bash.scripts.example.org. 2d IN  A 224.123.240.18
                    

That's all!

The `NS` records for `scripts` do the actual delegation. The `A` records
*must* be present, otherwise the name servers of `scripts` cannot be
located.

**Note**
It is advised to insert a TTL field (like the `2d` in the example).

Checking zone files for syntax errors

named-checkzone After creating or making changes to a zone file it is a
good idea to check them for syntax errors. This can be done with the
`named-checkzone` command. The way to do this is by entering the domain
name after the command followed by the name of the zone file. See below
for an example.

        # named-checkzone test.com /var/named/test.com.zone
        zone test.com/IN: loaded serial 0
        OK
                    

In this example I didn't put a dot at the end of the domain name but
you can choose to do so. Both ways are correct and will give the same
answer.

As you can see in the example above, the utility gives an \"OK\" as a
response this means the file is clear of any syntax errors. You maybe
also want to consider checking the man page for `named-checkzone` for
additional options.

named-compilezone From version 9.9 of the BIND software secondary server
zone files are by default saved in raw binary format instead of text
format. Reading and checking these files can be a bit more challenging
because of this. Luckily there is the tool `named-compilezone`. This
tool is quite similair to the `named-checkzone` tool but makes it
possible to change raw zone files to text format (and vice versa) so
they are readable by normal human beings.

masterfile-format It is possible to change to change this behaviour and
change the default format back to text format. This can be done by
adding the `masterfile-format` option to the zone statement in the
named.conf files on the secondary name servers that you administer.
Example below shows the correct syntax for this.

        masterfile-format text;
                    

DNS Utilities

dig nslookup Four DNS utilities can help to resolve names and even debug
a DNS zone. They are called `dig`, `host`, `nslookup` and `dnswalk`. The
first three are part of the BIND source distribution.

###   The `dig` program

The `dig` command lets you resolve names in a way that is close to the
setup of a zone file. For instance, you can do

        dig bird.example.org A
                    

This will do a lookup of the `A` record of `bird.example.org`. Part of
the output looks like this:

        ;; ANSWER SECTION:
        bird.example.org. 1D IN A 224.123.240.4

        ;; AUTHORITY SECTION:
        example.org.      1D IN NS  lion.example.org.

        ;; ADDITIONAL SECTION:
        lion.example.org.  1D IN A 224.123.240.1
                    

If `dig` shows a `SOA` record instead of the requested `A` record, then
the domain is ok, but the requested host does not exist.

It is even possible to query another name server instead of the one(s)
specified in `/etc/resolv.conf`:

        dig @cat.example.org bird.example.org A
                    

This will query name server `cat.example.org` for the `A` record of host
`bird`. The name server that was contacted for the query will be listed
in the tail of the output.

The `dig` command can be used to test or debug your reverse zone
definitions. For instance,

        dig 4.240.123.224.in-addr.arpa PTR
                    

will test the reverse entry for the `lion` host. You should expect
something like this:

        ;; ANSWER SECTION:
        4.240.123.224.in-addr.arpa.  1D IN PTR lion.example.org.

        ;; AUTHORITY SECTION:
        240.123.224.in-addr.arpa.  1D IN NS  lion.example.org.

        ;; ADDITIONAL SECTION:
        lion.example.org.      1D IN A       224.123.240.4
                    

If you get something like

        ;; ANSWER SECTION:
        4.240.123.224.in-addr.arpa. 1D IN PTR lion.example.org.240.123.224.in-addr.arpa.
                    

you've made an *error* in your zone file. Given a *current origin* of
`240.123.224.in-addr.arpa.`, consider the line:

        4  IN PTR lion.example.org ; WRONG!
                    

The dot at the end was omitted, so the current origin is appended
automatically. To correct this, add the trailing dot:

        4  IN PTR lion.example.org. ; RIGHT!
                    

**Note**
When specifying a hostname like `bird.example.org` or
`4.240.123.224.in-addr.arpa` to `dig`, a trailing dot may be added.

###   The `host` program

host

The `host` program reports resolver information in a simple format.

When a hostname is specified as a parameter, the corresponding `A`
record will be shown. For example:

        host bird.example.org
                    

will result in output like

        bird.example.org    A    224.123.240.4
                    

The `host` program is especially useful when a hostname is wanted and an
IP address is given. For example:

        host 224.123.240.4
                    

from our example hosts shows output like:

        Name: bird.example.org
        Address: 224.123.240.4
                    

The following command is also possible:

        host 4.240.123.224.in-addr.arpa
                    

resolves the PTR record:

        4.240.123.224.in-addr.arpa PTR bird.example.org
                    

**Note**
As is the case with `dig`, when specifying a hostname like
`bird.example.org` or `4.240.123.224.in-addr.arpa` to `host`, a trailing
dot may be added.

###   The `nslookup` program

The `nslookup` program is yet another way to resolve names. As stated
before the use of `nslookup` is deprecated, and the commands `host` and
`dig` should be used instead. Despite this recommendation, you should
have some knowledge of its usage.

For instance, start the interactive mode by entering `nslookup` and
typing:

        ls -d example.org.
                    

In result, the output will be shown in a zonefile-like format (beginning
shown):

        [lion.example.org]
        $ORIGIN example.org.
        @    1D IN SOA lion postmaster.lion (
                        2001110800   ; serial
                                8H   ; refresh
                                1H   ; retry
                                1W   ; expiry
                                1D ) ; minimum

                            1D IN NS   lion
                            1D IN MX 0 lion
                    

The first line, in square brackets, contains the name of the name server
that sent the answer.

**Note**
The example shown requires a *zone transfer* from the connected name
server. If this name server refuses zone transfers (as will be discussed
in the next section), you will of course not see this output.

A lot of commands can be given to `nslookup` in interactive mode: the
`help` command will present a list.

###   DNSwalk

DNSwalk is a DNS debugger. Use with caution, since it tries to perform
zone transfers while checking DNS databases for consistency and
accuracy. Example:

        $ dnswalk zoneedit.com.
        Checking zoneedit.com.
        Getting zone transfer of zoneedit.com. from ns2.zoneedit.com...done.
        SOA=ns2.zoneedit.com    contact=soacontact.zoneedit.com
        WARN: zoneedit.com A 64.85.73.107: no PTR record
        WARN: golf.zoneedit.com A 69.72.176.186: no PTR record
        WARN: zoneapp1.zoneedit.com A 64.85.73.104: no PTR record
        WARN: dynamic1.zoneedit.com A 64.85.73.40: no PTR record
        WARN: zoneapp2.zoneedit.com A 64.85.73.107: no PTR record
        WARN: ezzi.zoneedit.com A 207.41.71.242: no PTR record
        WARN: dynamic2.zoneedit.com A 64.85.73.40: no PTR record
        WARN: legacyddns.zoneedit.com A 64.85.73.40: no PTR record
        WARN: api2.zoneedit.com A 64.85.73.104: no PTR record
        WARN: wfb.zoneedit.com A 69.72.142.98: no PTR record
        WARN: new.zoneedit.com A 64.85.73.107: no PTR record
        WARN: zebra.zoneedit.com A 69.72.240.114: no PTR record
        WARN: api.zoneedit.com A 64.85.73.40: no PTR record
        WARN: www.zoneedit.com A 64.85.73.107: no PTR record
        WARN: newapi.zoneedit.com A 64.85.73.104: no PTR record
        0 failures, 15 warnings, 0 errors.
                    
