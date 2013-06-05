package Galuga::Repository;

use strict;
use warnings;

use Moose;
use MooseX::Types::Path::Tiny qw/Path AbsPath/;

use Method::Signatures;

has 'git' => (
    is => 'ro',
);

has root => (
    is => 'ro',
    isa => AbsPath,
    coerce => 1,
);

method full_path ( $within_repo ) {
    $self->root->child($within_repo);
}

1;
