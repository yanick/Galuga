package Galuga::Controller::Entry;
use Moose;
use namespace::autoclean;

use List::MoreUtils qw/ uniq /;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

Galuga::Controller::Entry - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub base :Chained('') :PathPart( 'entry' ) :CaptureArgs(1) {
    my ( $self, $c, $url ) = @_;

    my $rs = $c->model('DB::Entries')->find({ url => $url }) or die;
    $c->stash->{entry} = $rs;

    $c->stash->{url} = $url;
}

sub files :Chained('base') :PathPart( 'files' ) :Args(1) {
    my ( $self, $c, $filename ) = @_;

    $c->serve_static_file(
        join '/', 
        $c->config->{blog_root},
        $c->stash->{entry}->path,
        'files',
        $filename
    );
}


sub index :Chained('base') :PathPart('') :Args(0) {
    my ( $self, $c ) = @_;

    my $url = $c->stash->{url};

    my $tags = $c->model('DB::Tags')->search({}, {
             group_by => 'tag',
              select => [
                    'tag',
                  { count => 'entry_path' }
              ],
              as => [ qw/ tag nbr_entries / ],
         } );

    $c->stash->{tags} = [ $tags->all ];


    my $rs = $c->stash->{entry};

    my $body = $rs->body;

    # __ENTRY_DIR__
    $body =~ s#__ENTRY_DIR__# $c->uri_for( "/entry/" . $rs->url . "/files" ) #eg;

    my @syntax;
    while ( $body =~ s#<pre \s+ code=(['"])(.*?)\1#<pre class="brush: $2" #xg ) {
        push @syntax, $2;
    }

    while ( $body =~ m#<pre \s+ class=(['"])brush:\s+(.*?);?\1#xg ) {
        push @syntax, $2;
    }

    $body =~ s#<cpan>(.*?)</cpan>#cpan_tag($1)#eg;
    $body =~ s#<galuga_entry>(.*?)</galuga_entry>#entry_tag( $c, $1)#eg;

    $c->stash->{syntax_highlight} = [ uniq @syntax ];

    $c->stash->{body} = $body;
    

}

sub entry_tag {
    my $c = shift;
    my $entry = shift;

    $entry = $c->model( 'DB::Entries' )->find({ url => $entry });

    return "<a href='" . $c->uri_for( '/entry/', $entry->url ) . "'>" 
                . $entry->title . "</a>";


}

sub cpan_tag {
    my $dist = shift;
    ( my $dist_url = $dist ) =~ s/::/-/g; 

    return "<a href='http://search.cpan.org/dist/$dist_url'>$dist</a>";
}


=head1 AUTHOR

Yanick Champoux,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
