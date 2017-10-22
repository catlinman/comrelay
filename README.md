
# Comrelay #

Command line based HTTP/HTTPS server that allows requests to be routed to
server side commands via secret key form encoded request authentication.

## Setup ##

To install this module, run the following commands:

	$ perl Makefile.PL
	$ make
	# make install

Once you have installed Comrelay you can use the main command.

    $ comrelay [help] [list] [add] [remove] [start]

If all else fails you can run Comrelay directly from its *bin* directory.
This however makes managing of configuration files harder as they will be
created in the project directory.

    $ perl bin/Comrelay.pm [help] [list] [add] [remove] [start]

For additional information for the given commands please read the help that can
be viewed with the help command.

## Configuration ##

Comrelay creates its configuration files in the current execution directory as
the executing user with their permissions during runtime. This means that
running any Comrelay commands that modify the configuration must be executed in
the directory where the configuration is stored as otherwise the configuration
will not be found.

At the same time configuration should be handled through Comrelay itself as it
guarantees that there will be no errors in the syntax. Still, the user is
granted the option of modifying and generally managing the configuration file
with its CSV syntax on their own if they please.

The reasoning for this design decision can be derived from the following.

1. The application will be run from a service which specifies an execution
directory, user and permissions and as such always reading and writing in the
same location. Managing the service and sandboxing is a lot easier this way.

2. Running multiple servers is simpler as servers can be split just by executing
the application in different directories making server instance management easier
and data collisions a lot more unlikely.

3. After working with shared memory between servers and command line interaction
it became apparent that this would not work if multiple Comrelay servers were
running at the same time. As such the *.comrelay_status* file convention was
chosen which allows servers to be managed and handled directly from their
execution directory. Of course this is still done via a request but it is a lot
less messy than using shared memory and having servers work around each other
all the time.

## Security ##

It is advised to bind the server to localhost as to better handle access to
paths such as the admin route which is used for Comrelay to interact with a
running server. To do this, another web server such as nginx must proxy pass
outside connections while restricting access to the admin routes.

An example template configuration file can be found in the nginx directory of
this repository.

It is also advised to separate Comrelay with custom users. The reasoning for
this should be rather self explanatory as commands that are executed run as
the given user with their permissions. As such, running Comrelay as root is
highly discouraged. Make sure you know what you are doing before adding certain
commands and allowing access to them.

## License ##

This repository is released under the MIT license. For more information please
refer to [LICENSE](https://github.com/catlinman/comrelay/blob/master/LICENSE)
