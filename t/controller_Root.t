use strict;
use warnings;
use Test::More;

use Test::WWW::Mechanize::Catalyst 'Galuga';

my $mech = Test::WWW::Mechanize::Catalyst->new;

$mech->get_ok('/entries');

done_testing();
