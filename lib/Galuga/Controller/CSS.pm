package Galuga::Controller::CSS;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

Galuga::Controller::css - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub general_style :Path('galuga.css') :Args(0) {
    my ( $self, $c ) = @_;

    $c->res->content_type('text/css');
    $c->stash->{template} = 'css/galuga.css';
}


=head1 AUTHOR

Yanick Champoux,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
