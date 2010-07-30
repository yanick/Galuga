package Galuga::Controller::Entry;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

Galuga::Controller::Entry - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(1) {
    my ( $self, $c, $url ) = @_;

    my $rs = $c->model('DB::Entries')->find({ url => $url }) or die;

    $c->stash->{entry} = $rs;

    my $module = 'Galuga::Format::' . $rs->format;
    eval "use $module";
    
    $c->stash->{body} = $module->render( $rs->body );

}


=head1 AUTHOR

Yanick Champoux,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
