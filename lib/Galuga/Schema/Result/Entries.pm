package Galuga::Schema::Result::Entries;

use strict;
use warnings;

use base qw/DBIx::Class::Core/;

__PACKAGE__->table( 'Entries' );

__PACKAGE__->add_columns(
    path => {
        data_type => 'VARCHAR',
        size => 50,
        is_nullable => 0,
    },
    filename => {
        data_type => 'VARCHAR',
        size => 50,
        is_nullable => 0,
    },
    md5 => {
        data_type => 'VARCHAR',
        size => 32,
        is_nullable => 1,
    },
    url => {
        data_type => 'VARCHAR',
        size => 32,
        is_nullable => 0,
    },
    title => {
        data_type => 'VARCHAR',
        size => 50,
        is_nullable => 0,
   },
    format => {
        data_type => 'VARCHAR',
        size => 20,
        is_nullable => 0,
   },
    body => {
        data_type => 'TEXT',
        is_nullable => 0,
    },
    created => {
        data_type => 'DATETIME',
        is_nullable => 1,
    },
    last_updated => {
        data_type => 'DATETIME',
        is_nullable => 1,
    },
);

__PACKAGE__->set_primary_key( 'path' );

__PACKAGE__->add_unique_constraint([ 'url' ]);

__PACKAGE__->has_many( tags => 'Galuga::Schema::Result::Tags',
    { 'foreign.entry_path' => 'self.path' },
);

1;
