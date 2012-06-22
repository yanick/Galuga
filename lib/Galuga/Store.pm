package Galuga::Store;

use strict;
use warnings;

use Moose;

use Moose::Util::TypeConstraints;
use MooseX::Storage::Engine;

extends 'DBIx::NoSQL::Store::Manager';


__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;



