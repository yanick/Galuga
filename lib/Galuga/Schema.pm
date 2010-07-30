package Galuga::Schema;

use strict;
use warnings;

our $VERSION = '0.0.1';

use base qw/DBIx::Class::Schema/;

__PACKAGE__->load_namespaces();

__PACKAGE__->load_components(qw/Schema::Versioned/);
__PACKAGE__->upgrade_directory('upgrades');

1;
