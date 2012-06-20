#!/usr/bin/perl 

use 5.10.0;

use strict;
use warnings;

use DBIx::NoSQL;

=pod

package Galuga::Store;

use Moose;

extends 'DBIx::NoSQL::Store';

package Galuga::Store::Entry;

package main;

my $store = Galuga::Store->new(
    database => 'store.sqlite',
);

my $store = Galuga::Store->new( database => 'store.sqlite');
$store->connect;

my $entry = $store->

my $entry = Galuga::Store::Entry->new(
    store => 
);


my $store = DBIx::NoSQL->connect( 'foo.sqlite' );

$store->model('Entries')->index('tags', isa => 'Mollusk' );

$store->set( 'Entries' => 'bob' => 'oreo' );

$DB::single = 1;

say $store;

=cut

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

#$store->model('Entry')->_wrap(sub{
#    Galuga::Store::Model::Entry->unpack($_[0]);
#});

say p( $e->all );

say "bob";

say "obo", $entry->meta->class_precedence_list;

__END__

use Galuga::Schema;

my $schema = Galuga::Schema->connect( 'dbi:SQLite:dbname=test.db' );

#$schema->deploy;

my $entry = $schema->resultset('Entries')->new({
    path => 'foo',
    filename => 'bar',
    title => 'moink stuff',
    body => 'gluck',
    created => '2011-12-12',
});

$entry->insert;

$entry = $schema->resultset('Entries')->create({
    path => 'foo',
    filename => 'bar',
    title => 'moink stuff',
    url => 'other',
    body => 'gluck',
    created => '2011-12-12',
});


