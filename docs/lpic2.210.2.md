##  PAM authentication (210.2)

The candidate should be able to configure PAM to support authentication
using various available methods.

###   Key Knowledge Areas

- PAM configuration files, terms and utilities

- passwd and shadow passwords

- basic SSSD functionality for LDAP authentication

###   Terms and Utilities

-   `/etc/pam.d`

-   `pam.conf`

-   `nsswitch.conf`

-   `pam_unix, pam_cracklib, pam_limits, pam_listfile`

##  What is PAM?

PAM is the acronym for Pluggable Authentication Modules. PAM consists of
a set of libraries and an API (Application Programming Interface) that
can be used to perform authentication tasks. Privilege granting
programs, such as `login` and `su`, use the API to perform standard
authentication tasks.

###   How does it work?

account

-   Provide account verification types of service: has the user's
    password expired? Is this user permitted access to the requested
    service?

authentication

-   Establish if the user really is whom he claims to be. This can be
    done, for example, by asking a password or, given the right module,
    by reading a chip-card or by performing a retinal or fingerprint
    scan.

password

-   This group's responsibility is the task of updating authentication
    mechanisms. Typically, such services are strongly coupled to those
    of the authentication group. Some authentication mechanisms lend
    themselves well to being updated. The user might be presented with a
    question like "Please enter the new password".

session

-   This group of tasks covers things that should be done prior to a
    service being offered and after it is withdrawn. Such tasks include
    the maintenance of audit trails and the mounting of the user's home
    directory. The session management group is important as it provides
    both an opening and closing hook for modules that affect the
    services available to a user.

PAM can be configured using the file `/etc/pam.conf` ConfiguringPAM
PAMpam.conf which has the following format:

        service   type   control   module-path   module-arguments
                

service

-   This is the name of the application involved, for example: PAMlogin
    PAMssh PAMpasswd `login`, `ssh` or `passwd`.

type

-   This is the type of group the task to be performed belongs to:
    account, auth (the authentication group), password or session.

control

-   This field indicates what the PAM-API should do in case
    authentication fails for any module.

    re-quisite

    -   Upon failure, the authentication process will be PAMrequisite
        terminated immediately.

    required

    -   This will return failure after the remaining modules PAMrequired
        for this service and type have been invoked.

    sufficient

    -   Upon success, the authentication process will be PAMsufficient
        satisfied, unless a prior required module has failed the
        authentication.

    optional

    -   The success or failure of this module is only important
        PAMoptional if this is the only module associated with this
        service and this type.

module-path

-   This is the filename, including the full path, of the PAM that is to
    be used by the application.

module-arguments

-   These are module specific arguments, separated by spaces, that are
    to be passed to the module. Refer to the specific module's
    documentation for further details.

Configuration is also possible using individual configuration files,
which is recommended. These files should all be located in the
`/etc/pam.d` directory. If this directory exists, the file
`/etc/pam.conf` will be ignored. The filenames should all be lowercase
and be identical to the name of the service, such as `login`. The format
of these files is identical to `/etc/pam.conf` with the exception that
there is no service field.

Modules

###   pam\_unix

This module configures authentication via `/etc/passwd` and
`/etc/shadow`.

account

-   The type "account" does not authenticate the user but checks
    PAMaccount other things such as the expiration date of the password
    and might force the user to change his password based on the
    contents of the files `/etc/passwd` and `/etc/shadow`.

    debug

    -   Log information using `syslog`.

    audit

    -   Also logs information, even more than debug does.

auth

-   The type "auth" checks the user's password against the password
    PAMauth database(s). This component is configured in the file
    `/etc/nsswitch.conf`. Please consult the man page
    (`man nsswitch.conf`) for further details.

    audit

    -   Log information using `syslog`.

    debug

    -   Also logs information using `syslog` but less than audit.

    nodelay

    -   This argument sets the delay-on-failure, which has a default of
        a second, to nodelay.

    nullok

    -   Allows empty passwords. Normally authentication fails if
        PAMnullok the password is blank.

    try\_first\_pass

    -   Use the password from the previous stacked auth module and PAM
        try\_first\_pass prompt for a new password if the retrieved
        password is blank or incorrect.

    use\_first\_pass

    -   Use the result from the previous stacked auth module, never PAM
        use\_first\_pass prompt the user for a password and fails if the
        result was a fail.

password

-   The type "password" changes the user's password. PAM password

    audit

    -   Log information using `syslog`.

    bigcrypt

    -   Use the DEC "C2" extension to crypt().

    debug

    -   Also logs information using `syslog` but less than audit.

    md5

    -   Use md5 encryption instead of crypt().

    nis

    -   Use NIS (Network Information Service) passwords.

    not\_set\_pass

    -   Don't use the passwords from other stacked modules and do not
        give the new password to other stacked modules.

    nullok

    -   Allows empty passwords. Normally authentication fails if the
        password is blank.

    remember

    -   Remember the last n passwords to prevent the user from using one
        of the last n passwords again.

    try\_first\_pass

    -   Use the password from the previous stacked auth module, and
        prompt for a new password if the retrieved password is blank or
        incorrect.

    use\_authtok

    -   Set the new password to the one provided by a previous module.

    use\_first\_pass

    -   Use the result from the previous stacked auth module, never
        prompt the user for a password and fails if the result was a
        fail.

session

-   The type "session" uses syslog to log the user's name and session
    PAMsession type at the start and end of a session.

    The "session" type does not support any options.

For each service that requires authentication a file with the name of
that service must be created in `/etc/pam.d`. Examples of those services
are: `login`, `ssh`, `ppp`, `su`.

For example purposes the file `/etc/pam.d/login` will be used:

        # Perform password authentication and allow accounts without a password
        auth       required   pam_unix.so nullok

        # Check password validity and continue processing other PAM's even if
        # this test fails. Access will only be granted if a 'sufficient' PAM,
        # that follows this 'required' one, succeeds.
        account    required   pam_unix.so

        # Log the user name and session type to syslog at both the start and the end
        # of the session.
        session    required   pam_unix.so

        # Allow the user to change empty passwords (nullok), perform some additional
        # checks (obscure) before a password change is accepted and enforce that a
        # password has a minimum (min=4) length of 4 and a maximum (max=8) length of
        # 8 characters.
        password   required   pam_unix.so nullok obscure min=4 max=8
                    

###   pam\_nis

This module configures authentication via NIS. ConfiguringNIS
Authentication To be able to authenticate via NIS, the module
`pam_nis.so` is needed. This module can be PAMpam\_nis.so found at [PAM
NIS Authorisation
Module](http://www.chiark.greenend.org.uk/~peterb/uxsup/project/pam_nis/).

To set up things in such a way that NIS authentication is sufficient
(and if that is not the case try `pam_unix.so`), the lines that do the
trick in `/etc/pam.d/login` are:

        auth    sufficient pam_nis.so item=user \
        sense=allow map=users.byname value=compsci
        auth    required   pam_unix.so try_first_pass

        account sufficient pam_ldap.so \
        item=user sense=deny map=cancelled.byname error=expired
        account required   pam_unix.so
                    

###   pam\_ldap

This module configures authentication via LDAP. To be able to
authenticatie via LDAP, the module ConfiguringLDAP Authentication
`pam_ldap.so` is needed. This module can be found at [PADL Software Pty
Ltd](http://www.padl.com/pam_ldap.html).

To set up things in such a way that LDAP authentication is sufficient,
(and if that is not the case try `pam_unix.so`), the PAMpam\_ldap.so
lines that do the trick in `/etc/pam.d/login` are:

        auth    sufficient pam_ldap.so
        auth    required   pam_unix.so try_first_pass

        account sufficient pam_ldap.so
        account required   pam_unix.so
                    

###   pam\_cracklib

This plugin provides strength-checking for passwords. This is done by
performing a number of checks to ensure passwords are not too weak. It
checks the password against dictonaries, the previous password(s) and
rules about the use of numbers, upper and lowercase and other
characters.

        #%PAM-1.0
        #
        # These lines allow a md5 systems to support passwords of at least 14
        # bytes with extra credit of 2 for digits and 2 for others the new
        # password must have at least three bytes that are not present in the
        # old password
        #
        password  required pam_cracklib.so \
        difok=3 minlen=15 dcredit= 2 ocredit=2
        password  required pam_unix.so use_authtok nullok md5
                    

###   pam\_limits

The pam\_limits PAM module sets limits on the system resources that can
be obtained in a user-session. Users of uid=0 are affected by this
limits, too. By default limits are taken from the
`/etc/security/limits.conf` config file. Then individual files from the
`/etc/security/limits.d/` directory are read. The files are parsed one
after another in the order of \"C\" locale. The effect of the individual
files is the same as if all the files were concatenated together in the
order of parsing. If a config file is explicitely specified with a
module option then the files in the above directory are not parsed. The
module must not be called by a multithreaded application.

###   pam\_listfile

This module allows or denies an action based on the presence of the item
in a listfile. A listfile is a textfile containing a list of usernames,
one username per line. The type of item can be set via the configuration
parameter item and can have the value of user, tty, rhost, ruser, group,
or shell. The *sense* configuration parameter determines whether the
entries in the list are allowed. Possible values are allow and deny.

SSSD

Configure SSSD for LDAP authentication

The following steps describe the configuration of SSSD to use LDAP for
authentication:

1\. The following packages need to be installed:

        sssd-client
        sssd-common
        sssd-common-pac
        sssd-ldap
        sssd-proxy
        python-sssdconfig
        authconfig
        authconfig-gtk
                

Use your package manager to install these packages.

2\. Check the current settings for sssd, if any:

        # authconfig test
                

This will show you the current settings which are already in place. Also
check for an existing `/etc/sssd/sssd.conf` file. On a fresh
installation you can expect all settings to be disabled and that the
sssd.conf file will not be present.

3\. Now configure sssd:

        # authconfig \
        --enablesssd \
        --enablesssdauth \
        --enablelocauthorize \
        --enableldap \
        --enableldapauth \
        --ldapserver=ldap://ldap.example.com:389 \
        --disableldaptls \
        --ldapbasedn=dc=example,dc=com \
        --enablerfc2307bis \
        --enablemkhomedir \
        --enablecachecreds \
        --update
                

4\. Check the configuration in `/etc/sssd/sssd.conf`.

In case you're using TLS make sure that the `ldap_tls_cacertdir` and
`ldap_tls_cacert` parameters are configured correctly and point to your
certificates. Also change `ldap_id_use_start_tls` to "True".

To effect the changes, run:

        # systemctl restart sssd
                

Verify that all changes are effective by running:

        # authconfig test
                

5\. Update `/etc/openldap.conf` to use the same ldap settings. Your
`ldap.conf` file will look like this:

        SASL_NOCANON on
        URI ldaps://ldap.example.com:389
        BASE dc=example,dc=com
        TLS_REQUIRE never
        TLS_CACERTDIR /etc/pki/tls/cacerts
        TLS_CACERT /etc/pki/tls/certs/mybundle.pem
                

Please note that `TLS_REQUIRE` is set to never. This is done in order to
avoid issues with application stacks like `PHP`, which have difficulties
with `LDAPS` and `TLS`.

6\. Make sure that sssd is up and running and that it will be started
after a system reboot. Run `systemctl` `status sssd` to check this. To
start sssd, run `systemctl` `start sssd` and to make sssd persistent
across reboots, run `systemctl` `enable sssd`.
