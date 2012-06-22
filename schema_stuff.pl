#!/usr/bin/perl 

use 5.10.0;

use strict;
use warnings;

use Galuga::Store;
use Galuga::Store::Model::Entry;

use DateTime;

my $store = Galuga::Store->connect( 'foo.db' );
$store->register;

$store->model('Entry')->index( 'category' );

$store->new_model_object('Entry',
    uri => '/foo',
    tags => [qw/ perl moosex /],
)->store;

$store->new_model_object('Entry',
    uri => '/bar',
    tags => [qw/ perl dist::zilla /],
)->store;

# later on

my $e = $store->get( Entry => '/foo' );

use Data::Printer;
say p $e;

$e = $store->search( 'EntryTag' => { tag => 'perl' } );

say p( $e->all );

say join ' ', $store->schema->resultset('EntryTag')
    ->search({},{ columns => 'tag', distinct => 1 })->get_column('tag')->all;
