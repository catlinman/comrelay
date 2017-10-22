
# Assign this submodule to the main package.
package Comrelay::Routes;

# Basic Perl configuration.
use strict;
use warnings;

# HTTP request handling for updating the server via GET request.
use LWP::Simple;

# Name of the routes and port file.
my $routespath = '.comrelay_routes';
my $statuspath = '.comrelay_status';

# Delimiter for reading of the configuration.
my $delimiter = ',';

# Formatting guide and header specification.
my @format = (
    'route', $delimiter,
    'secret', $delimiter,
    'field', $delimiter,
    'command'
);

my $header = join("", @format);

# Secret random generation characters.
my @secretchars = ("A".."Z", "a".."z");
my $secretlength = 32;

# Hash storage of routes and their commands.
my %routes;

BEGIN {
    require Exporter;

    # Set the version for version checking.
    our $VERSION = 1.00;

    # Inherit from Exporter to export functions and variables.
    our @ISA = qw(Exporter);

    # Functions and variables which are exported by default.
    our @EXPORT = qw(load save add remove get);

    # Functions and variables which can be optionally exported.
    our @EXPORT_OK = qw();
}

sub _setup {
    # Create the data.csv file for writing.
    open my $routeshandle, '>', $routespath or die "Routes: Could not open '$routespath' $!.\n";

    # Write the headers.
    print $routeshandle $header;

    # Close handle.
    close $routeshandle;
}

sub save {
    # Open up the data file.
    open my $routeshandle, '>', $routespath or die "Routes: Could not open '$routespath' $!.\n";

    # Write the headers.
    print $routeshandle $header . "\n";

    foreach my $route (keys %routes) {
        my $secret = $routes{$route}[0];
        my $field = $routes{$route}[1];
        my $command = $routes{$route}[2];

        # Create an array for easier string formatting without concatenation.
        my @formatted = (
            $route, $delimiter,
            $secret, $delimiter,
            $field, $delimiter,
            $command
        );

        print $routeshandle join("", @formatted) . "\n";
    }

    # Close handle.
    close $routeshandle;

    # Check if the port file exists.
    my $exists = (-e $statuspath ? 1 : 0);

    if($exists) {
        # Port of the possibly currently running server.
        my $port = 0;

        # Read the found port file.
        local $/ = undef;
        open my $statushandle, '<', $statuspath or die "Routes: Could not open '$statuspath' $!.\n";
        $port = <$statushandle>;
        close $statushandle;

        # Make a reload request if the server is currently running.
        if($port) {
            print "Routes: Making an update request to the local server on port $port.\n";

            my $content = LWP::Simple::get("http://localhost:$port/system/update/");

            if($content) {
                print "Routes: (Response) $content\n";
            } else {
                print "Routes: Failed to make a connection to the server. Deleting '$statuspath'.\n";

                unlink $statushandle or print "Routes: Could not delete the file $!.\n";
            }
        }
    }

    %routes;
}

sub load {
    # Check if the file exists.
    my $exists = (-e $routespath ? 1 : 0);

    # Check if the file exists. If not run first time setup.
    _setup if(not $exists);

    # Clear the hash for a possible reload to avoid duplicate detection.
    %routes = ();

    # Open the file in read mode.
    open my $routeshandle, '<', $routespath or die "Routes: Could not open '$routespath' $!.\n";

    # Iterate over lines in the file handle.
    my $linecount = 0;
    my $formaterror = 0;
    while(my $line = <$routeshandle>) {
        # Increment line count.
        $linecount++;

        # Remove any possible line breaks.
        $line =~ s/[\r\n]+$//;

        # Skip the line if it's the header.
        next if($line eq $header);

        # Split the CSV file with the correct delimiter.
        my ($route, $secret, $field, $command) = split /$delimiter/, $line;

        # Check file formatting integrity.
        if(not $route or not $secret or not $field or not $command) {
            print "Routes: Incorrect length of values at line $linecount of '$routespath'. \n";

            # Print the error line.
            print "-> $line\n";

            # Increment the formatting error tracking variable.
            $formaterror++;

            next;
        }

        if($routes{$route}) {
            print "Routes: Duplicate route '$route' at line $linecount of '$routespath'.\n";

            # Print the error line.
            print "-> $line\n";

            # Increment the formatting error tracking variable.
            $formaterror++;

            next;
        }

        # Assign an array to the route hash.
        $routes{$route} = [$secret, $field, $command];
    }

    # Close the file handle we have previously created.
    close $routeshandle;

    # Attempt to save with the new data to fix formatting issues.
    print "Routes: Recreating '$routespath' to fix formatting errors.\n" and save if $formaterror;

    %routes;
}

sub add {
    # Get and handle arguments.
    my ($route, $secret, $field, $command) = @_;

    die 'Missing required arguments' if not $route or not $command;

    # Get data if it isn't present.
    load if not %routes;

    my $exists = 0;

    $exists = 1 if $routes{$route};

    # Make sure that there isn't already a route defined with this name.
    print "Routes: The route '$route' already exists. Replacing information.\n" if $exists;

    # Set arguments if they are already declared but not passed.
    $secret = $routes{$route}[0] if $routes{$route} and not $secret;
    $field = $routes{$route}[1] if $routes{$route} and not $field;
    $command = $routes{$route}[2] if $routes{$route} and not $command;

    # Generate a unique ID if no secret is specified or available.
    if(not $secret) {
        $secret .= $secretchars[rand @secretchars] for 1..$secretlength;
    }

    # Set the default access variable if none is set.
    $field = 'secret' if not $field;

    # Assign an array to the route hash.
    $routes{$route} = [$secret, $field, $command];

    if(not $exists){
        print "Routes: Successfully added '$route'.\n";

    } else {
        print "Routes: Successfully updated '$route'.\n";
    }

    # Save the changes and return the new data.
    save;
}

sub remove {
    # Get and handle arguments.
    my ($route) = @_;

    die 'Missing required arguments' if not $route;

    # Load data if it isn't present.
    load if(!%routes);

    if($routes{$route}) {
        my $removedata = $routes{$route};

        # Delete the entry from the routes hash.
        delete $routes{$route};

        print "Routes: Successfully removed '$route'.\n";

        # Save changes.
        save;

        # Return the removed data.
        $removedata;

    } else {
        print "Routes: The route '$route' does not exist.\n";

        0;
    }
}

1;
