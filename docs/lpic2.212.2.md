##  Managing FTP servers (212.2)

Candidates should be able to configure an FTP server for anonymous
downloads and uploads. This objective includes configuring user access,
and precautions to be taken if anonymous uploads are permitted.

###   Key Knowledge Areas

- Configuration files, tools and utilities for Pure-FTPd and vsftpd

- Awareness of ProFTPd

- Understanding of passive vs. active FTP connections

###   Terms and Utilities

-   `vsftpd.conf`

-   important Pure-FTPd command line options

##  FTP connection modes

FTP is a service that uses two ports for communication. Port 21 is used
for the command port (also known as control port) and port 20 for the
data port. FTP has two modes, *active* and *passive* FTP. These modes
differ in the way connections are initiated. In active mode the client
initates the control connection and the server initiates the data
connection. In passive mode the client initiates both connections.

###   Active mode


In active mode the client starts an FTP session. This is done by
initiating a control connection originating on an unprivileged port
(\>1023) to port 21 on the server. The client sends the server the IP
address and port number on which the client will listen for the data
connection. Usually this port is the next port above the used control
connections port on the client. The server sends an ACK to the clients
command port and *actively* opens a data connection originating on port
20 to the client. The client sends back an ACK on the data connection.

Active mode example:

-   The client opens up a command channel from client port 1050 to
    server port 21.

-   The client sends *PORT 1051* (1050 + 1) to the server and the server
    acknowledges on the command channel.

-   The server opens up a data channel from server port 20 to client
    port 1051.

-   The client acknowledges on the data channel.

###   Passive mode

In situations in which the client is behind a firewall and unable to
accept incoming TCP connections, passive mode may be used. In passive
mode the client starts an FTP session. This is done by initiating a
control connection originating on an unprivileged port (\>1023) to port
21 on the server. In this mode the client sends a PASV command to the
server and receives an IP address and port number in return. The server
replies with *PORT XXXX* where XXXX is the unprivileged port the server
listens for the data connection and *passively* waits for the data
connection. The client opens the data connection from the next port
above the control connections port to the port specified in the `PORT`
reply on the server. The server sends back an ACK to the client on the
data connection.

Passive mode example:

-   Client opens up command channel from client port 1050 to server
    port 21.

-   Client sends *PASV* command to server on command channel.

-   Server sends back (on command channel) *PORT 1234* after starting to
    listen on that port.

-   Client opens up data channel from client 1050 to server port 1234.

-   Server acknowledges on data channel.

##  Enabling connections through a firewall


To enable passive FTP connections when iptables is used, the
"ip\_conntrack\_ftp" module has to be loaded into the firewall and
connections with the state "related" have to be allowed.

###   vsftpd

vsftpd (very secure FTP daemon) is a very popular, versatile, fast and
secure FTP server.

####  Example minimal configuration for anonymous up- and downloads


    # If enabled, vsftpd will run in standalone mode. This means  that
    # vsftpd  must not be run from an inetd of some kind. Instead, the
    # vsftpd executable is run once directly. vsftpd itself will  then
    # take care of listening for and handling incoming connections.
    # Default: NO
    listen=NO

    # Controls whether local logins are permitted or not. If enabled,
    # normal user accounts in /etc/passwd (or wherever your PAM config
    # references) may be used to log in. This must be enable for any
    # non-anonymous login to work, including virtual users.
    # Default: NO
    local_enable=YES

    # This controls whether any FTP commands which change the filesystem
    # are  allowed  or not. These commands are: STOR, DELE, RNFR,
    # RNTO, MKD, RMD, APPE and SITE.
    # Default: NO
    write_enable=YES

    # Controls  whether  anonymous  logins  are  permitted  or not. If
    # enabled, both the usernames ftp and anonymous are recognised  as
    # anonymous logins.
    # Default: YES
    anonymous_enable=YES

    # This option represents a directory  which  vsftpd  will  try  to
    # change  into  after  an  anonymous  login.  Failure  is silently
    # ignored.
    # Default: (none)
    anon_root=/var/ftp/pub

    # If set to YES, anonymous users will be permitted to upload files
    # under  certain  conditions.  For  this  to  work,   the   option
    # write_enable  must be activated, and the anonymous ftp user must
    # have write permission on desired upload locations. This  setting
    # is  also  required for virtual users to upload; by default, virtual 
    # users  are  treated   with   anonymous   (i.e.   maximally restricted) privilege.
    # Default: NO
    anon_upload_enable=YES

    # When  enabled,  anonymous users will only be allowed to download
    # files which are world readable. This is recognising that the ftp
    # user may own files, especially in the presence of uploads.
    # Default: YES
    anon_world_readable_only=NO
                    

Create the ftp user:

        useradd --home /var/ftp --shell /bin/false ftp
                    

Create the FTP directory:

        mkdir -p --mode 733 /var/ftp/pub/incoming
                    

Set up inetd to listen for FTP traffic and start vsftpd. Add the
following line to `/etc/inetd.conf`:

        ftp   stream    tcp   nowait   root   /usr/sbin/tcpd   /usr/sbin/vsftpd
                    

Reload the inetd daemon.

An online HTML version of the manual page which lists all vsftpd config
options can be found at: [Manpage of
vsftpd.conf](http://vsftpd.beasts.org/vsftpd_conf.html).

When anonymous users should only be allowed to upload files, e.g., for
sending files for analysis to remote support, make sure this directory
is read-writable by the owner, root, and writeable but not readable by
group members and others. This allows the anonymous user to write into
the incoming directory but not to change it.

###   Pure-FTPd

Pure-FTPd is a highly flexible, secure and fast FTP server.

####  Configuration

Unlike many daemons, Pure-FTPd doesn't read any configuration file
(except for LDAP and SQL when used). Instead, it uses command-line
options. For convenience a wrapper is provided which reads a
configuration file and starts Pure-FTPd with the right command-line
options.

pure-ftpd Specific configuration options of `pure-ftpd` can be found at:
[Pure-FTPd Configuration
file](http://download.pureftpd.org/pub/pure-ftpd/doc/README).

####  Important command line options

pure-ftpd If you want to listen for an incoming connection on a
non-standard port, just append `-S` and the port number:

        /usr/local/sbin/pure-ftpd -S 42
                

If your system has many IP addresses and you want the FTP server to be
reachable on only one of these addresses, let's say 192.168.0.42, just
use the following command:

        /usr/local/sbin/pure-ftpd -S 192.168.0.42,21
                

**Note**

The 21 port number could be left away since this is the default port.

To limit the number of simultaneous connections use the `-c` option:

        /usr/local/sbin/pure-ftpd -c 50 &
                

####  Example minimal configuration for anonymous up- and downloads

Create the ftp user:

        useradd --home /var/ftp --shell /bin/false ftp
                    

Create the ftp directory structure with the correct permissions:

        # Set the proper permissions to disable writing
        mkdir -p --mode 555 /var/ftp
        mkdir -p --mode 555 /var/ftp/pub
        # Set the proper permissions to enable writing
        mkdir -p --mode 755 /var/ftp/pub/incoming
                    

Change ownership:

        chown -R ftp:ftp /var/ftp/

        192552    0 dr-xr-xr-x   3 ftp      ftp            16 Mar 11 11:54 /var/ftp
        192588    0 dr-xr-xr-x   3 ftp      ftp             8 Mar 11 11:07 /var/ftp/pub
        192589    0 drwxr-xr-x   2 ftp      ftp             8 Mar 11 11:55 /var/ftp/pub/incoming
                    

Set up inetd to listen for FTP traffic and start `pure-ftpd`. Add the
following line to `/etc/inetd.conf`:

        ftp   stream   tcp   nowait   root   /usr/sbin/tcpd   /usr/sbin/pure-ftpd -e
                    

Reload the inetd daemon:

        killall -HUP inetd
                    

or

        kill -HUP $(cat /var/run/inetd.pid)
                    

###   Other FTP servers

There are numerous FTP servers available and in use on Linux systems.
Some alternatives to the servers mentioned above are: wu-ftpd and
ProFTPd.

####  ProFTPd

ProFTPd - Professional configurable, secure file transfer protocol
server.

    SYNOPSIS
        proftpd [ -hlntv ] [ -c config-file ] [ -d debuglevel ] [ -p 0|1 ]
                

`proftpd` is the Professional File Transfer Protocol (FTP) server
daemon. The server may be invoked by the Internet "super-server"
`inetd(8)` each time a connection to the FTP service is made, or
alternatively it can be run as a standalone daemon.

When `proftpd` is run in standalone mode and it receives a SIGHUP then
it will reread its configuration file. When run in standalone mode
without the -n option, the main `proftpd` daemon writes its process ID
to `/var/run/run/proftpd.pid` to make it easy to know which process to
SIGHUP.

See the man page of `proftpd` for detailed information on this ftp
server. Detailed information can be found at: [The ProFTPd
Project](http://www.proftpd.org/).
