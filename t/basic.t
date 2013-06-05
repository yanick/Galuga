use strict;
use warnings;

use Test::More tests => 1;

use Galuga;

use Dancer2::Test apps => [ 'Galuga' ];

response_content_is '/entries' => '';

