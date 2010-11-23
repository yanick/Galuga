package Galuga::Schema::Result::EntryTags;

use strict;
use warnings;

use base qw/DBIx::Class::Core/;

__PACKAGE__->table( 'EntryTags' );

__PACKAGE__->add_columns(
    entry_id => {
        data_type => 'INTEGER',
    },
    tag_id => {
        data_type => 'INTEGER',
    }
);

__PACKAGE__->set_primary_key(qw/ entry_id tag_id /);


__PACKAGE__->belongs_to(entry => 'Galuga::Schema::Result::Entries',
'entry_id' );
__PACKAGE__->belongs_to(tag => 'Galuga::Schema::Result::Tags',
'tag_id' );

1;
