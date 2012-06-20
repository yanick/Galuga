package DBIx::NoSQL::Store::Manager;

use strict;
use warnings;

use Moose;

extends 'DBIx::NoSQL::Store';

use DBIx::NoSQL::Store;
use Method::Signatures;
use Module::Pluggable require => 1;

has models => (
    traits => [ 'Hash' ],
    is => 'ro',
    isa => 'HashRef',
    lazy => 1,
    default => method {
        my ( $class ) = $self->meta->class_precedence_list;

        search_path( $self, new => join '::', $class, 'Model' );

        return { map { _model_name($_) => $_ } plugins( $self, plugins ) };
    },
    handles => {
        all_models => 'keys',
        all_model_classes => 'values',
        model_class => 'get',
    },
);

sub _model_name {
    my $name = shift;
    $name =~ s/^.*::Model:://;
    return $name;
}

method register {
    for my $p ( $self->all_model_classes ) {
        $self->model( $p->store_model )->_wrap( sub {
            my $inflated = $p->unpack($_[0]);
            $inflated->store_db($self);
            return $inflated;
        });
    }
};

method new_model_object ( $model, @args ) {
    $self->model_class($model)->new( store_db => $self, @args);   
}

1;

