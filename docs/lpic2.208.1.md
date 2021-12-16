##  Basic Apache Configuration (208.1)

Candidates should be able to install and configure
a web server. This objective includes monitoring the server's load and
performance, restricting client user access, configuring support for
scripting languages as modules and setting up client user
authentication. Also included is configuring server options to restrict
usage of resources. Candidates should be able to configure a web server
to use virtual hosts and customise file access.

###   Key Knowledge Areas

- Apache 2.x including 2.4 configuration files, terms and utilities

- Apache log files configuration and content

- Access restriction methods and files

- mod\_perl and PHP configuration

- Client user authentication modules, files and utilities

- Configuration of maximum requests, minimum and maximim servers and
clients

- Apache 2.x virtual host implementation (with and without dedicated IP
addresses)

- Using redirect statements in Apache's configuration files to customise
file access

###   Terms and utilities

-   `access.log` or `access_log`

-   `error.log` or `error_log`

-   `.htaccess`

-   `httpd.conf`

-   `mod_auth`

-   `mod_authn_file`

-   `mod_access_compat`

-   `htpasswd`

-   `AuthUserFile, AuthGroupFile`

-   `apache2ctl`

-   `httpd`


##  Installing the Apache web-server

Building Apache from source was routinely done when Apache emerged.
Nowadays Apache is available in binary format for most modern (post
2005) Linux distributions. Installing programs from source is already
covered in [206.1](/src/lpic2.206.1/). Therefore, we will concentrate on working with rpm and
apt package managers and tools during this chapter. Do not underestimate
the importance of building Apache from source though. Depending on
requirements and (lack of) availability, it might still be necessary to
compile Apache and Apache modules from source. The Apache binary `httpd`
can be invoked with certain command-line options that affect the
behaviour of the server. But in general Apache is started by other
scripts that serve as a wrapper for `httpd`. These scripts should take
care of passing required flags to `httpd`. The behaviour of the server
is configured by setting various options called `directives`. These
`directives` are declared in configuration files. The location of configuration
files and how they are organized varies. Red Hat and similar distributions have their
configuration files in the `/etc/httpd/conf` directory. Other locations
which are or have been used are `/etc/apache/config`,
`/etc/httpd/config` and `/etc/apache2`.

Depending on your Linux distribution and enabled
repositories, your distribution may come with Apache 2.2 or Apache 2.4
or both. Apache 2.0 does comply to the LPIC-2 Apache 2.x scope due to
its name, but Apache 2.0 is no longer maintained. It is therefore not
recommended to use Apache 2.0. Instead, Apache 2.4 is recommended to be
used by the Apache foundation. As a Linux administrator, you may however
still encounter Apache 2.0 on servers. It is therefore recommended to
familiarize yourself with the configuration differences between the different
versions. The Apache foundation does provide guidence: Via
<https://httpd.apache.org/docs/> upgrade documents can be accessed that
address the necessary steps when upgrading from Apache 2.0 to 2.2, and
from Apache 2.2 to 2.4.

It is important to distinguish between (global) directives that affect
the Apache server processes, and options that affect a specific
component of the Apache server, i.e. an option that only affects a
specific website. The way the configuration files are layed out can
often be a clue as to where which settings are configured. Despite this
presumed obviousness, it is also important not to make assumptions.
Always familiarize yourself with all the configured options. When in
doubt about a specific option, use the documentation or a web search to
find out more and consider whether the option is configured
appropriately.

On many (Red Hat based) distributions the main Apache configuration file
is `httpd.conf`, other (Debian based) distributions favour the
`apache2.conf` filename. Depending on your distribution and installation
it might be one big file or a small generic one with references to other
configuration files via `Include` and/or `IncludeOptional` statements.
The difference between these two directives lies in the optional part.
If Apache is configured to `Include` all `
            *.conf` files from a certain directory, there has to be at
least one file that matches that pattern to include. Otherwise, the
Apache server will fail to start. As an alternative, the
`IncludeOptional` directive can be used to include configuration files
*if* they are present and accessible. The Apache main configuration file
can configure generic settings like servername, listening port(s) and
which IP addresses these ports should be bound to. There may also be a
seperate `ports.conf` configuration file though, so always follow the
`Include` directives and familiarize yourself with the contents of *all*
configuration files. The user and group Apache should run as can also be
configured from the main configuration file. These accounts can be set
to switch after startup. This way, the Apache software can be started as
the root user, but then switch to a dedicated "www", "httpd" or "apache"
user to adhere to the principle of least privilege. There are also
various directives to influence the way Apache serves files from its
document tree. For example there are `Directory` directives that control
whether it is allowed to execute PHP files located in them. The default
configuration file is meant to be self explanatory and contains a lot of
valuable information. In regards to the LPIC-2 exam, you are required to
be familiar with the most common Apache directives. We shall cover some
of those in the section to come. At the time of this writing, Apache 2.4
is the latest stable version and the recommended version to use
according to it's distributor, the Apache Foundation. Where applicable,
this book will try to point out the differences between the various
versions.

An additional method to set options for a subdivision of the document
tree is by means of an `.htaccess` file. For security reasons you will
also need to enable the use of `.htaccess` files in the main
configuration file by setting the `AllowOverride` directive for that
`Directory` context. All options in an `.htaccess` file influence files
in the directory and the ones below it, unless they are overridden by
another `.htaccess` file or directives in the main configuration file.

###   Modularity

Apache has a modular source code architecture. You can custom build a
server with only modules you really want. Many modules are available on
the Internet and you could also write your own.

Modules are compiled objects written in C. If you have questions about
the development of Apache modules, join the Apache-modules mailing list
at <http://httpd.apache.org/lists.html>. Remember to do your homework
first: research past messages and check all the documentation on the
Apache site before posting questions.

Special modules exist for the use of interpreted languages like Perl and
Tcl. They allow Apache to run interpreted scripts natively without
having to reload an interpreter every time a script runs (e.g.
`mod_perl` and `mod_tcl`). These modules include an API to allow for
modules written in an interpreted (scripted) language.

The modular structure of Apache's *source code* should not be confused
with the functionality of *run-time loading* of Apache modules. Run-time
modules are loaded after the core functionality of Apache
has started and are a relatively new feature. In older versions, to use
the functionality of a module, it needed to be compiled in during the
*build* phase. Current implementations of Apache are capable of
*run-time* module loading. The section on [DSO](#DSO) has more details.

####  Run-time loading of modules (DSO) {#DSO}

Most modern Unix derivatives have a mechanism for the on demand linking
and loading of so called Dynamic Shared Objects (DSO). This is a way to
load a Dynamic Shared Objects special program into the address space of
an executable at run-time. This can usually be done in two ways: either
automatically by a system program called `ld.so` when the executable is
started, or manually from within the executing program with the system
calls `dlopen()` and `dlsym()`.

In the latter method the DSO's are usually called shared objects or DSO
files and can be named with an arbitrary extension. By convention the
extension `.so` is used. These files are usually installed in a
program-specific directory. The executable program manually loads the
DSO at run-time into its address space via `dlopen()`.

How to run Apache-SSL as a shareable (DSO) module: First of all, install
the appropriate package:

        packagemanager installcommand modulename
                    

Depending on your distribution, the configuration file(s) might or might
not have been adjusted accordingly. Always check for the existence of a
`LoadModule` line in one of the configuration files:

        LoadModule apache_ssl_module modules/libssl.so
                    

This line might belong in the Apache main configuration file, or one of
the included configuration files. A construction that has been receiving
much support lately, is the use of seperate `modules-available` and
`modules-enabled` directories. These directories are subdirectories
inside the Apache configuration directory. Modules are installed in the
`modules-available` directory, and an `Include` reference is made to a
symbolic link inside the `modules-enabled` directory. This symbolic link
then points back to the module. The `Include` reference might be a
wildcard, including all files from a certain directory.

Another construction is similar, but includes a `conf.modules.d`
directory inside the Apache configuration directory. This file is in
fact a symbolic link, pointing to a directory inside the Apache program
directory somewhere else on the filesystem. An example from a Red Hat
based host:

        Include conf.modules.d/*.conf
                

Again, the implementations you could encounter might differ
significantly from each other. Various aspects such as Linux
distribution used, Apache version installed or whether Apache is
installed from packages or source may be of influence to the way Apache
is implemented. Not to mention the administrator on duty. Important to
remember is that Apache often uses configuration files that may be
nested. But that there will always be one main Apache configuration
file, at the top of the hiearchy.

To see whether your version of Apache supports DSOs, execute the command
`httpd -l` which lists the modules that have been compiled into Apache.
If `mod_so.c` appears in the list of modules then your
Apache server can make use of dyamic modules.

####  APache eXtenSion (APXS) support tool

The APXS is a new support tool from Apache 1.3 and onwards which can be
used to build an Apache module as a DSO *outside the Apache source-tree*.
It knows the platform dependent build parameters for making DSO files and
provides an easy way to run the build commands with them.

###   Monitoring Apache load and performance

An Open Source system that can be used to periodically load-test pages
of web-servers is Cricket. Cricket can be easily set up to
record page-load times, and it has a web-based grapher that will
generate charts to display the data in several formats. It is based on
RRDtool (Round Robin Data Tool) whose ancestor is  MRTG (short MRTG for
"Multi-Router Traffic Grapher"). RRDtool is a package that collects data
in "round robin" databases; each data file is fixed in size so that
running Cricket does not slowly fill up your disks. The database tables
are sized when created and do not grow larger over time. As the data
ages, it is averaged.

####  Enhancing Apache performance

Lack of available RAM may result in memory swapping. A swapping
webserver will perform badly, especially if the disk subsystem is not up
to par. Causing users to hit stop and reload, further increasing the
load. You can use the `MaxClients` setting to limit the amount of
children your server may spawn hence reducing memory footprint. It is
advised to `grep` through the Apache main configuration file for all
directives that start with `Min` or `Max`. These settings define the
MINimal and MAXimum boundaries for each affected setting. The default
values should provide a concense balance between server load at idle on
one hand, and the possibility to handle heavy load on the other. As each
chain is only as strong as it's weakest link, the underlying system
should be adequatetly configured to handle the expected load. The LPIC-2
exam focuses more on the detection of these performance bottlenecks in
chapter [200.1](/src/lpic2.200.1/).

###   Apache `access_log` file

access logs The `access_log` contains a generic overview of
page requests for your web-server. The format of the
access log is highly configurable. The format is specified using a
format string that looks much like a C-style `printf` format string. A
typical configuration for the access log might look like the following:

        LogFormat "%h %l %u %t \"%r\" %>s %b" common
        CustomLog logs/access_log common
                

This defines the nickname *common* and associates it with a particular
log format string. The format as shown is known as the Common Log Format
(CLF). It is a standard format produced bymany web servers and can be
read by most log analysis programs. Log file entries produced in CLF
will look similar to this line:

        127.0.0.1 - bob [10/Oct/2000:13:55:36 -0100] "GET /apache_pb.gif HTTP/1.0" 200 2326
                

CLF contains the following fields:

1.  IP address of the client (%h)

2.  RFC 1413 identity determined by `identd` (%l)

3.  userid of person requesting (%u)

4.  time server finished serving request (%t)

5.  request line of user (%r)

6.  status code servers sent to client (%s)

7.  size of object returned (%b).

###   Apache `error_log` file

The server error log, whose name and location is set by the *ErrorLog*
directive, is a very important log file. This is the file to which
Apache httpd will send diagnostic information and record any errors that
it encounters in processing requests. It is a good place to look when a
problem occurs starting the server or while operating the server. It
will often contain details of what went wrong and how to fix it.

The error log is usually written to a file (typically error\_log on Unix
systems and error.log on Windows). On Unix systems it is also possible
to have the server send errors to syslog or pipe them to a program.

The format of the error log is relatively free-form and descriptive. But
there is certain information that is contained in most error log
entries. For example, here is a typical message:

        [Wed Oct 11 14:32:52 2000] [error] [client 127.0.0.1] client denied by server \
        configuration: /export/home/live/ap/htdocs/test
                

The first item in the log entry is the date and time of the message. The
second item lists the severity of the error being reported. The
`LogLevel` directive is used to control the types of errors that are
sent to the error log by restricting the severity level. The third item
gives the IP address of the client that generated the error. Beyond that
is the message itself, which in this case indicates that the server has
been configured to deny the client access. The server reports the
file-system path (as opposed to the web path) of the requested document.

A very wide variety of different messages can appear in the error log.
Most look similar to the example above. The error log will also contain
debugging output from CGI scripts. Any information written to stderr by
a CGI script will be copied directly to the error log.

It is not possible to customize the error log by adding or removing
information. However, error log entries dealing with particular requests
have corresponding entries in the access log. For example, the above
example entry corresponds to an access log entry with status code 403.
Since it is possible to customize the access log, you can obtain more
information about error conditions using that log file.

During testing, it is often useful to continuously monitor the error log
for any problems. On Unix systems, you can accomplish this using:

        tail -f error_log
                

Knowing how to customize Apache logging may prove to be a very usable
skill. Manually reviewing Apache logs is not for the faint of heart. For
a low-traffic server, this may still be doable. Otherwise, looking for
information by sifting through logs on a busy server that serves
multiple websites, can become a very intense
textfile-manipulating-excercise. This creates a paradox: With little to
no logging, hardly any input is available when looking for the cause of
a problem. With very elaborate logging in place, the information may be
overwhelming. For this reason, Apache logs are often interpreted by
external facilities. The logs are either sent to or read by a system
that has the capability to visualize statistics and recognize patterns.
To ensure the provided logging is adequate, customizing the Apache
logging first may be necessary.

Apache 2.3.6 and later provide the possibility to enable different kinds
of `LogLevel` configurations on a per-module or per-directory basis. The
Apache documentation regarding the `Loglevel` directive is outstanding
and there is not much we could add to that.

###   Restricting client user access

Many systems use either DAC or MAC to control access to objects:

**Discretionary Access Control (DAC)**

-   A system that employs DAC allows users to set object permissions
    themselves. They can change these at their discretion.

**Mandatory Access Controls (MAC)**

-   A system that employs MAC has all its objects (e.g., files) under
    strict control of a system administrator. Users are not allowed to
    set any permissions themselves.

Apache takes a liberal stance and defines discretionary controls to be
controls based on usernames and passwords, and mandatory controls to be
based on static or quasi-static data like the IP address of the
requesting client.

Apache uses modules to authenticate and authorise users. First of all,
the difference between authentication and authorization should be clear.
Authentication is the process in which a user should validate their
identity. This is the *who* part. Authorization is the process of
deciding *who* is allowed to do *what*. Authorization either allows or
denies requests made to the Apache server. Authorization depends on
authentication to make these decisions.

The Apache modules that serve the purpose of autheNtication, follow the
naming convention of `mod_authn_*`. The modules that serve the purpose
of authoriZation, follow the convention of `mod_authz_*`. An exception
to this rule is the `mod_authnz_ldap` module. As you might have guessed,
due to the nature of LDAP this module can aid in both authentication as
well as authorization.

The location of these modules on the filesystem may vary. Most
distributions create a `modules`, `modules.d` or `modules-available`
directory within the Apache configuration directory. This directory can
very well be a symbolic link to a directory somewhere else on the
filesystem. This can be determined by invoking `pwd -P` or `ls -ld` from
within the modules directory as shown by the following example:

        [user@redhatbased /etc/httpd]$ pwd -P
        /usr/lib64/httpd/modules
                

In the example above, the symbolic link `/etc/httpd/modules` provides
for easy reference to the modules from within Apache configuration
files. Apache modules are loaded using the `LoadModule` directive. This
directive expects the path to the module to be relative to the Apache
configuration directory declared by the `ServerRoot` directive.

In general, modules will use some form of database to
store and retrieve credential data. The `mod_authn_file` module for
instance uses text files where `mod_auth_dbm` employs a Unix DBM
database.

Below is a list of some modules that are included as part of the
standard Apache distribution.

`mod_auth_file`

-   (DAC) This is the basis for most Apache security modules; it uses
    ordinary text files for the authentication database.

`mod_access`

-   (MAC) This used to be the only module in the standard Apache
    distribution which applies what Apache defines as
    mandatory controls. It used to allow you to list hosts, domains,
    and/or IP addresses or networks that were permitted or denied access
    to documents. As of Apache 2.4, this module is no longer used.
    Apache 2.4 and newer use an updated authentication and authorization
    model. This new model also comes with new modules, new directives
    and new syntax. The `mod_access` module is still an LPIC-2 exam
    objective, so the pre-2.4 syntax should still be familiar to you. In
    order to aid the migration towards Apache 2.4, a module called
    `mod_access_compat` ships with Apache 2.4. This module serves the
    purpose of still accepting the pre-2.4 syntax on Apache 2.4 servers.
    If you encounter `mod_access` related errors after upgrading to
    Apache 2.4 from a previous version, make sure the Apache 2.4
    configuration loads this compabibility module with a line similar
    to:

        LoadModule mod_access_compat modules/mod_access_compat.so
                                    

`mod_authn_anon`

-   (DAC) This module mimics the behaviour of anonymous FTP. Rather than
    having a Apachemod\_auth\_anon database of valid credentials, it
    recognizes a list of valid usernames (i.e., the way an FTP server
    recognizes "ftp" and "anonymous") and grants access to any of those
    with virtually any password. This module is more useful for logging
    access to resources and keeping robots out than it is for actual
    access control.

`mod_authn_dbm`

-   (DAC) Like `mod_auth_db`, except that credentials are stored in a
    Unix DBM file.

`mod_auth_digest`

-   (DAC) This module implements HTTP Digest Authentication (RFC2617),
    Apachemod\_auth\_digest which used to provide a more secure
    alternative to the `mod_auth_basic` functionality. The explanation
    that follows is nice to know but outdated. The whole point of digest
    authentication was to prevent user credentials to travel via
    unencrypted HTTP over the wire. The hashing algorithms used by the
    digest module are however seriously outdated. Using digest
    authentication instead of basic HTTP authentication does not offer
    as many advantages in terms of security as the use of HTTPS would.
    The following documentation page provides more detail:
    <http://httpd.apache.org/docs/2.4/mod/mod_auth_digest.html>.

    After receiving a request and a user name, the server will challenge
    the client by sending a `nonce`. The contents of a nonce can be any
    (preferably base 64 encoded) string, and the server may use the
    nonce to prevent replay attacks. A nonce might, for example, be
    constructed using an encrypted timestamp within a resolution of a
    minute, i.e. '201611291619'. The timestamp (and maybe other static
    data identifying the requested URI) might be encrypted using a
    private key known only to the server.

    Upon receival of the nonce the client calculates a hash (by default
    a MD5 checksum) of the received nonce, the username, the password,
    the HTTP method, and the requested URI and sends the result back to
    the server. The server will gather the same data from session data
    and password data retrieved from a local digest database. To
    reconstruct the nonce the server will try twice: the first try will
    use the current clocktime, the second try (if necessary) will use
    the current clocktime minus one minute. One of the tries should give
    the exact same hash the client calculated. If so, access to the page
    will be granted. This restricts validity of the challenge to one
    minute and prevents replay attacks.

    Please note that the contents of the nonce can be chosen by the
    server at will. The example provided is one of many possibilities.
    Like with `mod_auth`, the credentials are stored in a text file (the
    digest database). Digest database files are managed with the
    `htdigest` tool. Please refer to the module documentation for more
    details.

`mod_authz_host`

-   The `mod_authz_host` module may be used to `Require` a certain
    source of request towards Apache. The `mod_authz_host` module is
    quite flexible about the arguments provided. Due to the name of the
    module, it may seem logical to provide a hostname. While this
    certainly works, it may not be the preferred choice. Not only does
    this module need to perform a forward DNS lookup on the provided
    hostname to resolve it to a numerical IP, the module is also
    configured to perform a reverse DNS lookup on the resolved numerical
    IP after the forward lookup is performed. Providing a hostname thus
    leads to at least two DNS lookups for every affected webserver
    request. And if the reverse DNS result differs from the provided
    hostname, the request will be denied despite what the configuration
    may allow. To circumvent this requirement regarding forward and
    reverse DNS records matching, the `forward-dns` option may be used
    when providing a hostname. Luckily, `mod_authz_host` not only
    accepts hostnames as an argument. It can also handle (partial) IP
    addresses, both IPv4 and IPv6, and CIDR style notations. There is
    also an argument available called `local`. This will translate to
    the `127.0.0.0/8` or `::1` loopback addresses as well as the
    configured IP addresses of the server. This setting may come in
    handy when restricting connections in regards to the local host.
    Because of the liberal way that IP addresses are interpreted, it is
    recommended to be as explicit as possible when using this module.
    For instance, all of the following is regarded as valid input and
    will be interpreted by the rules that apply:

         Require host: sue.nl
         Require ip: 10.6.6
         Require ip: 172
         Require ip: 10.9.9.9/32
         Require forward-dns: cloudhost.sue.nl
         Require local
                                    

One of the noteworthy differences between Apache 2.2 and 2.4 lies in the
directives used for authorization. The authorization functionality is
provided by Apache `mod_authz_*` modules. Where previous versions of
Apache used the `Order`, `Allow from `, `Deny from ` and `Satisfy`
directives, Apache 2.4 uses new directives called `all`, `env`, `host`
and `ip`. These new directives have a significant impact on the syntax
of configuration files. In order to aid the transition towards Apache
2.4, the `mod_access_compat` module can still interpret the previously
used authorization directives. This module has to be explicitly enabled
though. In doing so, backwards compatibility towards previous
authorization configuration directives is maintained. The current
authorization directives provide the possibility of a more granular
configuration in regards to who is authorized to do what. This added
granularity mostly comes from the availability of the `Require`
directive. This directive could already be used before Apache 2.4 for
authentication purposes. Since Apache 2.4 though, this directive can
also be interpreted by the authorization modules.

The following example puts the old en new syntax in comparison, while
providing the same functionality.

First, the pre-2.4 style:

        <Directory /lpic2bookdev>
        Order deny,allow
        Deny from all
        allow from 10.6.6.0/24
        Require group employees
        Satisfy any
        </Directory>
                

And now the same codeblock, but using the Apache 2.4 style syntax:

        <Directory /lpic2bookdev>
        <RequireAny>
        Require ip 10.6.6.0/24
        Require group employees
        </RequireAny>
        </Directory>
                

The benefit of the new syntax is all about efficiency. By accomplishing
the same functionality with fewer lines, the processing of those lines
will be handled more effectively by both humans and computers. The
computers benefit from spending less processing cycles while
accomplishing the same result. Humans benefit from a short configuration
section. Long configurations are more prone to contain errors that may
be overlooked. By creating sections within configuration files using the
`RequireAll`, `RequireAny`, and `RequireNone` directives, these
configurations can contain granular rules while at the same time
preserving their readability.

Another 2.4 change that is worth mentioning, has to do with the LPIC-2
exam objective regarding the `mod_auth` module. Starting with Apache
2.1, the functionality of the `mod_auth` module has been superseeded by
more specific modules. One of these modules, `
            mod_authn_file` now provides the functionality that was
previously offered by `mod_auth`. `mod_authn_file` allows for the use of
a file that holds usernames and password as part of the authorization
process. This file can be created and the contents may be maintained by
the `htpasswd` utility. When using `mod_auth_digest` instead of
`mod_auth_basic`, the `
            htdigest` utility should be used instead. This book will
focus on the `mod_auth_basic` option. The `htpasswd -c` option will
create a file with the provided argument as a filename during creation
of a username and password pair. `
            htpasswd` allows for the creation of crypt, MD5 or SHA1
password algorithms. As of Apache 2.4.4, it is also possible to use
bcrypt as the password encryption algorithm. Plaintext passwords can
also be generated using the `htpasswd -p` option, but will only work if
Apache 2.4 is hosted on Netware and MS Windows platforms. The crypt
algorithm used to be the `
            htpasswd` default algorithm up to Apache version 2.2.17, but
is considered insecure. Crypt will limit the provided password to the
first eight characters. Every part of the password string from the ninth
character on will be neglected. Crypt password strings are subject to
fast brute force cracking and therefore pose a considerable security
risk. The use of the crypt algorithm should be avoided whenever
possible. Instead, the bcrypt algorithm should be considered when
available. On a system with Apache 2.4.4 or later, the following syntax
can be used to create a new password file `htpasswdfile
            `, supply it with the user "bob" and set the password for
the user account using the bcrypt algorithm:

        htpasswd -cB /path/outside/document/root/htpasswdfile bob
                

The system will ask for the new password twice. To update this file
anytime later by adding the user "alice", the `-c` option can be ommited
to prevent the file from being rewritten:

        htpasswd -B /path/outside/document/root/htpasswdfile alice
                

Using the brypt algorithm with `htpasswd` also enables the use of the
`-C` option. Using this option, the computing time used to calculate the
password hash may be influenced. By default, the system uses a setting
of 5. A value between 4 and 31 may be provided. Depending on the
available resources, a value up to 18 should be acceptable to generate
whilst increasing security. To add the user eve to the existing
`htpasswdfile` while increasing the computing time to a value of 18, the
following syntax may be used:

        htpasswd -B -C18 /path/outside/document/root/htpasswdfile eve
                

In the examples above, it is suggested that the password file is created
outside of the webserver document tree. Otherwise, it could be possible
for clients to download the password file.

To use the generated password file for authentication purposes, Apache
has to be aware of the `htpasswdfile
            ` file. This can be accomplished by defining the
`AuthUserFile` directive. This directive may be defined in either the
Apache configuration files, or in a seperate `.htaccess
            ` file. That `.htaccess` file should be located inside the
directory of the document root it should represent. The Apache config
responsible for that document root should have the `AllowOverride`
directive specified. This way Apache will override directives from its
configuration for directories that have `.htaccess` documents in them.
The syntax for the `.htaccess` documents is the same as for Apache
configuration files. A code block to use for user authentication could
look as follows:

        <Directory /web/document/root>
        AuthName "Authentication Required"
        AuthType Basic
        AuthUserFile /path/outside/document/root/htpasswdfile
        Require valid-user
        Documentroot /web/document/root
        </Directory>
                

Consult the contents of your Apache modules directory for the presence
of mod\_auth\* files. There are multiple authentication and
authorization modules available. Each has its own purpose, and some
depend on each other. Each module adds functionality within Apache. This
functionality can be addressed by using specific module-specific
directives. Refer to the Apache documentation website
<https://httpd.apache.org/docs/2.4/mod/> for detailed usage options
regarding the modules available for Apache 2.4.

Configuring authentication modules

ConfiguringApache Authentication Modules Apache security modules are
configured by configuration directives. These are read from either the
centralized configuration files (mostly found under or in the `/etc/`
directory) or from decentralized `.htaccess` files. The latter are
mostly used to restrict access to directories and are placed in the top
level directory of the tree they help to protect. For example,
authentication Apache.htaccess modules will read the location of their
databases using the ApacheAuthUserFile ApacheAuthDBMGroupFile
`AuthUserFile` or `AuthDBMGroupFile` directives.

**Centralized configuration.**

This is an example of a configuration as it might occur in a centralized
configuration file: ApacheAuthType ApacheRequire valid-user

        <Directory /home/johnson/public_html>
        <Files foo.bar>
        AuthName "Foo for Thought"
        AuthType Basic
        AuthUserFile /home/johnson/foo.htpasswd
        Require valid-user
        </Files>
        </Directory>
                    

The resource being protected is "any file named foo.bar" in the
`/home/johnson/public_html` directory *or any underlying subdirectory*.
Likewise, the file specifies whom are authorized to access `foo.bar`:
any user that has credentials in the `/home/johnson/foo.htpasswd` file.

**Decentralized configuration.**

The alternate approach is to place a `.htaccess` file in the top level
directory of any document tree that needs access protection. Note that
you must set the directive `AllowOverride` ApacheAllowOverride in the
*central* configuration to enable this.

The first section of `.htaccess` determines which authentication type
should be used. It can contain the name of the password or *group file*
to be used, e.g.:

        AuthUserFile {path to passwd file}
        AuthGroupFile {path to group file}
        AuthName {title for dialog box}
        AuthType Basic
                

The second section of `.htaccess` ensures that only user `{username}`
can access (GET) the current directory:

        <Limit GET>
        require user {username} 
        </Limit>
                

The `Limit` section can contain other directives to ApacheLimit restrict
access to certain IP addresses or to a group of users.

The following would permit any client on the local network (IP addresses
10.\*.\*.\*) to access the `foo.html` page and require a username and
password for anyone else:

        <Files foo.html>
        Order Deny,Allow
        Deny from All
        Allow from 10.0.0.0/8
        AuthName "Insiders Only"
        AuthType Basic
        AuthUserFile /usr/local/web/apache/.htpasswd-foo
        Require valid-user
        Satisfy Any
        </Files>
                

####  User files

The `mod_auth` module uses plain text files that contain lists of valid
users. The `htpasswd` Apachehtpasswd command can be used to create and
update these files. The resulting files are plain text files, which can
be read by any editor. They contain entries of the form
"username:password", where the password is encrypted. Additional fields
are allowed, but ignored by the software.

`htpasswd` encrypts passwords using either a version of MD5 modified for
Apache or the older `crypt()` routine. You can mix and match.

        SYNOPSIS
        htpasswd [ -c ] passwdfile username
                

Here are two examples of using `htpasswd` for creating an Apache
password file. The first is for creating a new password file while
adding a user, the second is for changing the password for an existing
user.

        $ htpasswd -c /home/joe/public/.htpasswd joe
        $ htpasswd /home/joe/public/.htpasswd stephan
                

**Note**
Using the `-c` option, the specified password file will be overwritten
if it already exists!

####  Group files

Apache can work with *group files*. Group files contain group names
followed by the names of the people in the group. By authorizing a
group, all users in that group have access. Group files are known as
`.htgroup` files and by convention bear that name - though you can use
any name you want. Group files can be located anywhere in the directory
tree but are normally placed in the toplevel directory of the tree they
help to protect. To allow the use of group files you will need to
include some directives in the Apache main configuration file. This will
normally be inside the proper `Directory` definition. Where the
`AuthUserFile` may specify either an absolute or relative path, the
`AuthGroupFile` directive will always treat the provided argument as
relative to the `ServerRoot`. The `AuthGroupFile` file functions as an
addition to the `AuthUserFile`. The file should contain a group on each
line, followed by a colon. An example:

ApacheAuthGroupFile Apache main configuration file:

        ...
        AuthType Basic
        AuthUserFile /var/www/.htpasswd
        AuthGroupFile /var/www/.htgroup
        Require group Management
        ...
            

The associated `.htgroup` file might have the following syntax:

        Management: bob alice
        Accounting: joe
            

Now the accounts "bob" and "alice" would have access to the resource but
account "joe" would not due to the "Require group Management" statement
in the main configuration file because "joe" is not a member of the
required "Management" group. For this to work the users specified in the
`.htgroup` file must have an entry in the `.htpasswd` file as well.

**Note**
A username can be in more than one group entry. This simply means that
the user is a member of both groups.

To use a DBM database (as used by `mod_auth_db`) you may use
`dbmmanage`. For other types of user files/databases, please consult the
documentation that comes with the chosen module.

**Note**
Make sure the various files are readable by the webserver.

Configuring `mod_perl`

`mod_perl` is another module for Apache, which loads the Perl
interpreter into your Apache webserver, reducing spawning of child
processes and hence memory footprint and need for processor power.
Another benefit is code-caching: modules and scripts are loaded and
compiled only once, and will be served from the cache for the rest of
the webserver's life.

ConfiguringApache mod\_perl Using `mod_perl` allows inclusion of Perl
statements into your webpages, which will be executed dynamically if the
page is requested. A very basic page might look like this:

        print "Content-type: text/plain\r\n\r\n";
        print "Hello, you perly thing!\n";
                

`mod_perl` also allows you to write new modules in Perl. You have full
access to the inner workings of the web server and can intervene at any
stage of request-processing. This allows for customized processing of
(to name just a few of the phases) `URI->filename` translation,
authentication, response generation and logging. There is very little
run-time overhead.

The standard Common Gateway Interface (CGI) within Apache can be
replaced entirely with Perl code that handles the response generation
phase of request processing. `mod_perl` includes two general purpose
modules for this purpose. The first is `Apache::Registry`, which can
transparently run well-written existing perl CGI scripts. If you have
badly written scripts, you should rewrite them. If you lack resources,
you may choose to use the second module `Apache::PerlRun` instead
because it doesn't use caching and is far more permissive then
`Apache::Registry`.

You can configure your `httpd` server and handlers in Perl using
`PerlSetVar`, and `<Perl>` ApachePerlSetVar sections. You can also
define your own configuration directives, to be read by your own
modules.

There are many ways to install `mod_perl`, e.g. as a [DSO](#DSO), either
using [APXS](#APXS) or not, from source or from RPM's. Most of the
possible scenarios can be found in the Mod\_perl Guide
[???](#perlref01).

###   Building Apache from source code

For building Apache from source code you should have downloaded the
Apache source code, the source code for `mod_perl` and have unpacked
these in the same directory. You'll need a recent version of
`perl` installed on your system. To build the module, in most cases,
these commands will suffice:

        $ cd ${the-name-of-the-directory-with-the-sources-for-the-module}
        $ perl Makefile.PL APACHE_SRC=../apache_x.x.x/src \
        DO_HTTPD=1 USE_APACI=1 EVERYTHING=1
        $ make && make test && make install
                    

After building the module, you should also build the Apache server. This
can be done using the following commands:

        $ cd ${the-name-of-the-directory-with-the-sources-for-Apache}
        $ make install
                    

All that's left then is to add a few configuration lines to
`httpd.conf` (the Apache configuration file) and start the server. Which
lines you should add depends on the specific type of installation, but
usually a few `LoadModule` and `AddModule` lines suffice.

As an example, these are the lines you would need to add to `httpd.conf`
to use `mod_perl` as a [DSO](#DSO):

        LoadModule perl_module modules/libperl.so
        AddModule mod_perl.c
        PerlModule Apache::Registry 

        Alias /perl/ /home/httpd/perl/ 
        <Location /perl>
        SetHandler perl-script 
        PerlHandler Apache::Registry 
        Options +ExecCGI
        PerlSendHeader On 
        </Location>
                    

The first two lines will add the `mod_perl` module when Apache starts.
During startup, the `PerlModule` directive ensures that the named Perl
module is read in too. This usually is a Perl package file ending in
`.pm`. The `Alias` keyword reroutes requests for URIs in the form
`http://www.example.com/perl/file.pl` to the directory
`/home/httpd/perl`. Next, we define settings for that location. By
setting the `SetHandler`, all requests for a Perl file in the directory
`/home/httpd/perl` now will be redirected to the perl-script handler,
which is part of the `Apache::Registry` module. The next line simply
allows execution of CGI scripts in the specified location instead of
displaying this file. Any URI of the form
`http://www.example.com/perl/file.pl` will now be compiled once and
cached in memory. The memory image will be refreshed by recompiling the
Perl routine whenever its source is updated on disk. Setting
`PerlSendHeader` to on tells the server to send an HTTP headers to the
browser on every script invocation but most of the time it's better
either to use the `$r->send_http_header` method using the Apache Perl
API or to use the `$q->header` method from the `CGI.pm` module.

Configuring `mod_php` support

PHP is a server-side, cross-platform, HTML embedded scripting language.
ConfiguringApache mod\_php PHP PHP started as a quick Perl hack written
by Rasmus Lerdorf in late 1994. Later he rewrote his code in C and hence
the \"Personal Home Page/Forms Interpreter\" (PHP/FI) was born. Over the
next two to three years, it evolved into PHP/FI 2.0. Zeev Suraski and
Andi Gutmans wrote a new parser in the summer of 1997, which led to the
introduction of PHP 3.0. PHP 3.0 defined the syntax and semantics used
in both versions 3 and 4. PHP became the de facto programming language
for millions of web developers. Still another version of the (Zend)
parser and much better support for object oriented programming led to
the introduction of version 5.0 in july 2004. Several subversions
followed and also version 6 was started to include native Unicode
support. However this version was abandoned. For the year 2015 the start
for version 7.0 was planned.

PHP can be called from the CGI interface, but the common approach is to
configure PHP in the Apache web server as a (dynamic) [DSO](#DSO)
module. To do this, you can either use pre-built modules extracted from
RPM's or roll your own from the source code. You need to configure
the `make` process first. To tell `configure` to build the module as a
[DSO](#DSO), you need to tell it to use [APXS](#APXS):

        ./configure -with-apxs
                

.. or, in case you want to specify the location for the `apxs` binary:

        ./configure -with-apxs={path-to-apxs}/apxs
                

Next, you can compile PHP by running the `make` command. Once all the
source files are successfully compiled, install PHP by using the
`make install` command.

Before Apache can use PHP, it has to know about the PHP module and when
to use it. The `apxs` program took care of telling Apache about the PHP
module, so all that is left to do is tell Apache about `.php` files.
File types are controlled in the `httpd.conf` file, and it usually
includes lines about PHP that are commented out. You may want to search
for these lines and uncomment them:

        Addtype application/x-httpd-php .php 
                

Then restart Apache by issuing the `apachectl restart` command. The
`apachectl` command is another way of passing commands to the Apache
server instead of using `/etc/init.d/httpd`. Consult the `apachectl(8)`
manpage for more information.

To test whether it actually works, create the following page:

        <HTML>
        <HEAD><TITLE>PHP Test </TITLE></HEAD>
        <BODY>
        <?php phpinfo( ) ?>
        </BODY>
        </HTML>
                

Save the file as `test.php` in Apache's `htdocs` directory and aim your
browser at `http://localhost/test.php`. A page should appear with the
PHP logo and additional information about your PHP configuration. Notice
that PHP commands are contained by `<?` and `?>` tags.

####  The httpd binary {#apachehttpd}

The `httpd` binary is the actual HTTP server component of Apache. 
During normal operation, it is recommended to use the `apachectl` or 
`apache2ctl` command to controlthe httpd daemon. On some distributions
the `httpd` binary is named `apache2`.

Apache used to be a daemon that forked child-processes only when needed.
To allow better response times, nowadays Apache can also be run in
pre-forked mode. This means that the server will spawn a number of
child-processes in advance, ready to serve any communication requests.
On most distributions the pre-forked mode is run by default.

###   Configuring Apache server options {#apacheoptions}

The `httpd.conf` file contains a number of sections
that allow you to configure the behavior of the Apache server. A number
of keywords/sections are listed below.

`MaxKeepAliveRequests`

-   The maximum number of requests to allow during a persistent
    connection. Set to 0 to allow an unlimited amount.

`StartServers`

-   The number of servers to start initially.

`MinSpareServers`; `MaxSpareServers`

-   Used for server-pool size regulation. Rather than making you guess how
    many server processes you need, Apache dynamically adapts to the load it
    sees. That is, it tries to maintain enough server processes to
    handle the current load, plus a few spare servers to handle
    transient load spikes (e.g., multiple simultaneous requests from a
    single browser). It does this by periodically checking how many
    servers are waiting for a request. If there are fewer than
    `MinSpareServers`, it creates a new spare. If there are more than
    `MaxSpareServers`, the superfluous spares are killed.

`MaxClients`

-   Limit on total number of servers running, i.e., limit on the number
    of clients that can simultaneously connect. If this
    limit is ever reached, clients will be *locked out*, so it should
    *not be set too low*. It is intended mainly as a brake to keep a
    runaway server from taking the system with it as it spirals down.

**Note**
In most Red Hat derivates the Apache configuration is split into two
subdirectories. The main configuration file `httpd.conf` is located in
`/etc/httpd/conf`. The configuration of Apache modules is located in
`/etc/httpd/conf.d`. Files in that directories with the suffix `.conf`
are added to the Apache configuration during startup of Apache.

####  Apache Virtual Hosting

*Virtual Hosting* is a technique that provides the capability
to host more than one domain on one *physical* host. There are
two methods to implement virtual hosting:

**Name-based virtual hosting**

With name-based virtual hosting, the HTTP server relies on the client
(e.g. the browser) to report the hostname as part of the HTTP request
headers. By using name-based virtual hosting, one IP address may serve
multiple websites for different web domains. In other words: Name-based
virtual hosts use the website address from the URL to determine the
correct virtual host to serve.

**IP-based virtual hosting**

Using IP-based virtual hosting, each configured web domain is committed
to at least one IP address. Since most host systems can be configured
with multiple IP addresses, one host can serve multiple web domains.
Each web domain is configured to use a specific IP address or range of
IP addresses. In other words: IP-based virtual hosts use the IP address
of the TCP connection to determine the correct virtual host to serve.

#### Name-based virtual hosting

Name-based virtual hosting is a fairly simple technique. You need to
configure  your DNS server to map each domain name to the correct IP
address first. Then, configure the Apache HTTP Server to recognize
the different domain names and serve the appropriate websites.

Name-based virtual hosting eases the demand for scarce IPv4 addresses.
Therefore you could (or should) use name-based virtual hosting unless
there is a specific reason to choose IP-based virtual hosting, see
[IP-based Virtual Hosting](#IPBasedVirtualHosting).

To use name-based virtual hosting, you must designate the IP address
(and possibly port) on the server that will be accepting requests for
the hosts. On Apache 2.x up to 2.4, this is configured using the
`NameVirtualHost` directive. This `NameVirtualHost` directive is
deprectated since Apache 2.4. Each `VirtualHost` also implies a
`NameVirtualHost`, so defining a `VirtualHost` is sufficient from Apache 2.4
on. Any available IP address can be used. There should be a balance
between ease of configuration, use and administration on one hand, and
security on the other. Using a wildcard as the listening IP address
inside a `
                NameVirtualHost` or `VirtualHost` segment will enable
the functionality of that specific configuration on all IP addresses
specified by the `Listen` directive of Apache's main configuration
file. If the main configuration file also uses a wildcard for the
`Listen
                ` option, this will result in the availability of the
Apache HTTPD server on all configured IP addresses of the server. And
therefore, the availability of the previously mentioned functionality on
all of these IP addresses as well. Whether or not this is either
preferable or imposes risk, depends on the circumstances. If the server
is using multiple network interfaces and/or IP addresses, special care
should be taken when configuring services. Every daemon exposing
services to the network could contain code based or configuration based
errors. These errors could be abused by someone with malicious
intentions. By minimizing the so called network footprint of the server,
the available attack surface is also minimized. Whether or not the
additional configuration overhead of preventing wildcards is worth the
effort, will always remain a trade off.

-   `Listen` can be used to specify the IP addresses and ports to which
    an Apache listener should be opened in order to serve the configured
    content.

The `<VirtualHost>` directive is the next step to create for each
different webdomain you would like to serve. The argument to the 
`<VirtualHost>` directive should be the same as the argument to 
the (pre-Apache 2.4) `NameVirtualHost` directive (i.e., an IP address
or `*` for all addresses). Inside each `<VirtualHost>` block you will
need, at minimum, a `ServerName` directive to designate which host is
served and a `DocumentRoot` directive to point out where in the
filesystem the content for that webdomain can be found.

Suppose that both `www.domain.tld` and `www.otherdomain.tld` point to
the IP address `111.22.33.44`. You could then add the following to
`httpd.conf` or equivalent (included) configuration file:

        NameVirtualHost 111.22.33.44

        <VirtualHost 111.22.33.44>
            ServerName www.domain.tld
            DocumentRoot /www/domain
        </VirtualHost>

        <VirtualHost 111.22.33.44>
            ServerName www.otherdomain.tld
            DocumentRoot /www/otherdomain
        </VirtualHost>
                    

The IP address `111.22.44.33` could be replaced by `*` to match all IP
addresses for this server. The implications of using wildcards in this
way have been addressed above.

Many websites should be accessible by more than one name. For instance,
the organization behind `domain.tld` wants to facilitate
`blog.domain.tld`. There are multiple ways to implement this
functionality, but one of them uses the `ServerAlias` directive. The
`ServerAlias` directive is declared inside the \<VirtualHost\> section.

If, for example, you add the following to the first \<VirtualHost\>
block above

        ServerAlias domain.tld *.domain.tld 
                    

then requests for all hosts in the `domain.tld` domain will be served by
the `www.domain.tld` virtual host. The wildcard characters `*` and `?`
can be used to match names.

Of course, you can't just make up names and place them in `ServerName`
or `ServerAlias`. The DNS system must be properly configured
to map those names to the IP address(es) declared in the
`NameVirtualHost` directive.

Finally, you can fine-tune the configuration of the virtual hosts by
placing other directives inside the `<VirtualHost>` containers. Most
directives can be placed in these containers and will then change the
configuration only of the relevant virtual host. Configuration
directives set in the main server context (outside any `<VirtualHost>`
container) will be used only if they are not overridden by the virtual
host settings.

Now when a request arrives, the server will first check if it is
requesting an IP address that matches the `NameVirtualHost`. If it is,
then it will look at each `<VirtualHost>` section with a matching IP
address and try to find one where the `ServerName` or `ServerAlias`
matches the requested hostname. If it finds one, it then uses the
corresponding configuration for that server. If no matching virtual host
is found, then the first listed virtual host that matches the IP address
will be used.

As a consequence, the first listed virtual host is the default virtual
host. The `DocumentRoot` from the main server will never be used when an
IP address matches the `NameVirtualHost` directive. If you would like to
have a special configuration for requests that do not match any
particular virtual host, put that configuration in a `<VirtualHost>`
container and place it before any other `<VirtualHost>` container
specification in the Apache configuration.

#### IP-based virtual hosting

Despite the advantages of name-based virtual hosting, there are some
reasons why you might consider using IP-based virtual hosting instead.
These are niche scenarios though:

-   Some older or exotic web clients are not compatible with name-based
    virtual hosting for HTTP or HTTPS. HTTPS name-based virtual hosting
    is implemented using an extension to the TLS protocol called Server
    Name Indicator (SNI). Most modern browsers on modern operating
    systems should support SNI at the time of this writing.

-   Some operating systems and network equipment devices implement
    bandwidth management techniques that cannot differentiate between
    hosts unless they are on separate IP addresses.

As the term *IP-based* indicates, the server must have a different IP
address for each IP-based virtual host. This can be achieved by
equipping the machine with several physical network connections or by
using virtual interfaces. Virtual interfaces are supported by most
modern operating systems (refer to the system documentation for details
on IP aliasing and the `ifconfig` or `ip` command).

There are two ways of running the Apache HTTP server to support multiple
hosts:

-   By running a separate `httpd` daemon for each hostname;

-   By running a single daemon that supports all the virtual hosts.

Use multiple daemons when:

-   There are security issues, e.g., if you want to maintain strict
    separation between the web-pages for separate customers. In this
    case you would need one daemon per customer, each running with
    different `User`, `Group`, `Listen` and `ServerRoot` settings;

-   You can afford the memory and file descriptor requirements of
    listening to every IP alias on the machine. It is only possible to
    `Listen` to the "wildcard" address, or to specific IP addresses. So,
    if you need to restrict one webdomain to a specific IP address, all
    other webdomains need to be configured to use specific IP addresses
    as well.

Use a single daemon when:

-   Sharing of the `httpd` configuration between virtual hosts is
    acceptable;

-   The machine serves a large number of requests, and so the
    performance loss in running separate daemons may be significant.

####  Setting up multiple daemons

Create a separate `httpd` installation for each virtual host. For each
installation, use the `Listen` directive in the configuration file to
select which IP address (or virtual host) that daemon services:

        Listen 123.45.67.89:80
                        

The `Listen` directive may be defined as an IP:PORT combination
seperated by colons as above. Another option is to specify only the port
number. By doing so, the Apache server will default to activating
listeners on all configured IP addresses on the specified port(s):

        Listen 80
        Listen 443
                        

The above `Listen` configuration could also be defined using `0.0.0.0`
as the IP address, again using the colon as a seperator.

Another option of the `Listen` directive enables the exact specification
of the protocol. In the previous example, port 80 and 443 are used. By
default, Port 80 is configured for HTTP and port 443 for HTTPS in
Apache. This configuration could be expanded by another HTTPS website on
port 8443::

        Listen 80
        Listen 443
        Listen 8443 https
                        

When configuring one or more Apache daemons, the `Listen` directive may
be used to specify one or more ports above 1024. This will prevent the
necessity of root privileges for that daemon, if no other ports below
1025 are specified. Unless certain key or certificate files which are
only accessible with root privileges are included in the configuration.
You will read more about this on the next page of this book.

As of Apache 2.4, the `Listen` directive is mandatory and should be
specified. Previous versions of Apache would default to port 80 for HTTP
and 443 for HTTPS on all available IP addresses if no `Listen
                ` directive was specified. Starting with Apache 2.4, the
Apache server will fail to start if no valid `Listen` directive is
specified.

####  Setting up a single daemon

For this case, a single `httpd` will service requests for the main
server and all the virtual hosts. The `VirtualHost` directive in the
configuration file is used to set the values of `ServerAdmin`,
`ServerName`, `DocumentRoot`, `ErrorLog` and `TransferLog` or `CustomLog`
configuration directives to different values for each virtual host.

        <VirtualHost www.sue.nl>
            ServerAdmin webmaster@mail.sue.nl
            DocumentRoot /groups/sue/www
            ServerName www.sue.nl
            ErrorLog /groups/sue/logs/error_log
            TransferLog /groups/sue/logs/access_log
        </VirtualHost>

        <VirtualHost www.unix.nl>
            ServerAdmin webmaster@mail.unix.nl
            DocumentRoot /groups/unix_nl/www
            ServerName www.unix.nl
            ErrorLog /groups/unix_nl/logs/error_log
            TransferLog /groups/unix_nl/logs/access_log
        </VirtualHost>
                        

####  Customizing file access {#redirective}

`Redirect` allows you to tell clients about documents
which used to exist in your server's namespace, but do not anymore.
This allows you to tell the clients where to look for the relocated
document.

        Redirect {old-URI} {new-URI}
                
