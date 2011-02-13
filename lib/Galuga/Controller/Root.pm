package Galuga::Controller::Root;
use Moose;
use namespace::autoclean;

use XML::Feed;
use XML::Atom::SimpleFeed;

BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(namespace => '');

=head1 NAME

Galuga::Controller::Root - Root Controller for Galuga

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 index

The root page (/)

=cut

sub tags :Path('tags') :Args(0) {
    my ( $self, $c ) = @_;

    # get all tags and their tally
    my %tags = map { $_->label => $_->count_related( 'entry_tags' ) } $c->model('DB::Tags')->search->all;
    my @tags = sort { $tags{$a} <=> $tags{$b} } keys %tags;

    for my $i ( 0..$#tags ) {
        $tags{$tags[$i]} = int( 24 * ($i+1) / @tags );
    }
    
    $c->stash->{tags} = \%tags;

    return;
}

sub entries :Path( 'entries' ) :Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{tags} = {
        map { $_->label => $_->count_related( 'entry_tags' ) } $c->model('DB::Tags')->search->all
    };

    $c->stash->{entries} = [ $c->model('DB::Entries')->search({},{order_by=>{
                '-desc' => 'created' } } )->all ];
}

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    my $entry = $c->model('DB::Entries')->search({},
        { order_by => { '-desc' => 'created' }, limit => 1 }
    );

    $c->res->redirect( 
        $c->uri_for( 'entry', $entry->next->url )
    );
}

sub sitemap :Path('sitemap') :Args(0) {
    my ( $self, $c ) = @_;

    $c->res->body( $c->sitemap_as_xml );
}

sub feed :Path('atom.xml') :Args(0) :Sitemap {
    my ( $self, $c ) = @_;

    # get the last 10 entries and wrap'em
    my @entries = $c->model('DB::Entries')->search({},
        { order_by => { '-desc' => 'created' }, rows => 10 }
    );

    my $feed = XML::Atom::SimpleFeed->new( 
        title => $c->config->{blog_url},
        link => $c->config->{blog_url},
        updated => $entries[0]->created->iso8601,
        author => $c->config->{blog_author},
    );

    for ( @entries ) {

        my $body = $_->body;

    # __ENTRY_DIR__
    $body =~ s#__ENTRY_DIR__# $c->uri_for( "/entry/" . $_->url . "/files" ) #eg;

    $body =~
    s#(<galuga_code.*?</galuga_code>)#Galuga::Controller::Entry::code_snippet( $c, $_, $1 )#eg;

    $body =~ s#<pre \s+ code=(['"])(.*?)\1#<pre class="brush: $2" #xg;

    $body =~ s#<cpan>(.*?)</cpan>#Galuga::Controller::Entry::cpan_tag($1)#eg;
    $body =~ s#<galuga_entry>(.*?)</galuga_entry>#Galuga::Controller::Entry::entry_tag( $c, $1)#eg;

        $feed->add_entry(
            title => $_->title,
            link => $c->uri_for( '/entry', $_->url ),
            content => {
                type => 'xhtml',
                content => $body,
            },
            updated => $_->created->iso8601,
        );
    }

    $c->res->content_type( 'application/atom+xml' );
    $c->res->body( $feed->as_string );

    $c->cache_page( 60 * 60 );
}

=head2 default

Standard 404 error page

=cut

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {}

=head1 AUTHOR

Yanick Champoux,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
