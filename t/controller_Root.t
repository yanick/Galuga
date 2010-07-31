use strict;
use warnings;
use Test::More;

         # We're in a t/*.t test script...
         use Test::WWW::Mechanize::Catalyst 'Galuga';
                                     my $mech =
                                     Test::WWW::Mechanize::Catalyst->new;

$mech->get_ok('/');

print $mech->content;

done_testing();
