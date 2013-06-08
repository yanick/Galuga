package Galuga::Store;

use strict;
use warnings;

use Git::Repository;
use Try::Tiny;
use List::Pairwise qw/ grepp /;

use Moose;
use MooseX::Storage::Engine;
use DateTime::Format::ISO8601;

extends 'DBIx::NoSQL::Store::Manager';
with 'MooseX::Role::Loggable';

has branch => (
    is => 'ro',
    isa => 'Str',
    default => 'master',
);

has db => (
    is => 'ro',
    required => 1,
);

has blog_repository => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);

has git => (
    is => 'ro',
    lazy => 1,
    default => sub {
        return Git::Repository->new( work_tree => $_[0]->blog_repository );
    }
);

sub BUILD {
    $_[0]->connect( [ "dbi:SQLite:".$_[0]->db, undef, undef, {
            sqlite_unicode => 1,
        } ]);
}

sub update_entries {
    my $self = shift;
    
    my $arg = ( @_ and ref $_[-1]) ? pop @_ : {};
    my @dirs = @_;

    @dirs = map { qr/^\Q$_/ } @dirs;

    my @entries;


    my %git_entries =
        grepp { $a =~ m#/entry(.\w+)?$# }
        grepp { not @dirs or $a ~~ @dirs }
        map { (split)[-1,-2]  }
        $self->git->run( 'ls-tree', '-r', 'HEAD' );

    my $rs = $self->search('Entry');

    while( my $entry = $rs->next ) {
        next unless not @dirs or $entry->path ~~ @dirs;

        unless( $git_entries{$entry->path} ) {
            $self->log( $entry->path. " gone, removing" );
            $entry->delete;
            next;
        }

        if ( $git_entries{$entry->path} eq $entry->sha1 and not $arg->{force}) {
            delete  $git_entries{$entry->path};
            $self->log($entry->path . " didn't change" );
            next;
        }

        $self->log( $entry->path. " new version" );

        $self->create( 'Entry' => 
            path => $entry->path
        )->store;

        delete  $git_entries{$entry->path};
    }

    while( my ($k,$v) = each %git_entries ) {
        $self->log( "new entry $k" );
        try {
        $self->create('Entry' => 
            path => $k,
        )->store;
        }
        catch {
            $self->log( "couldn't create '$k': $_" );
        }
    }

    return;
} 


__PACKAGE__->meta->make_immutable;

MooseX::Storage::Engine->add_custom_type_handler(
    'DateTime' => (
        expand   => sub { DateTime::Format::ISO8601->parse_datetime(shift) },
        collapse => sub { (shift)->iso8601 },
    )
);

1;
