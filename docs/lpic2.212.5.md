##  OpenVPN (212.5)

Candidates should be able to configure a VPN (Virtual Private Network)
and create secure point-to-point or site-to-site connections.

###   Key Knowledge Areas:

- OpenVPN

###   Terms and Utilities:

-   `/etc/openvpn/`

-   `openvpn`

##  OpenVPN

OpenVPN is a free and open source software application that implements
virtual private network (VPN) techniques for creating secure
point-to-point or site-to-site connections in routed or bridged
configurations and remote access facilities. It uses SSL/TLS security
for encryption and is capable of traversing network address translators
(NATs) and firewalls.

OpenVPN allows peers to authenticate each other using a pre-shared
secret key, certificates, or username/password. When used in a
multiclient-server configuration, it allows the server to release an
authentication certificate for every client, using signature and
Certificate authority. It uses the OpenSSL encryption library
extensively, as well as the TLSv1.2/TLSv1.3 protocol, and contains many
security and control features.

###   Installing

OpenVPN is available on almost any modern operating system and can be
built from source or installed as a pre-built package.

OpenVPN is not compatible with IPsec or any other VPN package. The
entire package consists of one binary for both client and server
connections, an optional configuration file, and one or more key files
depending on the authentication method used.

###   `openvpn` options

OpenVPN allows any option to be placed either on the command
line or in a configuration file. Though all command line options are
preceded by a double-leading-dash ("\--"), this prefix can be removed
when an option is placed in a configuration file.

\--config file

-   Load additional config options from file where each line corresponds
    to one command line option, but with the leading \"\--\" removed.

-dev tunX\|tapX\|null

-   TUN/TAP virtual network device (X can be omitted for a dynamic
    device.).

\-\--nobind *bits*

-   Do not bind to local address and port. The IP stack will allocate a
    dynamic port for returning packets. Since the value of the dynamic
    port could not be known in advance by a peer, this option is only
    suitable for peers which will be initiating connections by using the
    \--remote option.

\--ifconfig l rn *connection\_spec*

-   Set TUN/TAP parameters. l is the IP address of the local VPN
    endpoint. For TUN devices, rn is the IP address of the remote VPN
    endpoint. For TAP devices, rn is the subnet mask of the virtual
    ethernet segment which is being created or connected to.

secret file \[direction\]

-   Enable Static Key encryption mode (non-TLS). Use pre-shared secret
    file which was generated with \--genkey

###   Configuration

####  Simple point-to-point example

This example uses static keys for authentication. This is a very simple
setup, ideal for point-to-point networking. In the following example the
tun interfaces will be used. Another possibility would be to use the tap
interfaces but then the configuration would also be a little bit
different. See the man pages for more information about using these
interfaces.

A VPN tunnel will be created with a server endpoint of 10.10.10.10 and a
client endpoint of 10.10.10.11. The public ipaddress of the server is
referenced by vpnserver.example.com. The communication between these
endpoints will be encrypted and occur over the default OpenVPN port
1194.

openvpn To setup this example a key has to be created:
`openvpn --genkey 
                    --secret static.key`. Copy this key (`static.key`)
to both client and server.

Server configuration file (server.conf):

        dev tun
        ifconfig 10.10.10.10 10.10.10.11
        keepalive 10 60
        ping-timer-rem
        persist-tun
        persist-key
        secret static.key
                        

Client configuration file (client.conf):

        remote vpnserver.example.com
        dev tun 
        ifconfig 10.10.10.11 10.10.10.10
        keepalive 10 60
        ping-timer-rem
        persist-tun
        persist-key
        secret static.key
                        

Start the vpn on the server by running `openvpn server.conf` and running
`openvpn client.conf` on the client.
