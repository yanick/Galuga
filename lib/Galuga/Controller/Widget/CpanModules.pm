package Galuga::Controller::Widget::CpanModules;
use Moose;
use namespace::autoclean;

use LWP::Simple;
use JSON;
use DateTime::Format::Flexible;
use Template::Declare;

BEGIN {extends 'Catalyst::Controller'; }

sub distributions {
    my( $self, $c ) = @_;
 
    my $page =
      LWP::Simple::get sprintf 'http://api.metacpan.org/dist/_search?q=author:"%s"',
      $c->config->{widgets}{cpan_modules}{author};
 
    my $json = from_json($page);
 
    return map { {
            name    => $_->{name},
            version => $_->{version},
            url     => 'http://search.cpan.org/dist/' . $_->{name},
            date    => DateTime::Format::Flexible->parse_datetime(
                $_->{release_date}
            ), } }
           map { $_->{_source} }
               @{ $json->{hits}{hits} };
 
}

sub index :Path  {
    my ( $self, $c ) = @_;

    my $widget = $c->cache->get( __PACKAGE__ );

    unless ( $widget ) {
        Template::Declare->init( dispatch_to => [
                'Galuga::Controller::Widget::CpanModules::Template' ] );

        $widget =  Template::Declare->show( 'widget',
                         $self->distributions($c) ); 

        $c->cache->set( __PACKAGE__, $widget, '1 day' );
    }

    $c->response->body( $widget );
}

__PACKAGE__->meta->make_immutable;

package Galuga::Controller::Widget::CpanModules::Template;

use Template::Declare::Tags;
use base 'Template::Declare';

template widget => sub {
    my ( $self, @distributions ) = @_;
    div {
        class is "widget cpan_modules";
        h3 { "CPAN Modules" };
        show( 'distribution', $_ ) for reverse sort { $a->{date} <=> $b->{date} } @distributions;
    };
    script {
        outs_raw <<'END_JAVASCRIPT';
var $dist = $('.cpan_modules .distribution:eq(2)')
    .nextAll()
    .wrapAll('<div/>')
    .addClass('cpan_modules_more')
    .hide()
    .end();

if( $dist.length > 0 ) {
    $('<a href="javascript:void(0)">show all</a>')
    .addClass('more')
    .appendTo( '.cpan_modules' )
    .click( function(){
        $(this).hide();
        $('.cpan_modules_more').show();
    });
}
END_JAVASCRIPT
    };
};

template distribution => sub {
    my $self = shift;
    my $dist = shift;

    div {
        class is 'distribution';
        div { class is 'name'; a { href is $dist->{url}; $dist->{name} } };
        div { class is 'version'; $dist->{version}; };
        div { class is 'date'; $dist->{date}->strftime( '%e %b %Y' ); };
    }

};

1;
