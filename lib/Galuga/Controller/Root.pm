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

sub entries :Path( 'entries' ) :Args(0) {
    my ( $self, $c ) = @_;


    my $tags = $c->model('DB::Tags')->search({}, {
             group_by => 'tag',
              select => [
                    'tag',
                  { count => 'entry_path' }
              ],
              as => [ qw/ tag nbr_entries / ],
         } );

    $c->stash->{tags} = [ $tags->all ];
    # the whole she-bang

    $c->stash->{entries} = [ $c->model('DB::Entries')->search({},{order_by=>{
                '-desc' => 'created' } } )->all ];
}

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    my $entry = $c->model('DB::Entries')->search({},
        { order_by => { '-desc' => 'created' }, limit => 1 }
    );

    $c->go( '/entry/index', [ $entry->next->url ] );
}

sub feed :Path('atom.xml') :Args(0) {
    my ( $self, $c ) = @_;

    # get the last 10 entries and wrap'em
    my @entries = $c->model('DB::Entries')->search({},
        { order_by => { '-desc' => 'created' }, limit => 10 }
    );

    my $feed = XML::Atom::SimpleFeed->new( 
        title => $c->config->{blog_url},
        link => $c->config->{blog_url},
        updated => $entries[0]->created->iso8601,
        author => $c->config->{blog_author},
    );

    for ( @entries ) {
        $feed->add_entry(
            title => $_->title,
            link => $c->uri_for( '/entry', $_->url ),
            content => {
                type => 'xhtml',
                content => $_->body,
            },
            updated => $_->created->iso8601,
        );
    }

    $c->res->content_type( 'application/atom+xml' );
    $c->res->body( $feed->as_string );
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
