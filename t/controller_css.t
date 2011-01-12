use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'Catalyst::Test', 'Galuga' }
BEGIN { use_ok 'Galuga::Controller::CSS' }

ok( request('/css')->is_success, 'Request should succeed' );
done_testing();
