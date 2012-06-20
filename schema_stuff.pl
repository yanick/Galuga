#!/usr/bin/perl 

use 5.10.0;

use strict;
use warnings;

use DBIx::NoSQL;

use Galuga::Store;
use Galuga::Store::Model::Entry;

my $store = Galuga::Store->connect( 'foo.db' );
$store->register;

$store->model('Entry')->index( 'category' );

my $entry = Galuga::Store::Model::Entry->new(
    db => $store,
    title => 'yadah',
    category => 'x',
);

$entry->store;

# later on

my $e = $store->get( Entry => 'yadah' );

use Data::Printer;
say p $e;

$e = $store->search( Entry => { category => 'x' } );

say p( $e->all );
