package Galuga::Store::Model::Entry;

use strict;
use warnings;

use Method::Signatures;

use Moose;
use MooseX::ClassAttribute;

with 'DBIx::NoSQL::Store::Model::Role';

has uri => (
    traits => [ 'StoreIndex' ],
    is => 'rw',
);

has title => (
    is => 'rw',
);

has category => (
    is => 'rw',
);

has stuff => (
    is => 'rw',
);




__PACKAGE__->meta->make_immutable;

1;



