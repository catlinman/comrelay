
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

## License ##

This repository is released under the MIT license. For more information please
refer to [LICENSE](https://github.com/catlinman/comrelay/blob/master/LICENSE)
