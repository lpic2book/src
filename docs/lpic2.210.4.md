##  Configuring an OpenLDAP server (210.4)

Candidates should be able to configure a basic OpenLDAP server including
knowledge of LDIF format and essential access controls.

###  Key Knowledge Areas

- OpenLDAP

- Directory based configuration

- Access Control

- Distinguished Names

- Changetype Operations

- Schemas and Whitepages

- Directories

- Object IDs, Attributes and Classes

###   Terms and Utilities

-   `slapd`

-   `slapd.conf`

-   LDIF

-   `slapadd`

-   `slapcat`

-   `slapindex`

-   `/var/lib/ldap/`

-   `loglevel`


##  OpenLDAP

OpenLDAP uses `slapd` which is the stand-alone LDAP daemon.
It listens for LDAP connections on any number of ports (389 by default),
responding to the LDAP operations it receives over these connections.
OpenLDAP is typically started at boot time.

It can be installed either from source obtaining it from [OpenLDAP
software](http://www.OpenLDAP.org/software/) but most linux
distributions deliver it through their packagemanagement system like yum
or apt.

In OpenLDAP, directory entries are arranged in a hierarchical tree-like
structure. Traditionally, this structure reflected the geographic and/or
organizational boundaries. Entries representing countries appear at the
top of the tree. Below them are entries representing states and national
organizations. Below them might be entries representing organizational
units, people, printers, documents, or just about anything else.

###   Access Control

While the OpenLDAP directory gets filled the protection of data may become
more critical. Some data might be protected by law or be confidential in
any other way. Therefore access to the directory needs to be controlled.
The default policy allows read access to all clients. Regardless of what 
access control policy is defined, the olcRootDN is always allowed full 
rights (i.e. auth, search, compare, read, and write) on everything.

Access to `slapd` entries and attributes is controlled by the
`olcAccess` attribute, whose values are a sequence of access rules. They
begin with the access directive followed by a list of conditions:

        
        olcAccess: to <what>
               by <who> <type of access>
               by <who> <type of access>
                    

For example:

        
        olcAccess: to attrs=userPassword
               by anonymous auth
               by self write
               by * none
                    

This access specification is used to keep a user's password protected.
It allows anonymous users an authentication comparison on a password for
the purpose of of logging on. Additionally it grants a user permission
to change his password. The bottom line denies everyone else any access
to the password.

Alternatively we could grant users permission to update all their data
with access speficifations like the following:

        
        olcAccess: to attrs=userPassword
               by anonymous auth
               by * none
        olcAccess: to *
                   by self write
                   by * none
                    

###   Distinguished Names

A distinguished name (DN) is the name (set of attributes) which uniquely
identifies an entry in the OpenLDAP directory and corresponds to the
`path` which has to be traversed to reach that entry. A DN contains an
attribute and value pair separated by commas.

For example:

        
        cn=John Doe,ou=editing,o=Paris,c=F
        cn=Jane Doe,ou=editing,o=London,c=UK
        cn=Tom Jones,ou=reporting,o=Amsterdam,c=NL
                    

Any of the attributes defined in the directory schema may be used to
make up a DN. The order of the component attribute value pairs is
important. The DN contains one component for each level of the directory
hierarchy from the root down to the level where the entry resides. LDAP
DNs begin with the most specific attribute and continue with
progressively broader attributes. The first component of the DN is
referred to as the Relative Distinguished Name (RDN). It identifies an
entry distinctly from any other entries that have the same parent.

An example to create an entry for a person:

        dn: cn=John Doe,o=bmi,c=us
        objectclass: top
        objectclass: person 
        cn: John Doe 
        sn: Doe
        telephonenumber: 555-111-5555
                    

Some characters have special meaning in a DN. For example, = (equals)
separates an attribute name and value and comma separates
attribute=value pairs. The special characters are: comma, equals,
plus,less than, greater than, number sign, semicolon, backslash,
quotation mark.

A special character can be escaped in an attribute value to remove the
special meaning. To escape these special characters or other characters
in an attribute value in a DN string, use the following methods:

If a character to be escaped is one of the special characters, precede
it by a backslash ("\\" ASCII 92). This example shows a method of
escaping a comma in an organization name:

        CN=Supergroup,O=Crosby\, Stills\, Nash and Young,C=US
                    

###   slapd-config 

OpenLDAP 2.3 and later have transitioned to using a dynamic runtime
configuration engine, `slapd-config`. The older style `slapd.conf` file
is still supported, but its use is deprecated and support for it will be
withdrawn in a future OpenLDAP release.

**Note**
Although the slapd-config system stores its configuration as
(text-based) LDIF files, you should never edit any of the LDIF files
directly. Configuration changes should be performed via LDAP operations,
e.g. `ldapadd`, `ldapdelete`, or `ldapmodify`.

Depending on the linux distribution the `slapd-config` configuration
tree `slapd.d` may be located in `/etc/OpenLDAP` or
`/usr/local/etc/OpenLDAP`.

An example might look like this:

        
        /etc/OpenLDAP/slapd.d
        |-- cn=config
        |   |-- cn=module{0}.ldif
        |   |-- cn=schema
        |   |   |-- cn={0}core.ldif
        |   |   |-- cn={1}cosine.ldif
        |   |   `-- cn={2}inetorgperson.ldif
        |   |-- cn=schema.ldif
        |   |-- olcDatabase={0}config.ldif
        |   |-- olcDatabase={-1}frontend.ldif
        |   `-- olcDatabase={1}hdb.ldif
        `-- cn=config.ldif
                    

The `slapd.d` tree has a very specific structure. The root of the tree
is named `cn=config` and contains global configuration settings.
Additional settings are contained in separate child entries.

These may be the following:

-   Dynamically loaded modules in the `cn=module{0}.ldif`

-   Schema definitations in the `cn=schema` directory (more about the
    topic of schema's will follow below)

-   Backend-specific configuration in the `cn=Database={1}hdb.ldif`

-   Database-specific configuration in the `cn=Database={0}config.ldif`

The general layout of the LDIF (for more information on LDIF refer to
the section below) that is used to create the configuration tree is as
follows:

        # global configuration settings
        dn: cn=config
        objectClass: olcGlobal
        cn: config
        <global config settings>

        # schema definitions
        dn: cn=schema,cn=config
        objectClass: olcSchemaConfig
        cn: schema
        <system schema>

        dn: cn={X}core,cn=schema,cn=config
        objectClass: olcSchemaConfig
        cn: {X}core
        <core schema>

        # additional user-specified schema
        ...

        # backend definitions
        dn: olcBackend=<typeA>,cn=config
        objectClass: olcBackendConfig
        olcBackend: <typeA>
        <backend-specific settings>

        # database definitions
        dn: olcDatabase={X}<typeA>,cn=config
        objectClass: olcDatabaseConfig
        olcDatabase: {X}<typeA>
        <database-specific settings>

        # subsequent definitions and settings
        ...
                    

For the domain `example.com` the configuration file might look like
this:

        dn: olcDatabase=hdb,cn=config
        objectClass: olcDatabaseConfig
        objectClass: olcHdbConfig
        olcDatabase: hdb
        olcSuffix: dc=example,dc=com
        olcRootDN: cn=Manager,dc=example,dc=com
        olcRootPW: secret 
        olcDbDirectory: /var/lib/ldap
                    

It is more secure to generate a password hash using `slappasswd` instead
of the plain text password secret as in the example above. In that case
the `olcRootPW` line would be changed into something like the following:

        olcRootPW: {SSHA}xEleXlHqbSyi2FkmObnQ5m4fReBrjwGb
                    

The `olcLogLevel` directive specifies at which debugging
level statements and operation statistics should be syslogged. Log
levels may be specified as integers or by keyword. Multiple log levels
may be used and the levels are additive.

Available levels are:

        1      (0x1 trace) trace function calls
        2      (0x2 packets) debug packet handling
        4      (0x4 args) heavy trace debugging (function args)
        8      (0x8 conns) connection management
        16     (0x10 BER) print out packets sent and received
        32     (0x20 filter) search filter processing
        64     (0x40 config) configuration file processing
        128    (0x80 ACL) access control list processing
        256    (0x100 stats) stats log connections/operations/results
        512    (0x200 stats2) stats log entries sent
        1024   (0x400 shell) print communication with shell backends
        2048   (0x800 parse) entry parsing
        16384  (0x4000 sync) LDAPSync replication
        32768  (0x8000 none) only messages that get logged whatever log level is set
                    

For example:

        olcLogLevel: -1 
                    

This will cause lots and lots of debugging information to be logged.

        olcLogLevel: conns filter
                    

This will only log the connection and search filter processing.

        olcLogLevel: stats
                    

Basic stats logging is configured by default. However, if no olcLogLevel
is defined, no logging occurs (equivalent to a 0 level).

Note that the actual OpenLDAP database holding the user data is not
located in the `slapd.d` configuration directory tree. Its location may
be changed with the olcDbDirectory directory (see the example above) but
by convention it is usually `/var/lib/ldap` /var/lib/ldap/.

Its contents typically looks like this:

        $ ls -l /var/lib/ldap
        total 1168
        -rw-r--r--. 1 ldap ldap    4096 Dec 12 14:29 alock
        -rw-------. 1 ldap ldap    8192 Dec  2 21:31 cn.bdb
        -rw-------. 1 ldap ldap 2351104 Dec 12 14:29 __db.001
        -rw-------. 1 ldap ldap  819200 Dec 12 14:29 __db.002
        -rw-------. 1 ldap ldap  163840 Dec 12 14:29 __db.003
        -rw-rw-r--. 1 ldap ldap     104 Dec  2 21:12 DB_CONFIG
        -rw-------. 1 ldap ldap    8192 Dec  2 21:31 dn2id.bdb
        -rw-------. 1 ldap ldap   32768 Dec  2 21:31 id2entry.bdb
        -rw-------. 1 ldap ldap    8192 Dec  2 21:31 objectClass.bdb
                    

###   LDIF

All modifications to the OpenLDAP database are formatted in the LDIF
LDIF format. LDIF stands for LDAP Data Interchange Format. It is used by
OpenLDAP's tools like `slapadd` in order to add data to the database.
An example of a LDIF file:

        cat adduser.ldif

        # John Doe's Entry
        dn: cn=John Doe,dc=example,dc=com
        cn: John Doe
        cn: Johnnie Doe
        objectClass: person
        sn: Doe
                    

Multiple entries are separated using a blank line. `Slapcat` `slapcat`
can be used to export information from the LDAP database in the LDIF
format.

For example:

        slapcat -l all.ldif
                    

This will generate a file called `all.ldif` which contains a full dump
of the LDAP database.

The generated output can be used by `slapadd` `slapadd` to import the
data into an LDAP database.

For example:

        slapadd -l all.ldif
                    

Sometimes it may be necessary to regenerate LDAP's database indexes.
This can be done using the `slapindex` tool. `slapindex` It may also be
used to regenerate the index for a specific attribute like the UID:

        slapindex uid  
                    

Note that `slapd` should not be running (at least, not in read-write
mode) when the command is run to ensure consistency of the database.

###   Directories

A directory can be contrived of as an hierarchically organized
collection of data. The best known example probably is the telephone
directory, but the file system directory is another one. Generally
speaking a directory is a database that is optimized for reading,
browsing and searching. OpenLDAP directories contain descriptive,
attribute-based information. They do not support the roll-back
mechanisms or complicated transactions that are found in Relational Data
Base Management Systems (RDBMS's). Updates are typically simple
all-or-nothing changes, if allowed at all. This type of directories are
designed to give quick responses to high-volume lookup or search
operations. OpenLDAP directories can be replicated to increase
availability and reliability. Replicated databases can be temporarily
out-of-sync but will be synchronized eventually.

###   Schemas and Whitepages

Schemas are the standard way of describing the structure of objects that
may be stored inside a directory. A whitepages schema is a data model
for organizing the data contained in entries in a directory service such
as an address book or LDAP. In a whitepages directory, each entry
typically represents an individual that makes use of network resources,
such as by receiving email of having an account to log in to a system.
LDAP schemas are used to formally define attributes, object classes, and
various rules for structuring the directory information tree. Usually
schemas are configured in `slapd-config` LDIF using the include include
directive.

For example:

        
        include: file:///etc/OpenLDAP/schema/core.ldif
        include: file:///etc/OpenLDAP/schema/cosine.ldif
        include: file:///etc/OpenLDAP/schema/inetorgperson.ldif
                    

The first line imports the core schema, which contains the schemas of
attributes and object classes necessary for standard LDAP use. The
cosine.schema imports a number of commonly used object classes and
attributes, including those used for storing document information and
DNS records. The third provides the inetOrgPerson object class
definition and its associated attribute definitions. Other schemas are
available with OpenLDAP (in `/etc/OpenLDAP/schema`); refer to the
OpenLDAP Software 2.4 Administrator's guide for more information.

References

-   [OpenLDAP Software 2.4 Administrator's
    Guide](http://www.OpenLDAP.org/doc/admin24/)

-   [Directory Service](https://en.wikipedia.org/wiki/Directory_service)

-   [Lightweight Directory Access
    Protocol](https://en.wikipedia.org/wiki/Lightweight_Directory_Access_Protocol#Directory_structure)

-   [System Security Services
    Daemon](https://en.wikipedia.org/wiki/System_Security_Services_Daemon)

-   [White Pages
    Schema](https://en.wikipedia.org/wiki/White_pages_schema)
