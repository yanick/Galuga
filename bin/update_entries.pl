#!/usr/bin/env perl

use strict;
use warnings;

use lib 'lib';

use Getopt::Long;

GetOptions(
    'force!' => \my $force,
);

use Galuga::Store;
use Galuga::Config;

chdir '/home/yanick/work/perl-modules/Galuga';

my $config = Galuga::Config->new( config_location =>
    '/home/yanick/work/perl-modules/Galuga' );

my $store = Galuga::Store->new(
    blog_repository => $config->config->{blog_repository},
    db => $config->config->{store},
    log_debug => 1,
    log_to_stdout => 1,
);

$store->update_entries( @ARGV, { force => $force } );

