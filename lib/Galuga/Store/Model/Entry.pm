package Galuga::Store::Model::Entry;

use strict;
use warnings;

use Method::Signatures;

use Moose;
#use MooseX::ClassAttribute;
use MooseX::Storage;

with Storage;

has db => (
    traits => [ 'DoNotSerialize' ],
    is       => 'rw',
);

has model => (
    isa => 'Str',
    is => 'rw',
    lazy => 1,
    default => method {
        # TODO probably over-complicated
       my( $class ) = $self->meta->class_precedence_list;

       $class =~ s/^.*?::Model:://;

       return $class;
    },
    trigger => sub {
        my $self = shift;
        die $self;
        $self->db->model( $self->model )->_wrap( sub {
            $self->unpack($_[0]);
        });
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



