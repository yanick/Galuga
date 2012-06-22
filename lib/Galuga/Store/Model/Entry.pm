package Galuga::Store::Model::Entry;

use strict;
use warnings;

use Method::Signatures;

use Moose;
use Galuga::Store::Types qw/ URIClass DateTimeClass SetClass /;

with 'DBIx::NoSQL::Store::Model::Role';

has uri => (
    traits => [ 'StoreKey' ],
    isa => 'URIClass',
    is => 'rw',
    coerce => 1,
);

has date_created => (
    traits => [ 'StoreIndex' ],
    isa => 'DateTimeClass',
    is => 'rw',
    default => sub { DateTime->now },
);

has tags => (
    is => 'rw',
    isa => 'SetClass',
    handles => {
        add_tags => 'insert',
        remove_tags => 'remove',
        _all_tags => 'elements',
    },
    coerce => 1,
);

after store => sub {
    my $self = shift;

    # play it safe: remove all first
    $_->delete for $self->store_db->model('EntryTag')->search({
        entry_key => $self->store_key 
    })->all;

    for ( $self->all_tags ) {
        $self->store_db->new_model_object( 'EntryTag', 
            entry_key => $self->store_key,
            tag       => $_,
        )->store;
    }
};

method all_tags { sort $self->_all_tags } 

__PACKAGE__->meta->make_immutable;

1;



