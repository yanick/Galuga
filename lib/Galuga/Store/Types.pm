use Galuga::Store::Types;

use strict;
use warnings;

use MooseX::Storage::Engine;

use MooseX::Types -declare => [qw/
    URIClass
    DateTimeClass
    SetClass;
/];

use MooseX::Types::Moose qw/ Object /;

use Moose::Util::TypeConstraints;
use URI;
use Set::Object;
use DateTime;
use DateTime::Format::ISO8601;

class_type 'SetClass' => { class => 'Set::Object' };

coerce 'SetClass' => from 'ArrayRef' => via { Set::Object->new(@{shift @_}) };

MooseX::Storage::Engine->add_custom_type_handler(
    'SetClass' => (
        expand   => sub { Set::Object->new(@{shift @_}) },
        collapse => sub { [ (shift)->elements ] },
    ),
);

class_type 'URIClass' =>  { class => 'URI' };

coerce URIClass => from 'Str' => via { URI->new(shift) };

class_type 'DateTimeClass' => { class => 'DateTime' };

MooseX::Storage::Engine->add_custom_type_handler(
    'DateTimeClass' => (
        expand   => sub { DateTime::Format::ISO8601->parse_datetime(shift) },
        collapse => sub { (shift)->iso8601 },
    ),
);
MooseX::Storage::Engine->add_custom_type_handler(
    'URIClass' => (
        expand   => sub { URI->new(shift) },
        collapse => sub { (shift)->as_string },
    ),
);


1;
