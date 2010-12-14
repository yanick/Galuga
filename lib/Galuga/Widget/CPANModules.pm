package Galuga::Widget::CPANModules;

use 5.10.0;

use strict;
use warnings;

use Template::Declare::Tags;
use base 'Template::Declare';

use LWP::Simple;
use pQuery;
use DateTime::Format::Flexible;

template widget => sub {
    my $self = shift;
    my %arg  = @_;
    my $c    = $arg{c};

    div {
        attr { class => 'widget cpan_modules' };
        h3 { 'CPAN Modules' };

        show( 'module', %$_ ) for get_modules();
    }

};

template 'module' => sub {
    my ( $self, %arg ) = @_;
    
    div {
        div {
            a { href is $arg{url}; $arg{name} };
        };
        div { 
            $arg{version};
        };
        div { $arg{date}->strftime( '%b %e, %Y' ) };
    }

};

sub get_modules {
state $page = get "http://search.cpan.org/~yanick";

my $dists = pQuery( $page )->find('table:eq(1) tr');

my @dists;

$dists->each(sub{
        return unless shift;  # first one is headers

        my $row = pQuery($_);
        my $name = $row->find('td:eq(0) a')->text();

        $name =~ s/-v?([\d._]*)$//;  # remove version

        my $version = $1;

        my $url = "http://search.cpan.org/dist/$name";

        $name =~ s/-/::/g;

        my $desc = $row->find('td:eq(1)')->text();
        my $date = DateTime::Format::Flexible->parse_datetime(
            $row->find('td:eq(3)')->text );

        push @dists, {
            name => $name,
            url => $url,
            desc => $desc,
            date => $date,
            version => $version,
        };
});

return @dists = reverse sort { $a->{date} cmp $b->{date} } @dists;

}


1;


