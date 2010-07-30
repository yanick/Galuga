package Galuga::Schema::Result::Tags;

use strict;
use warnings;

use base qw/DBIx::Class::Core/;

__PACKAGE__->table( 'Tags' );

__PACKAGE__->add_columns(
    entry_path => {
        data_type => 'VARCHAR',
        size => 50,
        is_nullable => 0,
    },
    tag => {
        data_type => 'VARCHAR',
        size => 20,
        is_nullable => 0,
    },
);

__PACKAGE__->set_primary_key(qw/ entry_path tag / );

1;
