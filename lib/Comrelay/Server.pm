
# Assign this submodule to the main package.
package Comrelay::Server;

# Basic Perl configuration.
use strict;
use warnings;

# Load submodules.
use Comrelay::Routes;

# Server and routing library.
use HTTP::Server::Brick;
use HTTP::Daemon::SSL;

# Name of the routes and port file.
my $portfilename = '.comrelay_port';

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
    my ($port, $bind, $ssl_key, $ssl_cert) = @_;

    $port ||= 9669; # Local port to run the server on.
    $bind ||= ''; # Bind host address. Binds to the hostname by default.

    # Specifying both of these enables SSL.
    $ssl_key ||= 0; # SSL key file path.
    $ssl_cert ||= 0; # SSL certificate file path.

    # Write a temporary file with the port for other Comrelay processes to use.
    open my $portfilehandle, '>', $portfilename or die "Server: Could not open '$portfilename' $!.\n";;
    print $portfilehandle "$port";
    close $portfilehandle;

    # Handle keyboard interrupts and clear memory.
    $SIG{INT} = sub {
        # Delete the temporary port designation file.
        unlink $portfilehandle or die "Could not delete the file!\n";

        exit;
    };

    # Create a new server instance.
    if($ssl_key and $ssl_cert) {
        $server = HTTP::Server::Brick->new(
            daemon_class => 'HTTP::Daemon::SSL',
            daemon_args => [
                LocalAddr => $bind,
                SSL_key_file  => $ssl_key,
                SSL_cert_file => $ssl_cert,
            ],
            port => $port
        );

    } else {
        $server = HTTP::Server::Brick->new(
            daemon_args => [
                LocalAddr => $bind,
            ],
            port => $port
        );
    }
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
