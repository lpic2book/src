##  Managing Mailbox Access (211.3)

Candidates should be aware of Courier email server and be able to
install and configure POP and IMAP daemon on a Dovecot server.

##  Courier

The Courier mail transfer agent (MTA) is an integrated mail/groupware
server based on open commodity protocols, such as ESMTP, IMAP, POP3,
LDAP, SSL, and HTTP. Courier provides ESMTP, IMAP, POP3, webmail, and
mailing list services within a single, consistent framework. Individual
components can be enabled or disabled at will. The Courier mail server
now implements basic web-based calendaring and scheduling services
integrated in the webmail module.

The Courier mail server uses maildirs as its native mail storage format,
but it can also deliver mail to legacy mailbox files as well. By default
`/etc/courier` is the sysconfdir. All courier configuration files are
stored here. The mail queue can be found at `/var/spool/mqueue`.

Information about the configuration for Courier can be found at:
[Courier installation](http://www.courier-mta.org/install.html).

##  Dovecot

Dovecot is an open source IMAP and POP3 email server for Linux/UNIX-like
systems, written with security primarily in mind. Dovecot claims that it
is an excellent choice for both small and large installations.

The configuration files of Dovecot can be found in `/etc/dovecot/conf.d`
and we need to configure several parameters: authentication, mailbox
location, SSL settings and the configuration as POP3 server.

###   Authentication

Dovecot is capable of using several password database backends like:
PAM, BDSAuth, LDAP, passwd, and SQL databases like MySQL, PostgreSQL and
SQLite. The most common way is PAM authentication. The PAM configuration
is usually located in `/etc/pam.d`. By default Dovecot uses `dovecot` as
PAM service name.

Here is an example of `/etc/pam.d/dovecot`:

      
                                      #%PAM-1.0

                                      @include common-auth
                                      @include common-account
                                      @include common-session
                    

The method used by clients to send the login credentials to the server,
is configured via the *mechanisms* parameter. The simplest
authentication mechanism is *PLAIN*. The client simply sends the
password unencrypted to Dovecot. All clients support the *PLAIN*
mechanism, but obviously there's the problem that anyone listening on
the network can steal the password. For that reason (and some others)
other mechanisms were implemented.

SSL/TLS encryption can be used to secure the *PLAIN* authentication
mechanism, since the password is sent over an encrypted stream.
Non-plaintext mechanisms have been designed to be safe to use even
without SSL/TLS encryption. Because of how cd /etc/they have been
designed, they require access to the plaintext password or their own
special hashed version of it. This means that it's impossible to use
non-plaintext mechanisms with commonly used DES or MD5 password hashes.
With success/failure password databases (e.g. PAM) it's not possible to
use non-plaintext mechanisms at all, because they only support verifying
a known plaintext password.

Dovecot supports the following non-plaintext mechanisms: *CRAM-MD5*,
*DIGEST-MD5*, *SCRAM-SHA1*,*SCRAM-SHA-256*, *APOP*, *NTLM*,
*GSS-SPNEGO*, *GSSAPI*, *RPA*, *ANONYMOUS*, *OTP* and *SKEY*,
*OAUTHBEARER*, *XOATH2* and *EXTERNAL*. By default only the *PLAIN*
mechanism is enabled. You can change this by modifying `10-auth.conf`:

                                      auth_mechanisms = plain login cram-md5

###   Mailbox location

Using the *mail\_location* parameter in `10-mail.conf` we can configure
which mailbox location we want to use:

        mail_location = maildir:~/Maildir
                    

or

        mail_location = mbox:~/mail:INBOX=/var/mail/%u
                    

In this case email is stored in `/var/mail/%u` where "%u" is converted
into the username.

###   SSL

Before Dovecot can use SSL, the SSL certificates need to be created and
Dovecot must be configured to use them.

mkcert.sh Dovecot includes a script `/usr/share/dovecot/mkcert.sh` to
create self-signed SSL certificates:

    #!/bin/sh

    # Generates a self-signed certificate.
    # Edit dovecot-openssl.cnf before running this.

    umask 077
    OPENSSL=${OPENSSL-openssl}
    SSLDIR=${SSLDIR-/etc/ssl}
    OPENSSLCONFIG=${OPENSSLCONFIG-dovecot-openssl.cnf}

    CERTDIR=/etc/dovecot
    KEYDIR=/etc/dovecot/private

    CERTFILE=$CERTDIR/dovecot.pem
    KEYFILE=$KEYDIR/dovecot.pem

    if [ ! -d $CERTDIR ]; then
      echo "$SSLDIR/certs directory doesn't exist"
      exit 1
    fi

    if [ ! -d $KEYDIR ]; then
      echo "$SSLDIR/private directory doesn't exist"
      exit 1
    fi

    if [ -f $CERTFILE ]; then
      echo "$CERTFILE already exists, won't overwrite"
      exit 1
    fi

    if [ -f $KEYFILE ]; then
      echo "$KEYFILE already exists, won't overwrite"
      exit 1
    fi

    $OPENSSL req -new -x509 -nodes -config $OPENSSLCONFIG -out $CERTFILE -keyout $KEYFILE -days 365 || exit 2
    chmod 0600 $KEYFILE
    echo
    $OPENSSL x509 -subject -fingerprint -noout -in $CERTFILE || exit 2
                    

The important SSL configuration options can be found in the file:
`10-ssl.conf`. To enable encryption of the data in transit between a
client and a Dovecot server the following changes should be made.

        ssl = required
        

This configuration option requires that the client is using SSL/TLS as
transport layer mechanism. Authentication attempts without SSL/TLS will
cause authentication failures. Another important configuration option to
enable SSL/TLS is the configuration of the SSL/TLS key and the SSL/TLS
certificate. The certificates in this example are auto generated by the
installation of Dovecot.

        ssl_cert = </etc/dovecot/dovecot.pem
        ssl_key = </etc/dovecot/private/dovecot.pem
        

The preferred permissions of the certificate is 0440 (world readable).
The certificate is offered to clients. The permissions of the key should
be 0400 with uid/gid 0. It should only be readable by the root user. If
the key file is password protected the password can be configured in the
configuration file by changing the `
    ssl_key_password` option. Since the SSL and TLSv1 protocols are
vulnerable to multiple attacks like POODLE (Padding Oracle On Downgraded
Legacy Encryption) those protocols should be disabled.

    ssl_min_protocol=TLSv1.2
        

Another key feature of configuring encryption is determine the cipher
suite that should be used by Dovecot. The cipher suite defines the
allowed ciphers offered by the server by initiating a secured connection
with the client. You should keep in mind that the mail user agent should
support the cipher suite that is configured on the server otherwise it
is not possible to establish a secure connection. An example of a cipher
suite is displayed below:

        ssl_cipher_list = AES256+EECDH:AES256+EDH
        

The cipher AES256+EECDH means that the cipher is using authenticated
Ephemeral Elliptic Curve Diffie Hellman key agreement protocol. This
protocol is used the share a secret over an insecure channel. This key
can be used to encrypt and decrypt communications by using a symmetric
encryption protocol which is AES256 bits in this configuration. The
cipher AES256+EDH is almost the same as AES256+EECDH. This cipher is not
using elliptic curves but RSA algorithm. Another option that should be
configured is:

        ssl_prefer_server_ciphers = yes
        

This option prefers the ciphers that are in the configured on the server
in favour of the ciphers from the client. This configuration option
avoids so called downgrade attacks. This attack is performed by a man in
the middle attack and removes the strong crypto suites to initiate only
weak ciphers from the client. The attacker can attack the weak ciphers
with main purpose to decrypt encrypted traffic. Another important
configuration option is:

        
        ssl_dh_parameters_length = 2048
        

This option configures Diffie-Hellman key exchange to 2048-bit keys.
Recently the Logjam vulnerability was published. This attack is related
to cipher suite down grade attacks. An attacker can downgrade a TLS
connection to use 512-bit DH cryptography. gnutls-cli On a linux client
the supported cipher suite by first list the shared library (e.g.
openssl or gnutls) and then listing the supported ciphers by using one
of the command `openssl ciphers` or with `gnutls-cli -l`. If a cipher is
not supported by the mail user agent for example mutt, it will display
an error e.g.

     gnutls_handshake: A TLS fatal alert has been received.(Handshake failed)

. After the SSL/TLS configuration the imaps and pop3s listener should be
configured. The listeners can be configured in the file:
`10-master.conf`.

        service imap-login {
          inet_listener imap {
                port = 0
           #port = 143
         }
          inet_listener imaps {
              port = 993
              ssl = yes
         }
        }

        service pop3-login {
          inet_listener pop3 {
                port = 0
           #port = 110
         }
          inet_listener pop3s {
                port = 995
                ssl=yes
         }
        }

        

If the listener port is set to 0 the pop3 and imap service are not
running on the server. Only the secure versions of the protocol are
enabled. After configuration of the dovecot the dovecot server should be
restarted. This can be initiated by the command:
` service dovecot restart`. Verify if pop3s and imaps service is
listening on the appropriate port by using the command:

        # netstat -anp |egrep '993|995'
        tcp    0   0 0.0.0.0:993      0.0.0.0:*    LISTEN      3515/dovecot
        tcp    0   0 0.0.0.0:995      0.0.0.0:*    LISTEN      3515/dovecot
        tcp6   0   0 :::993           :::*         LISTEN      3515/dovecot
        tcp6   0   0 :::995           :::*         LISTEN      3515/dovecot
        

As you can see pop3s and imaps are listening on their configured ports
and ready to use.

###   POP3 server

Although Dovecot is primarily designed as IMAP server, it works fine as
POP3 server but it isn't optimized for being that. The POP3
specification requires that sizes are reported exactly and using
*Maildir* the linefeeds are stored as plain LF characters. Simply
getting the file size therefore returns a wrong POP3 message size.

mbox\_min\_index\_size When using *mbox* instead of *Maildir*, the index
files are updated when a POP3 starts and includes all messages. After
the user has deleted all mails, the index files again get updated to
contain zero mails. When using Dovecot as a POP3 server, you might want
to consider disabling or limiting the use of the index files using the
`mbox_min_index_size` setting.
