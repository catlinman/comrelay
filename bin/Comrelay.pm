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
sub say {print @_, "\n"}

sub main {
    # Get the primary command and pop it off of @ARGV.
    my $command = shift;

    # Make sure that the variable is set.
    $command ||= 0;

    if($command eq 'start') {
        # Set defaults.
        my $port = 9669;
        my $bind = '';
        my $ssl_key = 0;
        my $ssl_cert = 0;

        # Get command line options.
        GetOptions (
            'port|p=i' => \$port,
            'bind|b=s' => \$bind,
            'key|k=s' => \$ssl_key,
            'cert|c=s' => \$ssl_cert,
        );

        if($ssl_key and $ssl_cert) {
            say "Using $ssl_key and $ssl_cert for SSL.";
            say "Starting a Comrelay HTTP server with SSL on port $port.";

        } else {
            say "Starting a Comrelay HTTP server on port $port.";
        }

        # Start the server.
        Comrelay::Server::start($port, $bind, $ssl_key, $ssl_cert);

    } elsif($command eq 'add') {
        # Set defaults.
        my $route = "";
        my $secret = "";
        my $field = "";
        my $command = "";

        # Get command line options.
        GetOptions (
            'route|r=s' => \$route,
            'secret|s=s' => \$secret,
            'field|f=s' => \$field,
            'command|c=s' => \$command,
        );

        die "Required arguments not specified. Use 'help' for reference.\n" if not $route or not $command;

        # Set the new route with a command and an optional secret.
        Comrelay::Routes::add($route, $secret, $field, $command);

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
            my $field = $routes{$route}[1];
            my $command = $routes{$route}[2];

            # Print a nicely formatted string for each entry.
            say "$index. Route: $route\n- Secret: $secret\n- Field: $field\n- Command: $command";

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

comrelay server [--port|p] [--bind|b] [--key|k --cert|c]

=head1 OPTIONS

=over 8

=head2 B<help>

Display help and usage.

=head2 B<list>

Lists routes, their registered command and the given secret.

=head2 B<add>

Register a new route and a corresponding command.

=over 8

=item B<--route|r>

Specifies the route to relay to the command.

=item B<[--secret|s]>

Optional secret to use. Is randomly generate if not specified.

=item B<[--field|f]>

Optional field to use. Is set to 'secret' by default.

=item B<--command|c>

The command to be registered for the route.

=back

=head2 B<remove>

Register a new route and a corresponding command.

=over 8

=item B<--route|r>

Specifies the route to be removed.

=back

=head2 B<start>

Starts the main HTTP server. For SSL support both a key and a
certificate must be specified.

=over 8

=item B<--port|p>

The port to run the HTTP server on. Defaults to "9669".

=item B<--bind|b>

Address the server should bind to. Defaults to the hostname.

=item B<[--key|k --cert|c]>

Path of the SSL key tand certificate to enable SSL.

=back
