#!/usr/bin/env perl 

use strict;
use warnings;

use 5.10.0;

use lib 'lib';

use FindBin qw($Bin);
use Config::General;
use File::chdir;
use XXX;
use autodie;
use Digest::MD5 qw/ md5_hex /;
use File::Slurp qw/ slurp /;
use YAML;

use Getopt::Long;

use Galuga::Schema;

GetOptions(
    'nuke!' => sub { unlink 'db.sqlite' },
);

my %conf = Config::General->new( "$Bin/../galuga.conf" )->getall;

my $schema = Galuga::Schema->connect( $conf{db} );

if ( not $schema->get_db_version ) {
    $schema->deploy;
}
elsif ( $schema->get_db_version cmp $Galuga::Schema::VERSION ) {
    $schema->upgrade;
}

local $CWD = $conf{blog_root};
    print $schema->resultset('Entries')->all;

my @entries = find_entries( '.' );

for ( @entries ) {

    import_entry( $schema, @$_ );
}

sub import_entry {
    my ( $schema, $path, $filename ) = @_;

    my $entry = $schema->resultset('Entries')->new_result({
            path => $path,
            filename => $filename,
        });


    my $file = slurp join '/', $path, $filename;

    my ( $header, $body ) = $file =~ /(.*?)^---$(.*)/sm;

    $header = Load($header);

    $entry->title( $header->{title} ||= path_to_title( $path ) );

    $entry->url( $header->{url} ||= title_to_url( $header->{title} ) );

    $entry->format( lc( $header->{format} || $filename =~ /^entry\.(.*)$/ ) || 'html' );

    $entry->md5(md5_hex($file));

    $entry->body( $body );

    $entry->insert;

    for ( @{ $header->{tags} } ) {
        $entry->create_related( 'tags', { tag => $_ } );
    }

}

sub title_to_url {
    my $title = shift;
    $title =~ y/ /_/;
    return lc $title;
}

sub path_to_title {
    my $path = shift;
    $path =~ s#^.*/##;
    $path =~ y/_/ /;
    $path = ucfirst $path;
    return $path;
}

sub find_entries {
    my $dirname = shift;

    my $dir;
    opendir $dir, $dirname;

    my @items = grep { !/^\.\.?$/ } readdir $dir;

    if ( my ( $entry ) = sort grep { -f "$dirname/$_" and /^entry(?:\..*)?$/ } @items ) {
        return [ $dirname, $entry ];
    }

    return map { find_entries( $_ ) } grep { -d $_ } map { "$dirname/$_" } @items;

}


