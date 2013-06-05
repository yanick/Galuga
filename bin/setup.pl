#!/usr/bin/env perl 

use strict;
use warnings;

use lib 'lib';

use Galuga::Schema;
use Galuga::Repository;
use Log::Dispatchouli;
use YAML::XS qw/ LoadFile /;
use Path::Tiny;

my $config = LoadFile('config.yml');

my $db_path = path($config->{db})->dirname;
path( $db_path )->mkpath unless -d $db_path;

Galuga::Schema->connect( 'dbi:SQLite:' . $config->{db}, undef, undef, {
        sqlite_unicode => 1,
    })->deploy unless -f $config->{db};







