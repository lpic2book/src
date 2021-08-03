##  Managing E-Mail Delivery (211.2)

Candidates should be able to implement client e-mail management software
to filter, sort and monitor incoming user email.

###   Key Knowledge Areas

- Understanding of Sieve functionality, syntax and operators

- Use Sieve to filter and sort mail with respect to sender, recipient(s),
headers and size

- Awareness of procmail

###   Terms and Utilities

-   Conditions and comparison operators

-   keep, fileinto, redirect, reject, discard, stop

-   Dovecot vacation extension

##  Procmail

Procmail is a email filtering utility that may be used for
preprocessing and sorting of incoming mail. It can also be used to sort
out email from mailinglists, to filter spam and send auto-replies.
Procmail configuration is based on a file placed in the user's
homedirectory. It is rarely run from the command line (except for
testing purposes) but it's an autonomous program which is normally
invoked by MTA's (Mail Transport Agent) like Sendmail or Postfix.

Procmail follows the following scheme for reading its configuration (it
reads both): `/etc/procmailrc`, `~/.procmailrc`

Be careful using the system-wide `/etc/procmailrc`. It is usually read
and processed as root. This fact means that a poorly designed recipe in
that file could do serious damage. For instance, a typo could cause
Procmail to overwrite an important system binary rather than use that
binary to process a message. For this reason, you should keep
system-wide Procmail processing to a minimum and instead focus on using
`~/.procmailrc` to process email using individual accounts.

##  Sieve

Dovecot Sieve is a scripting language that may be used to
preproces and sort incoming email. It can also be used to sort out email
from mailinglists, to filter spam and send auto-replies. To use sieve it
should first be configured on the email servers. In this setup postfix
is used to deliver email to the Dovecot local delivery agent. In the
file `main.cf` the *mailbox\_command* option should be configured to use
the local delivery agent.

        mailbox_command = /usr/lib/dovecot/dovecot-lda -a "$RECIPIENT"
                

The next step is enabling sieve support in dovecot. In the configuration
file `15-lda.conf` the following options should be configured:

        lda_mailbox_autocreate = yes

        lda_mailbox_autosubscribe = yes

        protocol lda {
          mail_plugins = $mail_plugins sieve
        }
                

The configuration option: *lda\_mailbox\_autocreate* enables dovecot to
create a mailbox if this action is initiated by a rule in sieve. The
option: *lda\_mailbox\_autosubscribe* subscribes a user to a specific
mailbox if this is initiated by an auto created action for a specific
mailbox. The option: *mail\_plugins* enables the sieve scripting module
in dovecot. The configuration file `90-sieve.conf` needs the following
adjustments:

        plugin {
            sieve = ~/.dovecot.sieve
            sieve_dir = ~/sieve
            sieve_default = /var/lib/dovecot/sieve/default.sieve
            sieve_global_dir = /var/lib/dovecot/sieve
        }
                

The *sieve* configuration option is the location where users can save
their sieve rules. The *sieve\_dir* configuration option is the
directory of a user which can hold multiple sieve scripts. The
configuration option *sieve\_default* is used to execute a default sieve
script. If a user has a personal sieve configuration file in its home
directory then the global configuration file is overruled. The option
*sieve\_global\_dir* identifies a global directory to contain multiple
global sieve scripts. After configuration the services should be
restarted with `service postfix restart` and ` service dovecot restart`.

###   Sieve syntax

The *sieve* syntax is easy to understand. It consists of three basic
parts: Control, Test and Action commands. The control command controls
the flow of the code. They affect how the commands will be carried out.
The test command will be used in conjunction with control commands to
specify a condition that could lead to an action. The action command
will be executed after a condition is evaluated to true. You can also
use single-line comments starting with a "\#" and multi-line comments
starting with "/\*" and ending with "\*/" to clarify sieve rules.
Example:

        # comment
        require ["extension"];

        /* This is multi
           line comment */
                    
        # if -> control command
        if <condition> { 
           action1; 
           action2;
           ...
           stop; #end processing
                    

Sievevacation extension Sieve also offers an auto-responder
functionality by using the `vacation>` extension. Below is an example
shown that uses the vacation extension.

        require ["fileinto", "vacation"];

        vacation
            # Reply at most once a day to a same sender
        :days 1
                :subject "Out of office reply"
        # List of additional recipient addresses which are included in the auto replying.
        # If a mail's recipient is not the envelope recipient and it's not on this list,
        # no vacation reply is sent for it.
        :addresses ["j.doe@company.dom", "john.doe@company.dom"]
            "I'm out of office, please contact Joan Doe instead.
        Best regards
        John Doe";
                                    

The "vacation" extension provides several options, namely:

-   `:days number` - Is used to specify the period where addresses are
    kept and not responded to (in days).

-   `:subject string` - Specifies the subject line attached to any
    vacation response.

-   `:from string` - Specifies an alternate to use in the From field of
    vacation messages.

-   `:addresses string-list` - Specifies additional email addresses to
    the recipient.

-   `:mime` - Specifies arbitrary mime content. For example to specify
    multiple vacation messages in different languages.

-   `:handle string` - Tells sieve to treat two vacation actions with
    different arguments as the same command for response tracking

-   *reason: string* - The actual message

Example:

        require "vacation";
        if header :contains "subject" "lunch" {
               vacation :handle "ran-away" "I'm out and can't meet for lunch";
        } else {
               vacation :handle "ran-away" "I'm out";
        }
                    

####  Control commands

The control commands in sieve are the basic `if`, `else` and `elsif`
control statements. If the test condition is evaluated to true then the
associated action will be executed. In the control statements the
following tagged arguments can be used: `:contains`, `:is`, `:matches`,
`:over`, and `:under` as shown in the upcoming sieve examples. The
`require` control command is used to declare optional extensions at the
beginning of a script (e.g. fileinto) and the `stop` command ends all
processing of the script. Example:

        require "fileinto";
        if header :contains "from" "lottery" {
            discard;
        } elsif header :contains ["subject"] ["$$$"] {
                discard;
            } else {
                fileinto "INBOX";
            }
                

Example:

        if header :contains "subject" "money" { 
           discard; 
           stop; 
        }
                

####  Test commands

The control commands as stated in the previous section can support
different test commands, namely: `address`, `allof`, `anyof`, `exists`,
`false`, `header`, `not`, `size` and `true`.

With the address command you can only test if an email adres is in the
header. If the `to` header contains "John Doe \<john\@doe.com\>", then
the test would evaluate to false. If the `to` address contains
"john\@doe.com" then the test would be true because only the address is
evaluated. Example:

        require "fileinto";

        if address :is "to" "john@doe.com" {
           fileinto "john";
        }
                

The `allof` command is a logical "AND" meaning all conditions should be
evaluated to true for further action. Example:

        if allof (header :contains "from" "Bofh", header :contains "to" "abuse")
        {
            fileinto "spam";
        }
                

The `anyof` command is a logical "OR" meaning ANY condition should be
evaluated to true for further action. Example:

        if anyof (size :over 1M, header :contains "subject" "big file attached")
        {
            reject "I don't want messages that claim to have big files.";
        }           
                

The `exists` command tests if a header exits with the message. All
headers must return true for any action being executed. Example:

        if exists "x-custom-header" 
        {
            redirect "admin@example.com";
        }
                

The `false` command simply returns false.

The `header` command tests if a header matches the condition set by the
argument and evaluates to true. Example:

        if header :is ["subject"] "make money fast" {
                  discard; 
              stop;
        }
                

The `not` command should be used with another test. This command negates
the other test for the action to be taken. The example below means that
if the message does NOT contain "from" and "date" then the discard
action will be taken. Example:

        if not exists ["from", "date"] 
        { 
           discard; 
        }
                

The `size` command is used to specify the message size to be higher or
lower than a specified value in order to evaluate the condition to true.
The command accepts tagged arguments `:over` and `:under` and you can
use M after the specified value for megabytes, K for kilobytes and no
letter for bytes. Example:

        if size :over 500K {
           discard;
        }
                

The `true` command simply returns true.

####  Action commands


The action commands are being executed after a test command is evaluated
to true or operate on their own. The action commands are: `keep`,
`fileinto`, `redirect` and `discard`. The `keep` action commands causes
the message to be saved in the default location. The `fileinto` action
command is an optional command and can be used by using
`require "fileinto"` control command in the beginning of the script. If
the test command is evaluated to true then the message is moved into the
defined mailbox. Example:

        if attachment :matches ["*.vbs", "*.exe"] {
            fileinto "INBOX.suspicious";
        }
                

The `redirect` command redirects the message to the address that is
specified in the argument without tampering the message. Example:

        if exists "x-virus-found" {
           redirect "admin@example.com";
        }
                

The `discard` command causes the message silently deleted without
sending any notification or any other message. Example:

        if size :over 2M { 
          discard; 
        }
                
##  Mbox and maildir storage formats

Mbox and maildir are email storage formats. Postfix and Dovecot support
the two email storage formats where maildir is the recommended format.

###   Mbox format

Mbox is the traditional email storage format. In this format there is
only one regular text file which serves as the user's mailbox.
Typically, the name of this file is `/var/spool/mail/<user name>`. Mbox
locks the mailbox when an operation is performed on the mailbox. After
the operation the mailbox is unlocked.

####  Advantages:

-   Mbox format is universally supported

-   Appending new email is fast

-   Searching inside single mailbox is fast

####  Disadvantages:

-   Mbox is known for locking problems

-   The mbox format is prone to corruption

###   Maildir format

Maildir is the newer email storage format. A directory maildir is
created for each email user, typically in the users' home directories.
Under this maildir directory by default three more directories exist:
new, cur and tmp.

####  Advantages:

-   Locating, retrieving and deleting a specific email is fast,
    particularly when a email folder contains hundreds of messages

-   Minimal to no file locking needed

-   Can be used on a network file system

-   Immune to mailbox corruption (assuming the hardware will not fail)

####  Disadvantages:

-   Some filesystems may not efficiently handle a large number of small
    files

-   Searching text, which requires all email files to be opened is slow

###   Recipe differences between mbox and maildir for procmailrc

Before copying the recipes from this page into your procmailrc file,
remember to adapt them to your particular maildir/mbox format, taking
into consideration that the name of maildir folders end in \"/\". You do
not need to lock the file when using maildir format (:0 instead of :0:).

In mbox the format is:

        :0:
        recipe
        directory_name
                

While in maildir it would be:

        :0
        recipe
        directory_name/
                
