package Galuga::Widget::RecentTags;

use strict;
use warnings;

use Template::Declare::Tags;
use base 'Template::Declare';

template widget => sub {
    my $self = shift;
    my %arg  = @_;
    my $c    = $arg{c};

    div {
        attr { class => 'widget tags_listing' };
        h3 { 'Recent tags' };
        ul {
            attr { id => 'recent_tags' };
            map { show( 'tag', %arg, tag => $_ ) }
              sort { lc( $a->label ) cmp lc( $b->label ) }
              $self->get_tags( $arg{c} );
        };

        div {
            attr { style => 'text-align:right;', };
            a {
                attr { href => $c->uri_for('/tags') } 'all tags';
            }

        }
    }

    script {
        attr { type => 'text/javascript' };
        outs_raw <<'END_SCRIPT';
$(function(){
    $('#recent_tags').tagcloud({ 
        type: "list",
        colormin: "AB0404",
        colormax: "AB0404"
    }).find('li').css('padding-right', '3px' );
});
END_SCRIPT
    }

};

template 'tag' => sub {
    my ( $self, %arg ) = @_;

    li {
        attr {
            value => $arg{tag}->count_related( 'entry_tags' ),
            title => $arg{tag}->label
        };
        a {
            attr { href => $arg{c}->uri_for( '/tag', $arg{tag}->label ) };
            $arg{tag}->label;
        }
    }
};

sub get_tags {
    my ( $self, $c ) = @_;

    my %tags = map { $_->label => $_ } $c->model('DB::Entries')->search(
        {},
        {   order_by => { '-desc' => 'created' },
            rows     => 5
        } )->search_related( 'entry_tags' )->search_related( 'tag' )->all;

    return values %tags;
}

1;
