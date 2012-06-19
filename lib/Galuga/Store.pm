package Galuga::Store;

use strict;
use warnings;

use DBIx::NoSQL::Store;
use Method::Signatures;

use Moose;

extends 'DBIx::NoSQL::Store';

around get => sub {
    my( $inner, $self, @args ) = @_;

    $DB::single = 1;
    my $hash = $inner->( $self, @args );

    return $hash unless ref $hash;

    $hash->{store} = $self;

    return $hash->{'__CLASS__'}->unpack($hash);
};


__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;



