package Galuga::Format::markdown;

use strict;
use warnings;

use Text::Markdown 'markdown';

sub render {
    return markdown( $_[1] );
}

1;
