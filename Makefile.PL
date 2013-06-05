use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Galuga',
    AUTHOR              => q{YOUR NAME <youremail@example.com>},
    VERSION_FROM        => 'lib/Galuga.pm',
    ABSTRACT            => 'YOUR APPLICATION ABSTRACT',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'YAML'       => 0,
        'Dancer2'     => 0,
	'Dancer2::Template::Caribou' => 0,
	'Dancer2::Plugin::Feed' => 0,
	'MooseX::Storage::Engine' => 0,
	'DateTime::Format::ISO8601' => 0,
	'DBIx::NoSQL::Store::Manager' => 0,
	'MooseX::Role::Loggable' => 0,
	'Web::Query' => 0,
	'Escape::Houdini' => 0,
	'MooseX::ClassAttribute' => 0.27,
	'Moose' => 2.0802,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Galuga-*' },
);
