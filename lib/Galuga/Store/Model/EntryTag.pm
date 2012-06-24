package Galuga::Store::Model::EntryTag;

use strict;
use warnings;

use Method::Signatures;

use Moose;
use Galuga::Store::Types qw/ URIClass DateTimeClass SetClass /;

with 'DBIx::NoSQL::Store::Model::Role';

has '+store_key' => (
    default => method {
        join ' : ', $self->entry_key, $self->tag;
    },
);

has entry_key => (
    traits => [ 'StoreIndex' ],
    isa => 'URIClass',
    is => 'rw',
    coerce => 1,
);

has tag => (
    traits => [ 'StoreIndex' ],
    is => 'rw',
    isa => 'Str',
);

__PACKAGE__->meta->make_immutable;

1;





