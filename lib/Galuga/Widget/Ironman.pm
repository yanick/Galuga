package Galuga::Widget::Ironman;

use strict;
use warnings;

use Template::Declare::Tags;
use base 'Template::Declare';

template widget => sub {
    my $self   = shift;
    my $c      = shift;
    my $id     = $c->config->{widget}{ironman}{id};
    my $gender = $c->config->{widget}{ironman}{gender} || 'male';

    div {
        attr { class => 'widget ironman' };
        h3 {
            a {
                href is 'http://ironman.enlightenedperl.org/';
                'Perl Iron Man Challenge';
            }
        };

        div {
            align is 'center';
            img {
                attr { alt => 'Perl Iron Man Challenge badge' };
                src is
                  "http://ironman.enlightenedperl.org/munger/mybadge/$gender/${id}.png";
            };
        }

    }

};

1;

