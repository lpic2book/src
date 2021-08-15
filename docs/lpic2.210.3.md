##  LDAP client usage (210.3)

Candidates should be able to perform queries and updates to an LDAP
server. Also included is importing and adding items, as well as adding
and managing users.

###   Key Knowledge Areas

- LDAP utilities for data management and queries

- Change user passwords

- Querying the LDAP directory

###   Terms and Utilities

-   `ldapsearch`

-   `ldappasswd`

-   `ldapadd`

-   `ldapdelete`

##  LDAP

LDAP stands for Lightweight Directory Access Protocol. As the name
suggests, it is a lighter version of DAP, which stands for the Directory
Access Protocol that is defined by the X.500 standard. For more
information on X.500, please read [RFC
2116](http://www.faqs.org/rfc/rfc2116.txt). LDAPRFC 2116

The reason for a lightweight version is that DAP was rather heavy on
processor load, thereby asking for more than the processors could
provide at the time. LDAP is described in [RFC
2251](http://www.faqs.org/rfc/rfc2251.txt). LDAPRFC 2251

The LDAP project was started at the [University of
Michigan](http://www.umich.edu/~dirsvcs/ldap/), but, as can be read on
their site, is no longer maintained there. For current information, the
University of Michigan site points visitors to the
[OpenLDAP](http://www.openldap.org/) site instead. OpenLDAP

The type of information best suited for storage in a directory is
information with a low mutation grade. The reason for this is that
directories can not compete with RDBM systems because they are only
optimized for read access. So then, what do we store in a directory?
Typically, LDAP directories contain employee data such as surname,
christian name, address, phone number, department, social security
number, E-mail address. Alternatively, directories might store
newsletters for everyone to read, description of company policies and
procedures, templates supporting the house style of documents.

LDAP is a client/server system. The server can use a variety of
databases to store a directory, each optimized for quick and copious
read operations. When an LDAP client application connects to an LDAP
server, it can either query a directory or attempt to modify it. In the
event of a query, the server either answers the query locally, or it can
refer the querent to an LDAP server which does have the answer. If the
client application is attempting to modify information within an LDAP
directory, the server verifies that the user has permission to make the
change and then adds or updates the information.

entry

-   A single unit within an LDAP directory. Each entry is identified by
    its unique *Distinguished Name* (DN).

attributes

-   Information directly associated with an entry. For example, an
    organization could be represented as an LDAP entry. Attributes
    associated with the organization might be its fax number, its
    address, and so on. People can also be represented as entries in the
    LDAP directory. Common attributes for people include the person's
    telephone number and email address.

    Some attributes are required, while other attributes are optional.
    An objectclass definition sets which attributes are required and
    which are not for each entry. Objectclass definitions are found in
    various schema files, located in the `/etc/openldap/schema/`
    directory.

LDIF

-   The LDAP Data Interchange Format (LDIF) is an ASCII text
    representation of LDAP entries. Files used for importing data to
    LDAP servers must be in LDIF format. An LDIF entry looks similar to
    the following example:

            [<id>]
            dn: <distinguished name>
            <attrtype>: <attrvalue>
            <attrtype>: <attrvalue>
            <attrtype>: <attrvalue>
                                

    Each entry can contain as many \<attrtype\>: \<attrvalue\> pairs as
    needed. A blank line indicates the end of an entry.

    **Note**
    All \<attrtype\> and \<attrvalue\> pairs must be defined in a
    corresponding schema file to use this information.
    :::

    Any value enclosed within a \"\<\" and a \"\>\" is a variable and
    can be set whenever a new LDAP entry is created. This rule does not
    apply, however, to \<id\>. The \<id\> is a number determined by the
    application used to edit the entry.

ldapsearch

ldapsearch `ldapsearch` is a shell-accessible interface to the
ldap\_search(3) library call. `ldapsearch` opens a connection to an LDAP
server, binds, and performs a search using specified parameters. The
filter should conform to the string representation for search filters as
defined in [RFC 2254](http://www.faqs.org/rfc/rfc2254.txt).

###   LDAP Filters

|Match|notation|Effect|
|----|----|----|
|Equality|=|Creates a filter which requires a field to have a given value. For example, cn=Eric Johnson.|
|Presence|=*|Wildcard to represent that a field can equal anything except NULL. So it will return entries with one or more values. For example, cn=* manager=*|
|Substring|=string* string|Returns entries containing attributes containing the specified substring. For example, cn=Bob* cn=*John* cn=E*John. The asterisk (*) indicates zero (0) or more characters.|
|Approximate|~=|Returns entries containing the specified attribute with a value that is approximately equal to the value specified in the search filter. For example, cn~=suret l~=san franciso could return cn=sarette l=san francisco|
|Greater than or equal to|>=|Returns entries containing attributes that are greater than or equal to the specified value.|
|Less than or equal to|<=|Returns entries containing attributes that are less than or equal to the specified value.|
|Parentheses|()|Separates filters to allow other logical operators to function.|
|And|&|Boolean operator. Joins filters together. All conditions in the series must be true. For example, (&(filter)(filter)...).|
|Or|||Boolean operator. Joins filters together. At least one condition in the series must be true. For example, (|(filter)(filter)...).|
|Not|!|Boolean operator. Excludes all objects that match the filter. Only one filter is affected by the NOT operator. For example, (!(filter))|

Boolean expressions are evaluated in the following order:

-   Innermost to outermost parenthical expressions first.

-   All expressions from left to right.

**Examples:**

        ldapsearch -h myhost -p 389 -s base -b "ou=people,dc=example,dc=com" "objectclass=*"
                

This command searches the directory server myhost, located at port 389.
The scope of the search (-s) is base, and the part of the directory
searched is the base DN (-b) designated. The search filter
"objectclass=\*" means that values for all of the entry's object
classes are returned. No attributes are returned because they have not
been requested. The example assumes anonymous authentication because
authentication options are not specified.

        ldapsearch -x "(|(cn=marie)(!(telephoneNumber=9*)))"
                

This example shows how to search for entries that have a cn of marie OR
do NOT have a telephoneNumber beginning with 9.

###   ldappasswd

ldappasswd - change the password of an LDAP entry

ldappasswd is a tool to set the password of an LDAP user. ldappasswd
uses the LDAPv3 Password Modify ([RFC
3062](http://www.faqs.org/rfc/rfc3062.txt)) extended operation.

ldappasswd sets the password associated with the user (or an optionally
specified user). If the new password is not specified on the command
line and the user doesn't enable prompting, the server will be
requested to generate a password for the user.

**Example:**

        ldappasswd -x -h localhost -D "cn=root,dc=example,dc=com" \ 
            -s secretpassword -W uid=admin,ou=users,ou=horde,dc=example,dc=com
            

Set the password for "uid=admin,ou=users,ou=horde,dc=example,dc=com on
localhost".

###   ldapadd

ldapadd - LDAP add entry tool

`ldapadd` is implemented as a link to the `ldapmodify` tool. When
invoked as `ldapadd` the `-a` (add new entry) flag is turned on
automatically.

Option: `ldapmodify` `-a`

`-a` Adds new entries. The default for `ldapmodify` is to modify
existing entries. If invoked as `ldapadd`, this option is always set.

**Example:**

        ldapadd -h myhost -p 389 -D "cn=orcladmin" -w welcome -f jhay.ldif
            

Using this command, user orcladmin authenticates to the directory
myhost, located at port 389. The command then opens the file jhay.ldif
and adds its contents to the directory. The file might, for example, add
the entry "uid=jhay,cn=Human Resources,cn=example,dc=com" and its object
classes and attributes.


###   dapdelete

ldapdelete` - LDAP delete entry tool

`ldapdelete` is a shell-accessible interface to the ldap\_delete\_ext(3)
library call.

`ldapdelete` opens a connection to an LDAP server, binds, and deletes
one or more entries. If one or more DN arguments are provided, entries
with those Distinguished Names are deleted.

**Example:**

        ldapdelete -h myhost -p 389 -D "cn=orcladmin" -w welcome \
        "uid=hricard,ou=sales,ou=people,dc=example,dc=com"
            

This command authenticates user orcladmin to the directory myhost, using
the password welcome. Then it deletes the entry
"uid=hricard,ou=sales,ou=people,dc=example,dc=com".

###   More on LDAP

If you would like to read more about LDAP, this section points you to a
few sources of information:

-   [The OpenLDAP site](http://www.openldap.org/)

-   [OpenLDAP Software 2.4 Administrator's
    Guide](http://www.openldap.org/doc/admin24/)

-   [The LDAP Linux HOWTO](http://www.tldp.org/HOWTO/LDAP-HOWTO/)

-   [The Internet FAQ archives](http://www.faqs.org/faqs/) where RFC's
    and other documentation can be searched and found.
