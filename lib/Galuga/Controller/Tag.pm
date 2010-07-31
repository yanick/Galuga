package Galuga::Controller::Tag;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

Galuga::Controller::Tag - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args {
    my ( $self, $c, @tags ) = @_;

    $c->log->debug( "filtering out tags: @tags" );

    return unless @tags; 
    
    
    my $tags = $c->model('DB::Tags')->search({}, {
             group_by => 'tag',
              select => [
                    'tag',
                  { count => 'entry_path' }
              ],
              as => [ qw/ tag nbr_entries / ],
         } );

    $c->stash->{tags} = [ $tags->all ];


    $c->stash->{selected_tags} = [ @tags ];

    my @entries = $c->model('DB::Tags')->search({})->get_column('entry_path')->all;

    while ( @tags and @entries ) {
        @entries = $c->model('DB::Tags')->search({ tag => shift @tags,
                entry_path => { IN => \@entries
                } })->get_column('entry_path')->all
    }

    $c->stash->{entries} = [
        $c->model('DB::Entries')->search({ path => { IN => \@entries } })->all
    ];

}


=head1 AUTHOR

Yanick Champoux,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
