
use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'Comrelay',
    AUTHOR           => q{Catlinman <contact@catlinman.com>},
    VERSION_FROM     => 'lib/Comrelay.pm',
    ABSTRACT_FROM    => 'lib/Comrelay.pm',
    LICENSE          => 'mit',
    PL_FILES         => {},
    MIN_PERL_VERSION => '5.006',
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => '0',
    },
    BUILD_REQUIRES => {
        'Test::More' => '0',
    },
    PREREQ_PM => {
        'HTTP::Server::Brick' => '0.1.7',
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'comrelay-*' },
);
