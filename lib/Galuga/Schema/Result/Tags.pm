package Galuga::Schema::Result::Tags;

use strict;
use warnings;

use base qw/DBIx::Class::Core/;

__PACKAGE__->table( 'Tags' );

__PACKAGE__->add_columns(
    id => {
        data_type => 'INTEGER',
        auto_increment => 1,
    },
    label => {
        data_type => 'VARCHAR',
        size => 20,
        is_nullable => 0,
    },
);

__PACKAGE__->set_primary_key(qw/ id / );


__PACKAGE__->has_many(
    entry_tags => 'Galuga::Schema::Result::EntryTags',
    'tag_id'
);

__PACKAGE__->many_to_many( entries => 'entry_tags', 'entry' );

1;
