package Galuga::Store;

use strict;
use warnings;

use DBIx::NoSQL::Store;
use Method::Signatures;

use Module::Pluggable
    search_path => [ join '::', __PACKAGE__, 'Model' ],
    require     => 1;

use Moose;

extends 'DBIx::NoSQL::Store';

around get => sub {
    my( $inner, $self, @args ) = @_;

    my $hash = $inner->( $self, @args );

    return $hash unless ref $hash;

    $hash->db($self);

    return $hash;
    $hash->{db} = $self;
    use Data::Printer;
    return $hash->{'__CLASS__'}->unpack($hash);
};

sub register {
    my $self = shift;
    for my $p ( $self->plugins ) {
        $self->model( $p->model )->_wrap( sub {
            $p->unpack($_[0]);
        });

    }
};



__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;



