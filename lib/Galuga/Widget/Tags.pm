package Galuga::Widget::Tags;

use strict;
use warnings;

use Template::Declare::Tags;
use base 'Template::Declare';

template widget => sub {
    my $self = shift;
    my %arg  = @_;

    div {
        attr { class => 'widget tags_listing' };
        h3 { 'Tags' };
        show( 'tag', %arg, tag => $_ )
          for sort { lc( $a->tag ) cmp lc( $b->tag ) }
          $self->get_tags( $arg{c} );
    }

};

template 'tag' => sub {
    my ( $self, %arg ) = @_;

    div {
        a {
            attr { href => $arg{c}->uri_for('/tag') . '/' . $arg{tag}->tag }
              $arg{tag}->tag . ' ';
        }

        div {
            attr { class => 'count' } '('
              . $arg{tag}->get_column('nbr_entries') . ')';
        }
    }
};

sub get_tags {
    my ( $self, $c ) = @_;

    return $c->model('DB::Tags')->search(
        {},
        {   group_by => 'tag',
            order_by => 'tag',
            select   => [ 'tag', { count => 'entry_path' } ],
            as       => [qw/ tag nbr_entries /],
        } )->all;
}

1;
