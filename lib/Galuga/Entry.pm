package Galuga::Entry;

use strict;
use warnings;

use Moose;

has db => (
    is => 'ro',
    required => 1,
    handles => [qw/
        title
    /],
);

has repo => (
    is => 'ro',
    required => 1,
);

1;

