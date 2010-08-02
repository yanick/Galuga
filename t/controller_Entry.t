use strict;
use warnings;
use Test::More;


         # We're in a t/*.t test script...
         use Test::WWW::Mechanize::Catalyst 'Galuga';
                                     my $mech =
                                     Test::WWW::Mechanize::Catalyst->new;

$mech->get_ok('/entry/shuck-and-awe-5');

done_testing();
