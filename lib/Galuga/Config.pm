package Galuga::Config;

use strict;
use warnings;

use Moo;

with 'Dancer2::Core::Role::Config';

has '+config_location' => (
    required => 1,
    lazy => 0,
);

sub _build_config_location { die "argument 'config_location' is requied" }

sub _build_environment {
    $ENV{DANCER_ENVIRONMENT} || $ENV{PLACK_ENV} || 'development';
}

sub name { __PACKAGE__ }

1;



