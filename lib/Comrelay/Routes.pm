
# Assign this submodule to the main package.
package Comrelay::Routes;

# Basic Perl configuration.
use strict;
use warnings;

# Additional modules.
use Data::UUID;

# Name of the configuration file and specify the delimiter.
my $filename = 'data.csv';
my $filedelimiter = ',';
my @fileformat = ('route', $filedelimiter,  'secret', $filedelimiter, 'command');
my $fileheader = join("", @fileformat);

# Hash storage of routes and their commands.
my %data;

BEGIN {
    require Exporter;

    # Set the version for version checking.
    our $VERSION = 1.00;

    # Inherit from Exporter to export functions and variables.
    our @ISA = qw(Exporter);

    # Functions and variables which are exported by default.
    our @EXPORT = qw(get add remove);

    # Functions and variables which can be optionally exported.
    our @EXPORT_OK = qw();
}

sub setup {
    # Create the data.csv file for writing.
    open(my $filehandle, '>', $filename) or die "Could not open '$filename' $!.\n";

    # Write the headers.
    print $filehandle $fileheader;

    # Close handle.
    close $filehandle;
}

sub load {
    # Check if the file exists.
    my $exists = (-e $filename ? 1 : 0);

    # Check if the file exists. If not run first time setup.
    if(!$exists) {
        # Create the default file.
        setup;

    } else {
        # Open the file in read mode.
        open(my $filehandle, '<', $filename) or die "Could not open '$filename' $!.\n";

        # Iterate over lines in the file handle.
        my $linecount = 0;
        while(my $line = <$filehandle>) {
            # Increment line count.
            $linecount++;

            # Remove any possible line breaks.
            $line =~ s/[\r\n]+$//;

            # Skip the line if it's the header.
            next if($line eq $fileheader);

            # Split the CSV file with the correct delimiter.
            my ($route, $command, $secret) = split /$filedelimiter/, $line;

            # Check file formatting integrity.
            if (!$route or !$command or !$secret) {
                print "Routes: Incorrect length of values at line $linecount of '$filename'. \n";

                next;
            }

            if($data{$route}) {
                print "Routes: Duplicate route '$route' at line $linecount of '$filename'.\n";

                next;
            }

            # Assign an array to the route hash.
            $data{$route} = [$command, $secret];
        }

        close $filehandle;
    }

    %data;
}

sub save {
    # TODO: This is very broken I will fix this tomorrow.
    # Open up the data file.
    open(my $filehandle, '>', $filename) or die "Could not open '$filename' $!.\n";

    # Write the headers.
    print $filehandle "$fileheader\n";
    print $filehandle "TEST\n";

    foreach my $route (keys %data) {
        my $secret = $data{$route}[0];
        my $command = $data{$route}[1];

        my @formatted = ($route, $filedelimiter,  $secret, $filedelimiter, $command, "\n");
        print $secret;
        print $filehandle join("", @fileformat);
    }

    # Close handle.
    close $filehandle;

    %data;
}

sub get {
    # Return the reference if it exists or read the file.
    %data or load;
}

sub add {
    # Get arguments.
    my ($route, $secret, $command) = @_;

    die 'Missing required arguments.' if(!$route or !$command);

    # Get data if it isn't present.
    get if(!%data);

    # Generate a unique ID if no secret is specified.
    $secret ||= "asdf";

    # Assign an array to the route hash.
    $data{$route} = [$command, $secret];

    # Save the changes.
    save;
}

sub remove {
    # Get arguments.
    my ($route) = @_;

    die 'Missing required arguments.' if(!$route);

    # Load data if it isn't present.
    get if(!%data);

    if($data{$route}) {
        delete $data{$route};

        save;

        print "Routes: Successfully removed '$route'.\n";

    } else {
        print "Routes: The route '$route' does not exist.\n";
    }
}

1;
