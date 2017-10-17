
use 5.006;
use strict;
use warnings;
use File::Copy;
use ExtUtils::MakeMaker;

# Copy the executable script and rename it for command line use.
copy('bin/Comrelay.pm', 'bin/comrelay') or die "Failed to copy executable script: $!";

WriteMakefile(
    NAME             => 'Comrelay',
    AUTHOR           => 'Catlinman <contact@catlinman.com>',
    VERSION          => '0.1',
    ABSTRACT_FROM    => 'bin/comrelay',
    LICENSE          => 'mit',
    PL_FILES         => {},
    MIN_PERL_VERSION => '5.006',
    EXE_FILES        => [('bin/comrelay')],
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => '0',
    },
    BUILD_REQUIRES => {
        'Test::More' => '0',
    },
    PREREQ_PM => {
        'HTTP::Server::Brick' => '0.1.7',
        'LWP::Simple' => '6.27',
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'comrelay-*' },
);
