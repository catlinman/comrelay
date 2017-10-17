
# Assign this submodule to the main package.
package Comrelay::Routes;

# Basic Perl configuration.
use strict;
use warnings;

# HTTP request handling for updating the server via GET request.
use LWP::Simple;

# Name of the configuration file and specify the delimiter.
my $filename = '.comrelay_routes';
my $filedelimiter = ',';
my @fileformat = ('route', $filedelimiter,  'secret', $filedelimiter, 'command');
my $fileheader = join("", @fileformat);

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
    our @EXPORT = qw(load save add remove);

    # Functions and variables which can be optionally exported.
    our @EXPORT_OK = qw();
}

sub _setup {
    # Create the data.csv file for writing.
    open my $filehandle, '>', $filename or die "Routes: Could not open '$filename' $!.\n";

    # Write the headers.
    print $filehandle $fileheader;

    # Close handle.
    close $filehandle;
}

sub load {
    # Check if the file exists.
    my $exists = (-e $filename ? 1 : 0);

    # Check if the file exists. If not run first time setup.
    _setup if(not $exists);

    # Clear the hash for a possible reload to avoid duplicate detection.
    %routes = ();

    # Open the file in read mode.
    open ROUTESFILE, '<', $filename or die "Routes: Could not open '$filename' $!.\n";

    # Iterate over lines in the file handle.
    my $linecount = 0;
    while(my $line = <ROUTESFILE>) {
        # Increment line count.
        $linecount++;

        # Remove any possible line breaks.
        $line =~ s/[\r\n]+$//;

        # Skip the line if it's the header.
        next if($line eq $fileheader);

        # Split the CSV file with the correct delimiter.
        my ($route, $command, $secret) = split /$filedelimiter/, $line;

        # Check file formatting integrity.
        if(not $route or not $command or not $secret) {
            print "Routes: Incorrect length of values at line $linecount of '$filename'. \n";

            next;
        }

        if($routes{$route}) {
            print "Routes: Duplicate route '$route' at line $linecount of '$filename'.\n";

            next;
        }

        # Assign an array to the route hash.
        $routes{$route} = [$command, $secret];
    }

    # Close the file handle we have previously created.
    close ROUTESFILE;

    %routes;
}

sub save {
    # Open up the data file.
    open my $filehandle, '>', $filename or die "Routes: Could not open '$filename' $!.\n";

    # Write the headers.
    print $filehandle "$fileheader\n";

    foreach my $route (keys %routes) {
        my $secret = $routes{$route}[0];
        my $command = $routes{$route}[1];

        # Create an array for easier string formatting without concatenation.
        my @formatted = ($route, $filedelimiter,  $secret, $filedelimiter, $command, "\n");

        print $filehandle join("", @formatted);
    }

    # Close handle.
    close $filehandle;

    # Check if the port file exists.
    my $exists = (-e '.comrelay_port' ? 1 : 0);

    if($exists) {
        # Port of the possibly currently running server.
        my $port = 0;

        # Read the found port file.
        local $/ = undef;
        open PORTFILE, '.comrelay_port' or die "Routes: Could not open 'port' $!.\n";
        $port = <PORTFILE>;
        close PORTFILE;

        # Make a reload request if the server is currently running.
        if($port) {
            print "Routes: Making an update request to the server on port $port.\n";

            my $content = LWP::Simple::get("http://localhost:$port/admin/update/");

            print "Routes: (Response) $content\n";
        }
    }

    %routes;
}

sub add {
    # Get and handle arguments.
    my ($route, $secret, $command) = @_;

    die 'Missing required arguments' if not $route or not $command;

    # Get data if it isn't present.
    load if(not %routes);

    # Make sure that there isn't already a route defined with this name.
    die "Routes: The route '$route' already exists.\n" if $routes{$route};

    # Generate a unique ID if no secret is specified.
    if(not $secret) {
        $secret .= $secretchars[rand @secretchars] for 1..$secretlength;
    }

    # Assign an array to the route hash.
    $routes{$route} = [$secret, $command];

    print "Routes: Successfully added '$route'.\n";

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
