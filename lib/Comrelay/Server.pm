
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
my $statuspath = '.comrelay_status';

# Main server instance reference.
my $server;

# Hash storage of routes and their commands.
my %archiveroutes;

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

    # Iterate over archived routes and check if they are still present.
    foreach my $route (keys %archiveroutes) {
        # If a route was removed reset the handler.
        if(not $routes{$route}) {
            $server->mount("/routes/$route/" => {
                handler => sub {
                    my ($req, $res) = @_;

                    $res->header('Content-type', 'text/plain');
                    $res->code(404);

                    1;
                },
                wildcard => 0,
            });

            _log "Unmounted handler at /routes/$route.";
        }
    }

    foreach my $route (keys %routes) {
        # Get the data array information.
        my $secret = $routes{$route}[0];
        my $field = $routes{$route}[1];
        my $command = $routes{$route}[2];

        # Mount the new route.
        $server->mount("/routes/$route/" => {
            handler => sub {
                my ($req, $res) = @_;

                # Make sure the request is using the POST method and has a payload.
                $res->code(405) and return 1 if $req->method ne 'POST';
                $res->code(403) and return 1 if not $req->content;

                # Split the content by its delimiter.
                my @payload = split '&', $req->content;

                # Is incremented if successfully authenticated.
                my $approved = 0;

                # Iterate over payload entries and check that the access and secret match.
                for my $entry (@payload) {
                    my ($payloadfield, $payloadvalue) = split '=', $entry;

                    $approved = 1 if $payloadfield eq $field and $payloadvalue eq $secret;
                }

                if($approved) {
                    _log "Approved route '$route' with secret '$secret' via access of '$field'.";
                    my $output = `$command`;

                    _log "Executed command: '$command'. Command output: '$output'.";

                    # Get the username for logging
                    my $username = getlogin || getpwuid($<);

                    # Return the output.
                    $res->header('Content-type', 'text/plain');
                    $res->add_content("Server has run the command '$command' as $username.\n$output");
                    $res->code(200);

                    1;

                } else {
                    my $content = $req->content;
                    _log "Failed authentication for route '$route'. Payload: '$content'.";

                    $res->code(403);

                    1;
                }
            },
            wildcard => 0,
        });
    }

    # Store old routes. Required for removal of routes.
    %archiveroutes = %routes;
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
    open my $statushandle, '>', $statuspath or die "Server: Could not open '$statuspath' $!.\n";;
    print $statushandle "$port";
    close $statushandle;

    # Handle keyboard interrupts and clear memory.
    $SIG{INT} = sub {
        # Delete the temporary status port designation file.
        unlink $statuspath or die "Could not delete the file $!!\n";

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

    # Wildcard catcher for undefined directories.
    $server->mount('/' => {
        handler => sub {
            my ($req, $res) = @_;

            $res->code(404);

            1;
        },
        wildcard => 1,
    });

    # Start mounting system inputs.
    $server->mount('/system/update' => {
        handler => sub {
            my ($req, $res) = @_;

            # Reload the routes file and mount new routes.
            _update;

            $res->header('Content-type', 'text/plain');
            $res->add_content('Successfully updated routes.');
            $res->code(200);

            return 1;
        },
        wildcard => 0,
    });

    # Load routes file and mount routes.
    _update;

    $server->start;
}

1;
