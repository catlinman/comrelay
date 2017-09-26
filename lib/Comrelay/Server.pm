
# Assign this submodule to the main package.
package Comrelay::Server;

# Basic Perl configuration.
use strict;
use warnings;

# Server library.
use HTTP::Server::Brick;
use HTTP::Status;

my $server;

sub start {
    my ($port, $fork) = @_;

    $port ||= 9669;
    $fork ||= 0;

    $server = HTTP::Server::Brick->new(
        port => $port,
        fork => $fork
    );

    # Start mounting inputs
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

sub refresh {

}

sub stop {
    $server->stop;
}

1;
