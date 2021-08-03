##  Implementing Squid as a caching proxy (208.3)

Candidates should be able to install and configure a proxy server,
including access policies, authentication and resource usage.

###   Key Knowledge Areas

- Squid 3.x configuration files, terms and utilities

- Access restriction methods

- Client user authentication methods

- Layout and content of ACL in the Squid configuration files

###   Terms and utilities:

-   `squid.conf`

-   `acl`

-   `http_access`

##  Web-caches

A *web-cache*, also known as an *http proxy*, is web-cache http proxy
used to reduce bandwidth demands and often allows for finer-grained
access control. Using a proxy, in the client software the hostname and
port number of a proxy must be specified. When the browser tries to
connect to a web server, the request will be sent to the specified proxy
server but to the user it looks like the request has been sent to the
requested web server directly. The proxy server now makes a connection
to the specified web server, waits for the answer and sends this back to
the client. The proxy works like an interpreter: the client talks and
listens to the proxy and the proxy talks and listens to the web server
the client wants to talk to. A proxy will also use locally cached
versions of web-pages if they have not yet expired and will also
validate client requests.

Additionally, there are *transparent proxies*. Usually this is the
transparent proxy tandem of a regular proxy and a redirecting router. In
these cases, a web request can be intercepted by the proxy,
transparently. In this case there is no need to setup a proxy in the
settings of the client software. As far as the client software knows, it
is talking directly to the target server, whereas it is actually talking
to the proxy.

###   `squid`

`squid` is a high-performance proxy caching server for web clients.
squid `squid` supports more then just HTTP data objects: it supports FTP
and `gopher` objects too. FTP gopher `squid` handles all requests in a
single, non-blocking, I/O-driven process. `squid` keeps meta data and,
especially, hot objects cached in RAM, it caches DNS lookups, supports
non-blocking DNS lookups and implements negative caching of failed
requests. `squid` also supports SSL, extensive access controls and full
request squidSSL logging. By using the lightweight Internet Cache
Protocol, `squid` caches can be arranged in a hierarchy or mesh for
additional bandwidth savings.

`squid` can be used for a number of things, including bandwidth saving,
handling traffic spikes and caching sites that are occasionally
unavailable. `squid` can also be used for load balancing. Essentially,
the first time `squid` receives a request from a browser, it acts as an
intermediary and passes the request on to the server. `squid` then saves
a copy of the object. If no other clients request the same object, no
benefit will be gained. However, if multiple clients request the object
before it expires from the cache, `squid` can speed up transactions and
save bandwidth. If you've ever needed a document from a slow site, say
one located in another country or hosted on a slow connection, or both,
you will notice the benefit of having a document cached. The first
request may be slower than molasses, but the next request for the same
document will be much faster, and the originating server's load will be
lightened.

`squid` consists of a main server program `squid`, a Domain Name System
lookup program `dnsserver`, some optional programs for rewriting
requests and performing authentication, and some management and client
tools. When `squid` starts up, it spawns a configurable number of
`dnsserver` processes, each of which can perform a single, blocking
Domain Name System (DNS) lookup. This reduces the amount of time the
cache waits for DNS lookups.

`squid` is normally obtained in source code format. On most systems a
simple `make install` will suffice. After that, you will also have a set
of configuration files. In most distributions all the squid
configuration files are, by default, kept in the directory
`/usr/local/squid/etc`. However, the location may vary, depending on the
style and habits of your distribution. The Debian packages, for example,
place the configuration files in `/etc`, which is the normal home
directory for `.conf` files. Though there is more than one file in this
directory, only one file is important to most administrators, namely the
`squid.conf` file. There are just about 125 option tags in this file but
only eight options are really needed to get `squid` up and running. The
other options just give you additional flexibility.

`squid` assumes that you wish to use the default value if there is no
occurrence of a tag in the `squid.conf` file. Theoretically, you could
even run `squid` with a zero length configuration file. However, you
will need to change at least one part of the configuration file, i.e.
the default `squid.conf` denies access to all browsers. You will need to
edit the Access Control Lists to allow your clients to use the `squid`
proxy. The most basic way to perform access control is to use the
`http_access` option (see below).

`http_port`

-   This option determines on which port(s) `squid` will listen
    squidhttp\_port for requests. By default this is port `3128`.
    Another commonly used port is port `8080`.

`cache_dir`

-   Used to configure specific storage areas. If you use more than one
    disk squidcache\_dir for cached data, you may need more than one
    mount point (e.g., `/usr/local/squid/cache1` for the first disk,
    `/usr/local/squid/cache2` for the second disk). `squid` allows you
    to have more than one `cache_dir` option in your config file. This
    option can have four parameters:

            cache_dir /usr/local/squid/cache/ 100 16 256 
                                

    The first option determines in which directory the cache should be
    maintained. The next option is a size value in Megabytes where the
    default is 100 Megabytes. `squid` will store up to that amount of
    data in the specified directory. The next two options will set the
    number of subdirectories (first and second tier) to create in this
    directory. `squid` creates a large number of directories and stores
    just a few files in each of them in an attempt to speed up disk
    access (finding the correct entry in a directory with one million
    files in it is not efficient: it's better to split the files up
    into lots of smaller sets of files).

`http_access`; `acl`

-   The basic syntax of the option is
    `http_access allow|deny [!]aclname`. squidhttp\_access If you want
    to provide access to an internal network, and deny access to anyone
    else, your options might look like this:

            acl home src 10.0.0.0/255.0.0.0
            http_access allow home 
                                

    The first line sets up an Access Control List class called "home" of
    an internal network range of ip addresses. The second line allows
    access to that range of ip addresses. Assuming it's the final line
    in the access list, all other clients will be denied. See also the
    section on [acl](#acl).

    ::: {.tip}
    Note that `squid`'s default behavior is to do the *opposite of your
    last access line* if it can't find a matching entry. For example,
    if the last line is set to "allow" access for a certain set of
    network addresses, then `squid` will deny any client that doesn't
    match any of its rules. On the other hand, if the last line is set
    to "deny" access, then `squid` will allow access to any client that
    doesn't match its rules.
    :::

`auth_param`

-   This option is used to specify which program to start up as an
    squidauth\_param [authenticator](#authenticator). You can specify
    the name of the program and any parameters needed.

`redirect_program`; `redirect_children`

-   The `redirect_program` is used to specify which program to start up
    squidredirect\_program as a [redirector](#redirector). The option
    `redirect_children` is used to specify how many processes to start
    up to do redirection.

After you have made changes to your configuration, issue
`squid -k reconfigure` so that `squid` will use squid-k reconfigure the
changes.

####  Redirectors

`squid` can be configured to pass every incoming URL through a
*redirector process* squidredirector that returns either a new URL or a
blank line to indicate no change. A redirector is an external program,
e.g. a script that you wrote yourself. Thus, a redirector program is
*NOT* a standard part of the `squid` package. However, some examples are
provided in the `contrib/` directory of the source distribution. Since
everyone has different needs, it is up to the individual administrators
to write their own implementation.

A redirector allows the administrator to control the web sites his users
can get access to. It can be used in conjunction with transparent
proxies to deny the users of squiddeny access your network access to
certain sites, e.g. porn-sites and the like.

The redirector program must read URLs (one per line) on standard input,
and write rewritten URLs or blank lines on standard output. Also,
`squid` writes additional information after the URL which a redirector
can use to make a decision. The input line consists of four fields:

        URL ip-address/fqdn ident method
                

-   The URL originally requested.

-   The IP address and domain name (if already cached by `squid`) of the
    client making the request.

-   The results of any IDENT / AUTH lookup done for this client, if
    enabled.

-   The HTTP method used in the request, e.g. `GET`.

A parameter that is not known or specified is replaced by a dash.

A sample redirector input line:

        ftp://ftp.gnome.org/pub/GNOME/stable/releases/gnome-1.0.53/README 192.168.12.34/- - GET
                

A sample response:

        ftp://ftp.net.lboro.ac.uk/gnome/stable/releases/gnome-1.0.53/README 192.168.12.34/- - GET
                

It is possible to send an HTTP redirect to the new URL directly to the
client, rather than have `squid` silently fetch the alternative URL. To
do this, the redirector should begin its response with `301:` or `302:`
depending on the type of redirect.

A simple very fast redirector called `squirm` is a good place to start,
it uses the `regex` library to allow pattern matching.

The following Perl script may also be used as a template for writing
your own redirector:

        #!/usr/local/bin/perl
        $|=1;           # Unbuffer output
        while (<>) {
        s@http://fromhost.com@http://tohost.org@;
        print;
        }
                

This Perl script replaces requests to "http://fromhost.com" with
"http://tohost.org".

####  Authenticators

`squid` can make use of authentication. Authentication
squidauthentication can be done on various levels, e.g. network or user.

Browsers are capable to send the user's authentication credentials
using a special "authorization request header". This works as follows.
If `squid` gets a request, given there was an `http_access` rule list
that points to a `proxy_auth` ACL, `squid` looks for an *authorization
header*. If the header is present, `squid` decodes it and extracts a
username and password. If the header is missing, `squid` returns an HTTP
reply with status 407 (Proxy Authentication Required). The user agent
(browser) receives the 407 reply and then prompts the user to enter a
name and password. The name and password are encoded, and sent in the
authorization header for subsequent requests to the proxy.

Authentication is actually performed outside of the main `squid`
process. When `squid` starts, it spawns a number of authentication
subprocesses. These processes read usernames and passwords on `stdin`
and reply with `OK` or `ERR` on `stdout`. This technique allows you to
use a number of different authentication schemes. The current supported
schemes are: *basic*, *digest*, *ntlm* and *negotiate*.

Squid has some basic authentication backends. These include:

-   LDAP: Uses the Lightweight Directory Access Protocol

-   NCSA: Uses a NCSA-style username and password file

-   MSNT: Uses a Windows NT authentication domain

-   PAM: Uses the Unix Pluggable Authentication Modules scheme

-   SMB: Uses a SMB server like Windows NT or Samba

-   getpwam: Uses the old-fashioned Unix password file

-   SASL: Uses SASL libraries (Simple Authentication and Security Layer)

-   mswin\_sspi: Windows native authenticator

-   YP: Uses the NIS database

The *ntlm*, *negotiate* and *digest* authentication schemes provide more
secure authentication methods because passwords are not exchanged over
the wire or air in plain text.

Configuration of each scheme is done via the *auth\_param* director in
the config file. Each scheme has some global and scheme-specific
configuration options. The order in which authentication schemes are
presented to the client is dependent on the order the scheme first
appears in the config file.

Example configuration file with multiple directors:

        #Recommended minimum configuration per scheme:
        #
        #auth_param negotiate program  < uncomment and complete this line to activate>
        #auth_param negotiate children 20 startup=0 idle=1
        #auth_param negotiate keep_alive on
        #
        #auth_param ntlm program < uncomment and complete this line to activate>
        #auth_param ntlm children 20 startup=0 idle=1
        #auth_param ntlm keep_alive on
        #
        #auth_param digest program < uncomment and complete this line>
        #auth_param digest children 20 startup=0 idle=1
        #auth_param digest realm Squid proxy-caching web server
        #auth_param digest nonce_garbage_interval 5 minutes
        #auth_param digest nonce_max_duration 30 minutes
        #auth_param digest nonce_max_count 50
        #
        #auth_param basic program < uncomment and complete this line>
        #auth_param basic children 5 startup=5 idle=1
        #auth_param basic realm Squid proxy-caching web server
        #auth_param basic credentialsttl 2 hours
                

####  Access policies 

Many `squid.conf` options require the use of Access Control Lists
squidsquid.conf (ACLs). Each ACL consists of a name, type and value (a
string or filename). ACLs are often regarded as being the most difficult
part of the `squid` cache configuration, i.e. the layout and concept is
not immediately obvious to most people. Additionally, the use of
external authenticators and the default ACL augment to the confusion.
squidACL

ACLs can be seen as definitions of resources that may or may not gain
access to certain functions in the web-cache. Allowing the use of the
proxy server is one of these functions.

To regulate access to certain functions, you will have to define an ACL
first, and then add a line to deny or allow access to a function of the
cache, thereby using that ACL as a reference. In most cases the feature
to `allow` or `deny` will be `http_access`, which allows or denies a web
browsers access to the web-cache. The same principles apply to the other
options, such as `icp_access` (Internet Cache Protocol).

To determine whether a resource (e.g. a user) has access to the
web-cache, `squid` works its way through the `http_access` list from top
to bottom. It will squidhttp\_access allow squidhttp\_access deny match
the rules, until one is found that matches the user and either denies or
allows access. Thus, if you want to allow access to the proxy only to
those users whose machines fall within a certain IP range you would use
the following:

        acl ourallowedhosts src 192.168.1.0/255.255.255.0
        acl all src 0.0.0.0/0.0.0.0

        http_access allow ourallowedhosts
        http_access deny all
                

If a user from 192.168.1.2 connects using TCP and requests an URL,
`squid` will work it's way through the list of `http_access` lines. It
works through this list from *top to bottom*, stopping after the *first*
match to decide which one they are in. In this case, `squid` will match
on the first `http_access` line. Since the policy that matched is
`allow`, `squid` would proceed to allow the request.

The `src` option on the first line is one of the options you can use to
decide which domain the requesting user is in. You can regulate access
based on the source or destination IP address, domain or domain regular
expression, hours, days, URL, port, protocol, method, username or type
of browser. ACLs may also require user authentication, specify an SNMP
read community string, or set a TCP connection limit.

For example, these lines would keep all internal IP addresses off the
Web except during lunchtime:

        acl allowed_hosts src 192.168.1.0/255.255.255.0
        acl lunchtime MTWHF 12:00-13:00
        http_access allow allowed_hosts lunchtime
                

The `MTWHF` string denotes the proper days of the week, where `M`
specifies Monday, `T` specifies Tuesday and so on. `WHFAS` means
Wednesday until Sunday. For more options have a look at the default
configuration file `squid` installs on your system.

Another example is the blocking of certain sites, based on their domain
names:

        acl adults dstdomain playboy.com sex.com
        acl ourallowedhosts src 192.168.1.0/255.255.255.0
        acl all src 0.0.0.0/0.0.0.0

        http_access deny adults
        http_access allow ourallowedhosts
        http_access deny all
                

These lines prevent access to the web-cache (`http_access`) to users who
request sites listed in the `adults` ACL. If another site is requested,
the next line allows access if the user is in the range as specified by
the ACL `ourallowedhosts`. If the user is not in that range, the third
line will deny access to the web-cache.

To use an [authenticator](#authenticator), you have to tell `squid`
which program it should use to authenticate a user (using the
`authenticate_program` option in the `squid.conf` file). Next you need
to set up an ACL of type `proxy_auth` and add a line to regulate the
access to the web-cache using that `ACL`. Here's an example:

        authenticate_program /sbin/my_auth -f /etc/my_auth.db
        acl name proxy_auth REQUIRED
        http_access allow name
                

The ACL points to the external authenticator `/sbin/my_auth`. If a user
wants access to the webcache (the `http_access` function), you would
expect that (as usual) the request is granted if the ACL `name` is
matched. *HOWEVER, this is not the case!*


####Authenticator Behaviour

Authenticator `allow` rules act as `deny` rules!

If the external authenticator allowed access, the `allow` rule actually
acts as if it were a `deny` rule! *Any following rules are consequently
checked too* until another matching ACL is found. In other words: the
rule "`http_access allow name`" should be read as
"`http_access deny !name`". The exclamation mark signifies a negation,
thus the rule "`http_access deny !name`" means: "deny access to users
*not* matching the 'name' rule".

`squid` always adds a default ACL!

`squid` automatically adds a final rule to the ACL section that
*reverses* the preceding (last) rule: if the last rule was an "`allow`"
rule, a "`deny all`" rule would be added, and vice versa: if the last
rule was a "`deny`" rule, an "`allow all`" rule would be added
automatically.

Both warnings imply that if the example above is implemented as it
stands, the final line "`http_access allow name`" implicitly adds a
final rule "`http_access deny all`". If the external authenticator
grants access, *the access is not granted, but the next rule is checked*
- and that next rule is the default `deny` rule if you do not specify
one yourself! This means that properly authorized people would be
*denied* access. This exceptional behavior of `squid` is often
misunderstood and puzzles many novice `squid` administrators. A common
solution is to add an extra line, like this:

        http_access allow name 
        http_access allow all
                

####  Utilizing memory usage

`squid` uses lots of memory. For performance reasons this makes sense
since it takes much, much longer to read something from disk compared to
reading directly from memory. A small amount of metadata for each cached
object is kept in memory, the so-called StoreEntry. For `squid` version
2 this is 56-bytes on "small" pointer architectures (Intel, Sparc, MIPS,
etc) and 88-bytes on "large" pointer architectures (Alpha). In addition,
there is a 16-byte cache key (MD5 checksum) associated with each
StoreEntry. This means squidStoreEntry there are 72 or 104 bytes of
metadata in memory for every object in your cache. A cache with
1,000,000 objects therefore requires 72 MB of memory for metadata only.

In practice, `squid` requires much more than that. Other uses of memory
by `squid` include:

-   Disk buffers for reading and writing

-   Network I/O buffers

-   IP Cache contents

-   FQDN Cache contents

-   Netdb ICMP measurement database

-   Per-request state information, including full request and reply
    headers

-   Miscellaneous statistics collection

-   *Hot objects* which are kept entirely in memory

You can use a number of parameters in `squid.conf` to determine
`squid`'s memory utilization:

-   The `cache_mem` parameter specifies how much memory to use for
    caching squidcache\_mem *hot* (very popular) requests. `squid`'s
    actual memory usage depends strongly on your disk space (cache
    space) and your incoming request load. Reducing `cache_mem` will
    *usually* also reduce `squid`'s process size, but not necessarily.

-   The `maximum_object_size` option in `squid.conf`
    squidmaximum\_object\_size specifies the maximum file size that will
    be cached. Objects larger than this size will NOT be saved on disk.
    The value is specified in kilobytes and the default is 4MB. If speed
    is more important than saving bandwidth, you should leave this low.

-   The `minimum_object_size` option specifies that objects smaller than
    this size will squidminimum\_object\_size NOT be saved on disk. The
    value is specified in kilobytes, and the default is 0 KB, which
    means there is no minimum (and everything will be saved to disk).

-   The `cache_swap` option tells `squid` how much squidcache\_swap disk
    space it may use. If you have a large disk cache, you may find that
    you do not have enough memory to run `squid` effectively. If it
    performs badly, consider increasing the amount of RAM or reducing
    the `cache_swap`.
