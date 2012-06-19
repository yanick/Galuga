package Galuga::Store::Entry;

use strict;
use warnings;

use Method::Signatures;

use Moose;
use MooseX::Storage;

with Storage( format => 'JSON' );

has db => (
    traits => [ 'DoNotSerialize' ],
    is       => 'ro',
);

has title => (
    is => 'rw',
);

has category => (
    is => 'rw',
);

method store {
    $self->db->set( 
        'Entry' => $self->title => $self,
    );
}

method _entity {
   return $self->pack; 
}


__PACKAGE__->meta->make_immutable;

1;



