package Galuga;
use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.80;

# Set flags and add plugins for the application
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

use Catalyst qw/
    ConfigLoader
    Static::Simple
    Cache 
    Sitemap
    VersionedURI
    SubRequest
    PageCache
/;
# PageCache

extends 'Catalyst';

our $VERSION = '0.4.0';
$VERSION = eval $VERSION;

# Configure the application.
#
# Note that settings in galuga.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.

__PACKAGE__->config(
    name => 'Galuga',
    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback => 1,
    default_view => 'Mason',
    static => {
                   ignore_dirs => [ 'css' ],
               },
   'Plugin::Cache' => {
       backend => {
           class => 'Cache::FileCache',
       } },
   'Plugin::PageCache' => {
       set_http_headers => 1,
   },
);

# Start the application
__PACKAGE__->setup();


=head1 NAME

Galuga - Catalyst based application

=head1 SYNOPSIS

    script/galuga_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<Galuga::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Yanick Champoux,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
