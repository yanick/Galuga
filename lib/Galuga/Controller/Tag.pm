package Galuga::Controller::Tag;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Galuga::Controller::Tag - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

=cut

sub index : Path : Args {
    my ( $self, $c, @tags ) = @_;

    $c->log->debug("filtering out tags: @tags");

    return unless @tags;

    $c->stash->{selected_tags} = [@tags];

    my @entries;

    if ( my $t = $c->model('DB::Tags')->find({label => shift @tags}) ) {
        @entries = $t->search_related('entry_tags')->search_related('entry')->all;
    }

    while ( @tags and @entries ) {
        my $tag = $c->model('DB::Tags')->find({label => shift @tags });
        unless ( $tag ) {
            @entries = ();
            last;
        };
        @entries = grep { $_->count_related('entry_tags', { tag_id => $tag->id } ) }
                    @entries;
    }

    $c->stash->{entries} = [ @entries ];

}

=head1 AUTHOR

Yanick Champoux,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
