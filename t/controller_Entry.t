use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'Catalyst::Test', 'Galuga' }
BEGIN { use_ok 'Galuga::Controller::Entry' }

ok( request('/entry')->is_success, 'Request should succeed' );
done_testing();
