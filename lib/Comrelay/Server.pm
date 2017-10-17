
# Assign this submodule to the main package.
package Comrelay::Server;

# Basic Perl configuration.
use strict;
use warnings;

# Server and routing library.
use HTTP::Server::Brick;
use HTTP::Status;

# Load submodules.
use Comrelay::Routes;

# Main server instance reference.
my $server;

BEGIN {
    require Exporter;

    # Set the version for version checking.
    our $VERSION = 1.00;

    # Inherit from Exporter to export functions and variables.
    our @ISA = qw(Exporter);

    # Functions and variables which are exported by default.
    our @EXPORT = qw(start);

    # Functions and variables which can be optionally exported.
    our @EXPORT_OK = qw();
}

sub _log {
    my ($text) = @_;

    my $localtime = localtime;
    print("[$localtime] [$$] $text\n");
}

sub _update {
    # Load route information.
    my %routes = Comrelay::Routes::load;

    foreach my $route (keys %routes) {
        # Get the data array information.
        my $secret = $routes{$route}[0];
        my $command = $routes{$route}[1];

        # Mount the new route.
        $server->mount("/routes/$route/$secret" => {
            handler => sub {
                my ($req, $res) = @_;

                _log "Running '$command'.";
                my $output = `$command`;

                # Return the output.
                $res->header('Content-type', 'text/plain');
                $res->add_content("Server has run the command '$command' as $ENV{USERNAME}.\n$output");

                1;
            },
            wildcard => 0,
        });
    }
}

sub start {
    # Get and handle arguments.
    my ($port) = @_;

    $port ||= 9669;

    # Write a temporary file with the port for other Comrelay processes to use.
    open(my $handle, '>', '.comrelay_port');
    print $handle "$port";
    close $handle;

    # Handle keyboard interrupts and clear memory.
    $SIG{INT} = sub {
        # Delete the temporary port designation file.
        unlink('.comrelay_port');

        exit;
    };

    # Create a new server instance.
    $server = HTTP::Server::Brick->new(
        port => $port
    );

    # Start mounting inputs.
    $server->mount('/' => {
        handler => sub {
            my ($req, $res) = @_;

            $res->header('Content-type', 'text/plain');
            $res->code(200);

            1;
        },
        wildcard => 1,
    });

    # Start mounting inputs.
    $server->mount('/admin/update' => {
        handler => sub {
            my ($req, $res) = @_;

            # Reload the routes file and mount new routes.
            _update;

            $res->header('Content-type', 'text/plain');
            $res->add_content("Successfully updated routes.");

            1;
        },
        wildcard => 0,
    });

    # Load routes file and mount routes.
    _update;

    $server->start;
}

1;
