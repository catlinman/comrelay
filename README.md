
# Comrelay #

Command line based HTTP server that allows requests to be routed to
server side commands via secret key form encoded request authentication.

Notice: Currently secret key passing is not enabled. The key is part of the URL
for debugging reasons at this point.

## Setup ##

To install this module, run the following commands:

	$ perl Makefile.PL
	$ make
	# make install

Once you have installed Comrelay you can use the main command.

    $ comrelay [help] [list] [add] [remove] [server]

For additional information for the given commands please read the help that can
be viewed with the help command.

## Security ##

It is advised to bind the server to better handle access to paths such as the
admin route which is used for Comrelay to interact with a running server. To do
this another web server such as nginx can proxy pass outside connections while
restricting access to the admin routes.

An example configuration can be found in the nginx directory of this repository.

It is also advised to separate Comrelay with custom users. The reasoning for
this should be rather self explanatory as commands that are called are run as
the given user and their permissions. As such, running Comrelay as root is
highly discouraged. Make sure you know what you are doing before adding certain
commands and allowing access to them.

## License ##

This repository is released under the MIT license. For more information please
refer to [LICENSE](https://github.com/catlinman/comrelay/blob/master/LICENSE)
