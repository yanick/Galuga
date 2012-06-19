package Galuga::Store::Entry;

use strict;
use warnings;

use Method::Signatures;

use Moose;
use MooseX::Storage;

with Storage;

has db => (
    traits => [ 'DoNotSerialize' ],
    is       => 'ro',
);

has model => (
    isa => 'Str',
    is => 'rw',
    default => method {
        # TODO probably over-complicated
       my( $class ) = $self->meta->class_precedence_list;
       my( $store_class ) = $self->db->meta->class_precedence_list;

       my $prefix = quotemeta join "::", $store_class, 'Model', '';

       $class =~ s/$prefix//;

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



