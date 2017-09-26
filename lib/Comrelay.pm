#!/usr/bin/perl

# Main package.
package Comrelay;

# Basic Perl configuration.
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/";

# Load submodules.
use Comrelay::Server;
use Comrelay::Data;

# CLI helpers.
use Getopt::Long;

sub main {
    # Get the primary command and pop it off of @ARGV.
    my $command = shift;

    $command ||= 0;

    if($command eq 'server') {
        print 'Starting the server.';

        my $port = 9669;
        my $fork = 0;

        GetOptions (
            'port|p=i' => \$port,
            'fork' => \$fork
        );

        Comrelay::Server->start;

    } elsif(!$command || $command eq 'help') {
        print 'Test'

    } else {
        print "'$command' is not a recognized command. Use 'help' to print a list of available commands."
    }
}

# Execute the main entry point.
main(@ARGV);
