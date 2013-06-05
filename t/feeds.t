use strict;
use warnings;

use Test::More tests => 2;

use Galuga;

use Dancer2::Test apps => [ 'Galuga' ];

response_status_is '/feed/atom' => 200;
response_status_is '/feed/rss' => 200;

