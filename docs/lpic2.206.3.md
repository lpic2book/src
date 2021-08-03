##  Notifying users on system-related issues (206.3)

Candidates should be able to notify the users about current issues
related to the system.

###   Key Knowledge Areas

- Automate communication with users through logon messages

- Inform active users of system maintenance

###   Terms and Utilities

-   `/etc/issue`

-   `/etc/issue.net`

-   `/etc/motd`

-   `wall`

-   `/sbin/shutdown`

-   `/bin/systemctl`


###   The `/etc/issue`, `/etc/issue.net`, and `/etc/motd` files

The `/etc/issue`, `/etc/issue.net` and `/etc/motd` files are used to
send simple messages to users that log in to the system. The `/etc/motd`
is used to display a message after the user has authenticated
successfully. The `/etc/issue` on the other hand is used to send a
message to the user before they login. This message is only displayed to
users that log in using the console and will often contain some
information about the system like kernel version and architecture. The
`/etc/issue.net` file has the same purpose as the `/etc/issue` file but
is used for insecure logins using `telnet`. It is possible to use the
`/etc/issue.net` file for `ssh` as well. For this to work you need to
add or modify the following line in `/etc/ssh/sshd_config`:

        Banner /etc/issue.net
            

When using `/etc/issue.net` with ssh you should note that the special
sequences may not work.

###   The `wall` command

wall `wall` is used to broadcast a message of at most 22 lines to all
interactive terminals. By default the command can be used by any user,
but often is reconfigured so only root can use it. A user not wishing to
receive broadcast messages may use the `mesg` to write disable their
terminals. The broadcaster may use the `finger` command to see which
terminals are write disabled.

You can specify two options with the `wall` command: the `-n` option,
which only works for the root user and the message itself. The `-n`
suppresses the standard broadcast banner and replaces it with a remote
broadcast banner. This option has meaning only when `wall` is used over
the `rpc.walld` daemon. The second argument, the message itself can also
be typed on `stdin`, in which case it must be terminated with an EOF
(end of file, in most cases [Ctrl+D]{.keycombo}).

###   The `shutdown` command communication.

shutdown As its name suggests, the `shutdown` command is used to
shutdown a server gracefully, stepping down through the run level kill
scripts, and optionally halting, or rebooting the server. The shutdown
command itself is not discussed here, and this small section explains
only the communicative steps that `shutdown` takes before, and during
the system shutdown.

The last argument to the `shutdown` may optionally be used to broadcast
some custom message explaining the purpose of the shutdown, and when it
is expected to be returned to production. For example:

        # shutdown -H +10 Server halting in 10 minutes for change change number. Expected up at 00:00:00. 
                

Shutdown can be used with the `-k`. This makes `shutdown` do a
'dry-run': it emulates the shutdown, but does NOT shut down the
system.

When you use the `-k` options you can append broadcast messages as part
of the command line too, like in a "real" `shutdown`.

**Note**
Please note that `shutdown` `-k` will still temporarily disallow user
logins as it will create the `/etc/nologin` file. It will be removed
after the 'dry run' but your users will not be able to log in into the
system as long as it is there.

In the event that a running `shutdown` needs to be cancelled, the
`shutdown` may be called with the `-c` option, and again a broadcast
message added to the command line to inform the users of the U-turn. As
with all forms of message broadcasts, the receiving terminals must be
write enabled.

###   The `systemctl` command communication,

systemctl The `systemctl` the central management tool for the systemd
init system. `systemctl` can be used to manage services, system states
(runlevels) and config files.

####  Managing services

#### Starting and stopping services

Where you used the `service` command in sysVinit you will now use the
systemctl command to manage services. If you are using a non-root user
to run the command you will have to use sudo. The following example
shows starting a service using the `start` command:

        $ systemctl start application.service
                    

Because systemd knows you are running the system management commands on
services you can also leave the .service suffix. For clarity we will
keep using the suffix in the commands.

        $ systemctl start application
                    

For some programs it is possible to start the application multiple times
with different configuration files. In this case you can pass the name
of the config file to the command using the @-sign. For example, to
start the openvpn service twice with different configuration files you
can use the following commands:

        $ systemctl start openvpn@config1.service
        $ systemctl start openvpn@config2.service
                    

Because they changed the order of the parameters for the systemctl
command you can also start and stop multiple services at once: The
following example show stopping multiple services using the `stop`
command:

        $ systemctl stop application1.service application2.service
                    

#### Restarting and reloading services

For restarting a service you can use the `restart` command:

        $ systemctl restart application.service
                    

If an application is able to reload it's configuration you can also use
the `reload` command:

        $ systemctl reload application.server
                    

If you not sure if a service can reload it's configuration you can also
use the `reload-or-restart` command. This will reload is configuration
if it is available, else it will restart the application:

        $systemctl reload-or-restart application.service
                    

#### Enabling and disabling service

The previous commands are useful for starting and stopping services in
the current session. If you want a service to start at boot, for which
sysVinit use the `chkconfig` command, you have to enable them using
`systemctl`:

        $ systemctl enable application.service
                    

This `enable` command will create a symbolic link from this systems copy
of the service file (which is usually found in /lib/systemd/system or
/etc/systemd/system) to the directory where systemd looks for autostart
files (usually /etc/systemd/system/some\_target.target.wants). To
disable a service from start at boot you use the `disable` command:

        $ systemctl disable application.service
                    

This will remove the symbolic link that indicate that the service should
start at boot.

**Note**
Remember that enabling a service will not start it in the current
session. To start and enable a service you will need to issue both the
start and enable command

#### Checking the status of services

To check the current status of a service you can use the `status`
command:

        $ systemctl status application.service
                    

This command will give you the current state of the service, the cgroup
hierarchy, and the first few log lines. It gives you a nice overview of
the current status, and notifying you of any problems. For example the
following output for the sshd service:

        $ systemctl status sshd.service
          - sshd.service - OpenSSH server daemon
             Loaded: loaded (/usr/lib/systemd/system/sshd.service; enabled; vendor preset: enabled)
             Active: active (running) since Fri 2016-12-16 08:18:17 CET; 4h 58min ago
               Docs: man:sshd(8)
                     man:sshd_config(5)
            Process: 1033 ExecStart=/usr/sbin/sshd $OPTIONS (code=exited, status=0/SUCCESS)
           Main PID: 1067 (sshd)
              Tasks: 1 (limit: 4915)
             CGroup: /system.slice/sshd.service
                     `-1067 /usr/sbin/sshd
          
          Dec 16 08:18:17 localhost.localdomain systemd[1]: Starting OpenSSH server daemon...
          Dec 16 08:18:17 localhost.localdomain systemd[1]: sshd.service: PID file /var/run/sshd.pid not readable (yet?) after start: No such file or directory
          Dec 16 08:18:17 localhost.localdomain sshd[1067]: Server listening on 0.0.0.0 port 22.
          Dec 16 08:18:17 localhost.localdomain sshd[1067]: Server listening on :: port 22.
          Dec 16 08:18:17 localhost.localdomain systemd[1]: Started OpenSSH server daemon.
                    

There are also commands available for checking specific states which can
be particularly useful for using them in scripts. For example to check
if as service is currently active you can use the `is-active` command:

        $ systemctl is-active application.service
                    

This command will show if the application is active or inactive. If the
application is active it will return an exit code of "0". To see if an
application is enabled you can use the `is-enabled` command:

        $ systemctl is-enabled application.service
                    

This command will return wheter the application is enbled or disable and
will return an exit code of "0" if the application is enabled. To check
if an application has failed you can use the `is-failed` command:

        $ systemctl is-failed application.service
                    

This command wil return active if the application is running, failed if
an error has occured, and inactive or unknown the the service was
intentionally stopped. It will return an exit code of "0" if the service
has failed.

####  System state overview

The commands so far have been useful for managing single services. For
exploring the the current state of the system there ar a number of
systemctl commands that provide more information.

#### Listing current units

To get a list of all the active units that systemd knows about you can
use the `list-units` command:

        $ systemctl list-units
                    

This command only shows a list of the currently active units. Then
output has the following columns:

        UNIT: The systemd unit name
        LOAD: Whether the unit's configuration has been parsed by systemd. The
              configuration of loaded units is kept in memory.
        ACTIVE: A summary state about whether the unit is active. This is usually a
                fairly basic way to tell if the unit has started successfully or not.
        SUB: This is a lower-level state that indicates more detailed information
             about the unit This often varies by unit type, state, and the actual
             method in which the unit runs.
        DESCRIPTION: A short textual description of what the unit is/does/
                    

Because the `list-units` command only shows the active units by default,
all of the entries above will show "loaded" in the LOAD colymn and
"active" in the ACTIVE column. This is also the default behaviour of
systemctl when called without additional commands, so you will see the
same output if you call systemctl without arguments.

        $ systemctl
                    

You can also tell systemctl to output different information by adding
additional flags. For instance, to show all units that systemd has
loaded, whether they are active or not, you can use the `--all` flag:

        $ systemctl list-units --all
                    

This will show all units that systemd loaded or attempted to load,
regardless of it's current state on the system. It is also possible to
filter units by the current state, for this you can use the `--state=`
flag. You will have to keep the `--all` flag so that systemctl allows
non-active units to be disaplayed. For example, if you wish to see all
inactive units you can issue the following command:

        $ systemctl --list-units --all --state=inactive
                    

Another filter you can use is the `--type=` flag. You can tell systemctl
to only show the unit types you are interested in. For example, to only
show active service units you can use the following command:

        $ systemctl --list-units --type=service
                    

#### Listing unit files

The `list-units` command we just used only shows units that systemd has
attempted to load into memory. Systemd will only read units that it
thinks it need so this will not necessarily include all availble units
on the system. To see every unit file that is available in the systemd
paths you can use the `list-unit-files` command instead:

        $ systemctl list-unit-files
                    

Units are representations of resources that systemd knows about. Because
systemd has not necessarily read all of the unit definitions in this
view it only presents information about hte files themselves. The output
of this command shows two columns, the UNIT FILE and the STATE. The
STATE column will usually be "enabled","disabled","static" or "masked".
For this command static means that the unit file doesn't contain an
"install" section which is necessary to enable a service. A unit that
has a state of static can't be enable will run a one-off action or is
only used as a dependency of another unit. We will cover what "masked"
means later.

####  Unit management

So far we have been working with services an displaying information
about the unit files that systemd knows about. With some additional
commands we can get more specific information about units.

#### Displaying a unit file

To display the unit file that systemd has loaded into it's memory you
can use the `cat` command (which was added in systemd version 209). To
see the unit file of the atd scheduling daemon you can use to following
command:

        $ systemctl cat atd.service

        [Unit]
        Description=ATD daemon

        [Service]
        Type=forking
        ExecStart=/usr/bin/atd

        [Install]
        WantedBy=multi-user.target
                    

The output of this command is the unit file as it's known by the
current systemd process. This is important to know if you've recently
modified the unit files or if you're overriding certain options.

####  Displaying dependencies

If we want to see the dependency tree of a service we can use the
`list-dependencies` command:

        $ systemctl list-dependencies sshd.service
                    

This command wil show a hierarchical view of the dependencies that must
be dealt with in order to start the unit. Dependencies, in this context,
are the units that are required or wanted by the units above it.

        sshd.service
        |-system.slice
        `-basic.target
          |-microcode.service
          |-rhel-autorelabel-mark.service
          |-rhel-autorelabel.service
          |-rhel-configure.service
          |-rhel-dmesg.service
          |-rhel-loadmodules.service
          |-paths.target
          |-slices.target

        . . .
                    

Recursive dependencies are only displayed for target units which
indicate system states. To list all dependencies you can include the
`--all` flag.

To get the reverse dependencies you can add the `--reverse` flag to the
command. Other useful flags are the `--before` and `--after` flags which
can be used to show units to depend on the specified unit to start
before or after them respectivly.

#### Checking unit properties

To get the low-level properties of a unit you can use the `show`. This
will display a list of properties in a key=value format:

        $ systemctl show sshd.service

        Id=sshd.service
        Names=sshd.service
        Requires=basic.target
        Wants=system.slice
        WantedBy=multi-user.target
        Conflicts=shutdown.target
        Before=shutdown.target multi-user.target
        After=syslog.target network.target auditd.service systemd-journald.socket basic.target system.slice
        Description=OpenSSH server daemon

        . . .
                    

To get a single property you can pass the `-p` flag with the property
name. For example, to see the conflicts that the sshd.service unit has
you can use the following command:

        $ systemctl show sshd.service -p Conflicts

        Conflicts=shutdown.target
                    

#### Masking and unmasking units

In the service management section we showed how to stop or disable a
service, but systemd also has the ability to mark a unit as completely
unstartable. To do this it creates a symbolic link to `/dev/null` which
is called masking a unit. To do this you can use the `mask` command:

        $ systemctl mask nginx.service
                    

This wil prevent the Nginx service from being start manually or
automatically for as long as it's masked. If you check with the
`list-unit-files` command you will see that the service is now listed as
masked:

        $ systemctl list-unit-files

        . . .

        kmod-static-nodes.service              static
        ldconfig.service                       static
        mandb.service                          static
        messagebus.service                     static
        nginx.service                          masked
        quotaon.service                        static
        rc-local.service                       static
        rdisc.service                          disabled
        rescue.service                         static

        . . .
                    

If you try to start the service you will see a message like this:

        $ systemctl start nginx.service

        Failed to start nginx.service: Unit nginx.service is masked.
                    

To unmask a service you can use the `unmask` command:

        $ systemctl unmask nginx.service
                    

This will return the unit to it's previous start allowing the service
to be started or enabled.

####  Editing unit files

The systemctl command also has the possibility to edit unit files if you
need to make adjustments. This functionality was added in systemd
version 218.

The `edit` will open a unit file snipper by default:

        $ systemctl edit nginx.service
                

This will be a blank file that can be used to override or add properties
to the unit definition. A directory will be created within the
`/etc/systemd/system` directory which will have the name of the unit
with .d appended. For example, for the nginx.service, a directory
callend nginx.service.d will be created.

If you want to edit the full unit file, instead of adding a snippet, you
can pass the `--full` flag:

        $ systemctl edit --full nginx.service
                

This will load the current unit file into the editor where you can
modify it. When the editor exits the changes will be written to
`/etc/systemd/system`. This new file will take precedence over the
system unit definition (usually found somewhere in
`/lib/systemd/system`).

To remove any additions you have meid you can either remove the units .d
configuration directory or the modiefied service file from
`/etc/systemd/system`. For instance, to remove a snipper, you can type:

        $ rm -r /etc/systemd/system/nginx.service.d
                

To remove a full modified unit file you can type:

        $ rm /etc/systemd/system/nginx.service
                

After remove thile file or directory you should reload the systemd
process so that it no longer attempts to reference the file and reverts
back to using the system copies. You can do this by using the
`daemon-reload` command:

        $ systemctl daemon-reload
                

####  Adjusting the system start (runlevel) with targets

Targets are special unit files that describe a system state. Like other
units the files that define targets can be identified by their suffix
which in this case is `.target`. Targets don't do much themselves but
ar used to group other units together.

These targets can be used to bring the system to a certain state, much
like other init systems use runlevels. They are used as a reference for
when certain functions are available allowing you to specify the desired
state instead of the individual units needed to produce the same state.

For instance, there is a `swap.target` which is used to indicate that
swap is ready for use. Units that are part of this process can sync with
this target by indicating in their configuration files that they are
wanted by or required by the `swap.target`. Unit that require swap to be
available can specify this condition by using the wants, requires, and
after properties to indicate the natur of their relationship.

#### Getting and setting the default target

Systemd has a default target that is used when booting the system.
Satisfying the cascade of dependencies from that target will bring the
system into the desired state. To get the default target of your system
you can use the `get-default` command:

        $ sytemctl get-default

        multi-user.target
                    

If you want to set another target as the default you can use the
`set-default` command. For example, if you want to use the graphical
desktop as default you can change this with the following command:

        $ systemctl set-default graphical.target
                    

#### Listing available targets

You can get a list of the available targets using the `list-unit-files`
command in combination with the `--type=target` filter:

        $ systemctl list-unit-files --type=target
                    

Unlike with runlevels it's possible to have multiple targets active at
the same time. An active target indicates that systemd has attempted to
start all of the units tied to the target and has not tried to tear them
down again. To see all active targets use the following command:

        $ systemctl list-units --type=target
                    

#### Isolating targets

It's possible to start all the units that are associated with a target
and to stop all units that are not part of the dependency tree. The
command we can use for this is the `isolate` command. This is similar to
changing the runlevel in other init systems.

For example, if you are working in a graphical environment with
graphical.target active, you can shutdown the graphical system by
isolating the multi-user.target. Since multi-user.target is a dependency
of graphical.target and not the other way around, the isolate command
will stop all the graphical units.

You may wish to take a look at the dependencies of the target you're
isolating to make sure you don't stop any services that are vital to
you:

        $ systemctl list-dependencies multi-user.target
                    

When you're satisfied with the units that will be kept alive you can
isolate the target:

        $ systemctl isolate multi-user.target
                    

#### Using shortcuts for important events

Some targets are defined for important events like powering off or
rebooting. However `systemctl` also has some shortcuts that add a bit of
additional functionality.

For instance, to put the system into rescue (single-user in System V
init terms) mode you can just use the `rescue` instead of
`isolate rescue.target`:

        $ systemctl rescue
                    

This command will also provide the additional functionallity of alerting
all logged in users about the event in comparison with the isolate
command. To halt the system you can use the `halt` command:

        $ systemctl halt
                    

To initiate a full shutdown you can use the `poweroff` command:

        $ systemctl poweroff
                    

To reboot the system you can use the `reboot` command:

        $ systemctl reboot
                    

Not that most systems will link the shorter, more conventional, commands
for these operations so they will work properly with systemd. For
example, to reboot a system you can usually type:

        $ reboot
                    
