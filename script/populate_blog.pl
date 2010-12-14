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
use DateTime::Format::DateParse;

use Getopt::Long;

use Galuga::Schema;

GetOptions(
    'nuke!' => sub { unlink 'db.sqlite' },
);

my %conf = Config::General->new( "$Bin/../galuga.conf" )->getall;

$conf{blog_root} =~ s#__HOME__#$Bin/..#;

my $schema = Galuga::Schema->connect( $conf{db} );

if ( not $schema->get_db_version ) {
    $schema->deploy;
}
elsif ( $schema->get_db_version cmp $Galuga::Schema::VERSION ) {
    $schema->upgrade;
}

# first, the entries in the database
my $entries_rs = $schema->resultset('Entries')->search;

my %seen_entry;
while ( my $entry = $entries_rs->next ) {
    print "from DB, ", $entry->url, "\n";

    $seen_entry{ join '/', $conf{blog_root}, $entry->path }++;

    my $md5 = md5_hex( slurp join '/', $conf{blog_root}, $entry->path, $entry->filename );

    print "not modified\n" and next if $md5 eq $entry->md5;

    print "modified, reloading...\n";

    $entry->delete;

    import_entry( $schema, $conf{blog_root}, $entry->path, $entry->filename );
}

my @entries = find_entries( $conf{blog_root} );

for ( @entries ) {

    next if delete $seen_entry{ $_->[0] };

    print "new entry $_->[0]/$_->[1] discovered\n";

    $_->[0] =~ s#^\Q$conf{blog_root}/##;

    import_entry( $schema, $conf{blog_root}, @$_ );
}

sub import_entry {
    my ( $schema, $blog_root, $path, $filename ) = @_;

    print "importing $path/$filename\n";

    my $entry = $schema->resultset('Entries')->new_result({
            path => $path,
            filename => $filename,
        });


    my $file = slurp join '/', $blog_root, $path, $filename;

    my ( $header, $body ) = $file =~ /(.*?)^---$(.*)/sm;

    $header = Load($header);

    $entry->title( $header->{title} ||= path_to_title( $path ) );

    $entry->url( $header->{url} ||= title_to_url( $header->{title} ) );


    $entry->created( DateTime::Format::DateParse->parse_datetime(
            $header->{created} ) );

    $entry->last_updated( DateTime::Format::DateParse->parse_datetime(
            $header->{last_updated} || $header->{created} ) );

    $entry->md5(md5_hex($file));

    $entry->original( $header->{original} );

    my $format = lc( $header->{format} || $filename =~ /^entry\.(.*)$/ ) || 'html';

    my $module = 'Galuga::Format::' . $format;
    eval "use $module";

    $entry->body( '<div>'.$module->render( $body ).'</div>' );

    use XML::LibXML;
    my $dom = XML::LibXML->load_xml( string => $entry->body );

    $entry->insert;

    for ( @{ $header->{tags} } ) {
        $entry->add_to_tags( { label => $_ } ) unless $entry->tags({label =>
                $_ })->search->count > 0;
    }

}

sub title_to_url {
    my $title = shift;
    $title =~ y/ /-/;
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


