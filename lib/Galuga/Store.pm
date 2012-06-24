package Galuga::Store;

use strict;
use warnings;

use Moose;

use Moose::Util::TypeConstraints;
use MooseX::Storage::Engine;

extends 'DBIx::NoSQL::Store::Manager';

has gitstore => (
    is => 'ro',
    required => 1,
    isa => 'GitStore'
);

sub update_database {
    my $self = shift;

    die $self->gitstore->get( 'going-postal/entry' );

    die join "\n", map { join ":", $_->filename, $_->sha1 } $self->gitstore->all_head_directory_entries;

}

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;



