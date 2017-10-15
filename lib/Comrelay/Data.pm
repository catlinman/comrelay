
# Assign this submodule to the main package.
package Comrelay::Data;

# Basic Perl configuration.
use strict;
use warnings;

# Path handling.
use File::Basename;
my $dirname = dirname(__FILE__);

my $file = "$dirname/../data/data.csv";
my $data;

BEGIN {
    require Exporter;

    # Set the version for version checking.
    our $VERSION = 1.00;

    # Inherit from Exporter to export functions and variables.
    our @ISA = qw(Exporter);

    # Functions and variables which are exported by default.
    our @EXPORT = qw(read_data save_data get_data);

    # Functions and variables which can be optionally exported.
    our @EXPORT_OK = qw();
}

sub setup_data {
    open(my $data, '<', $file) or die "Could not open '$file' $!\n";
}

sub read_data {
    # Check if the file exists.
    my $exists = (-e $file ? 1 : 0);

    # Check if the file exists. If not run first time setup.
    if(!$exists) {
        # Create the default file.
        setup_data;

    } else {

    }

    $data;
}

sub save_data {
    get_data;
}

sub get_data {
    if(defined $data) {
        $data;

    } else {
        read_data;
    }
}

sub add_command {

}

sub remove_command {

}

1;
