package Galuga::Store::Model::Entry;

use strict;
use warnings;

use Method::Signatures;

use Moose;
use MooseX::ClassAttribute;
use MooseX::Storage;

with Storage;

has db => (
    traits => [ 'DoNotSerialize' ],
    is       => 'rw',
);

class_has model => (
    isa => 'Str',
    is => 'rw',
    default => method {
        # TODO probably over-complicated
       my( $class ) = $self->class_precedence_list;

       $class =~ s/^.*?::Model:://;

       return $class;
    },
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



