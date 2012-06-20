package DBIx::NoSQL::Store::Model::Role;

use strict;
use warnings;

use Moose::Role;

use Method::Signatures;
use MooseX::ClassAttribute;
use MooseX::Storage;

with Storage;
with 'DBIx::NoSQL::Store::Model::Role::StoreIndex';

has store_db => (
    traits => [ 'DoNotSerialize' ],
    is       => 'rw',
);

class_has store_model => (
    isa => 'Str',
    is => 'rw',
    default => method {
        # TODO probably over-complicated
       my( $class ) = $self->class_precedence_list;

       $class =~ s/^.*?::Model:://;
       return $class;
    },
);

has store_key => (
    traits => [ 'DoNotSerialize' ],
    is => 'ro',
    lazy => 1,
    default => method {
       for my $attr ( grep {
            $_->does('DBIx::NoSQL::Store::Model::Role::StoreIndex') 
       } $self->meta->get_all_attributes ) {
            my $reader = $attr->get_read_method;
            my $value = $self->$reader;

            die "attribute '", $attr->name, "' is empty" unless $value;

            return $value;
       }

       die "no store key set for $self";
    },
);

method store {
    $self->store_db->set( 
        $self->store_model =>
            $self->store_key => $self,
    );
}

method _entity {
   return $self->pack; 
}

package DBIx::NoSQL::Store::Model::Role::StoreIndex;

use Moose::Role;
Moose::Util::meta_attribute_alias('StoreIndex');

1;
