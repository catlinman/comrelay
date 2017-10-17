#!/usr/bin/perl

# Main package.
package Comrelay;

# Basic Perl configuration.
use strict;
use warnings;
use feature qw(say);

# Library preperation.
use lib qw(../lib/);

# Load submodules.
use Comrelay::Server;
use Comrelay::Routes;

# CLI helpers.
use Getopt::Long;
use Pod::Usage;

# Implement a quick say command.
sub say { print @_, "\n" }

sub main {
    # Get the primary command and pop it off of @ARGV.
    my $command = shift;

    # Make sure that the variable is set.
    $command ||= 0;

    if($command eq 'server') {
        # Set defaults.
        my $port = 9669;
        my $fork = 0;

        # Get command line options.
        GetOptions (
            'port|p=i' => \$port,
        );

        say "Starting the server on port $port.";

        # Start the server.
        Comrelay::Server::start($port, $fork);

    } elsif($command eq 'add') {
        # Set defaults.
        my $route = "";
        my $secret = "";
        my $command = "";

        # Get command line options.
        GetOptions (
            'route|r=s' => \$route,
            'secret|s=s' => \$secret,
            'command|c=s' => \$command,
        );

        die "Required arguments not specified. Use 'help' for reference.\n" if not $route or not $command;

        # Set the new route with a command and an optional secret.
        Comrelay::Routes::add($route, $secret, $command);

    } elsif($command eq 'remove') {
        # Set defaults.
        my $route = "";

        # Get command line options.
        GetOptions (
            'route|r=s' => \$route,
        );

        die "Required arguments not specified. Use 'help' for reference.\n" if not $route;

        # Remove the route.
        Comrelay::Routes::remove($route);

    } elsif($command eq 'list') {
        my %routes = Comrelay::Routes->load;

        say "There are no defined routes." if(keys %routes == 0);

        my $index = 1;
        foreach my $route (keys %routes) {
            # Get the data array information.
            my $secret = $routes{$route}[0];
            my $command = $routes{$route}[1];

            # Print a nicely formatted string for each entry.
            say "$index. $route (Secret: $secret) \-\> $command";

            $index++; # Increment the index.
        }

    } elsif(not $command or $command eq 'help') {
        pod2usage(0);

    } else {
        say "'$command' is not a recognized command. Use 'help' to view a list of available commands."
    }

    exit 0;
}

# Execute the main entry point.
main(@ARGV);

=head1 NAME

Comrelay - Command line based web hook HTTP server that allows requests to be
routed to server side commands via secret key form encoded request authentication.

=head1 SYNOPSIS

comrelay help

comrelay list

comrelay add --route|r --command|c

comrelay remove --route|r

comrelay server [--port|p] [--fork|f]

=head1 OPTIONS

=head2 help

Display help and usage.

=head2 list

Lists routes, their registered command and the given secret.

=head2 add

Register a new route and a corresponding command.

=head3 ARGUMENTS

=head4 --route|r

Specifies the route to relay to the command.

=head4 --command|c

The command to be registered for the route.

=head4 [--secret|s]

Optional secret to use. Is randomly generate if not specified.

=head2 remove

Register a new route and a corresponding command.

=head3 ARGUMENTS

=head4 --route|r

Specifies the route to be removed.

=head2 server

Starts the main HTTP server.

=head3 ARGUMENTS

=head4 --port|p

Specifies the port to run the HTTP server on. Defaults to "9669".
