
# Assign this submodule to the main package.
package Comrelay::Server;

# Basic Perl configuration.
use strict;
use warnings;

# Server library.
use HTTP::Server::Brick;
use HTTP::Status;

BEGIN {
    require Exporter;

    # Set the version for version checking.
    our $VERSION = 1.00;

    # Inherit from Exporter to export functions and variables.
    our @ISA = qw(Exporter);

    # Functions and variables which are exported by default.
    our @EXPORT = qw(start_server refresh_server stop_server);

    # Functions and variables which can be optionally exported.
    our @EXPORT_OK = qw();
}

my $server;

sub start_server {
    my ($port, $fork) = @_;

    $port ||= 9669;
    $fork ||= 0;

    $server = HTTP::Server::Brick->new(
        port => $port,
        fork => $fork
    );

    # Start mounting inputs.
    $server->mount('/' => {
        handler => sub {
            my ($req, $res) = @_;

            $res->add_content('Success.');

            1;
        },
        wildcard => 0,
    });

    $server->start;
}

sub refresh_server {

}

sub stop_server {
    $server->stop;
}

1;
