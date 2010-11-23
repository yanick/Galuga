package Galuga::Schema::Result::Entries;

use strict;
use warnings;

use base qw/DBIx::Class::Core/;

__PACKAGE__->load_components(qw/ Core InflateColumn::DateTime/);

__PACKAGE__->table('Entries');

__PACKAGE__->add_columns(
    id => {
        data_type      => 'INTEGER',
        auto_increment => 1,
    },
    path => {
        data_type   => 'VARCHAR',
        size        => 50,
        is_nullable => 0,
    },
    filename => {
        data_type   => 'VARCHAR',
        size        => 50,
        is_nullable => 0,
    },
    md5 => {
        data_type   => 'VARCHAR',
        size        => 32,
        is_nullable => 1,
    },
    url => {
        data_type   => 'VARCHAR',
        size        => 32,
        is_nullable => 0,
    },
    title => {
        data_type   => 'VARCHAR',
        size        => 50,
        is_nullable => 0,
    },
    body => {
        data_type   => 'TEXT',
        is_nullable => 0,
    },
    created => {
        data_type   => 'DATETIME',
        is_nullable => 1,
    },
    last_updated => {
        data_type   => 'DATETIME',
        is_nullable => 1,
    },
    original => {
        data_type   => 'VARCHAR',
        size        => 100,
        is_nullable => 1,
    },
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->add_unique_constraint( ['path'] );
__PACKAGE__->add_unique_constraint( ['url'] );

__PACKAGE__->has_many(
    entry_tags => 'Galuga::Schema::Result::EntryTags',
    'entry_id'
);

__PACKAGE__->many_to_many( tags => 'entry_tags', 'tag' );

1;
