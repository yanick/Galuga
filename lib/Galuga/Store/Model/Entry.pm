package Galuga::Store::Model::Entry;

use utf8;

use strict;
use warnings;

use YAML;
use JSON;

use Moose;
use DateTime::Format::Flexible;
use Web::Query;
use Method::Signatures;
use Text::MultiMarkdown qw/ markdown /;
use HTML::Entities;
use Escape::Houdini ':html';

with 'DBIx::NoSQL::Store::Manager::Model';

has "path" => (
    traits => [ 'StoreIndex' ],
    isa => 'Str',
    is => 'ro',
    required => 1,
);

has "sha1" => (
    isa => 'Str',
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;

        my ( undef, undef, $sha1 ) = split ' ', $self->store_db->git->run( 'ls-tree', '-r',
            'HEAD', $self->path );

        return $sha1;
    },
);

has "raw" => (
    isa => 'HashRef',
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;

        my $content = join '', map { "$_\n" } $self->store_db->git->run( 'show', 'HEAD:'.$self->path);

        my %raw;
        if( $content =~ s/^(.*?\n)---\n//s ) {
            %raw = %{ Load($1) };
        }

        $raw{text} = $content;

        return \%raw;
    },
);

has "uri" => (
    traits => [ 'StoreKey' ],
    isa => 'Str',
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;

        my $uri = $self->raw->{url} || $self->raw->{uri};
        unless ( $uri ) {
            $uri = lc $self->title;
            $uri =~ y/ /_/;
        }

        return $uri;
    },
);

has "title" => (
    isa => 'Str',
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        
        return $self->raw->{title};
    },
);

has created => (
    traits => [ 'StoreIndex' ],
    isa => 'DateTime',
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;

        my $raw = $self->raw->{created};

        unless( $raw ) {
            ( $raw ) = reverse
                $self->store_db->git->run( 'log', '--pretty=%ai', $self->path
                    );
        }
        return DateTime::Format::Flexible->parse_datetime($raw);
    }
);

has last_updated => (
    isa => 'DateTime',
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;

        my $raw = $self->raw->{last_updated};

        unless( $raw ) {
            ( $raw ) = 
                $self->store_db->git->run( 'log', '--pretty=%ai', $self->path
                    );
        }
        return DateTime::Format::Flexible->parse_datetime($raw);
    }
);

has "format" => (
    isa => 'Str',
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        return $self->raw->{format} || 'markdown';
    },
);

has "html_body" => (
    isa => 'Str',
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        my $raw = $self->raw->{text};

        $raw = $self->process_markdown( $raw ) if $self->format eq 'markdown';

        return $raw;
    },
);


sub process_markdown {
    my( $self, $text ) = @_;

    # ``` stuff
    $text =~ s@^ ```\s*(\S*?) $(.*?) ```$
              @'<pre><code>' . ( "#syntax: $1" x !! $1 ) . $2 . '</code></pre>'
              @xmseg;

    my $doc = Web::Query->new( markdown( $text, { document_format => 'complete' } ) );

    $doc->find('pre code')->each( method ($node) {
           if ( $node->text =~ /^#syntax:\s+(\S+)/ ) {
               $node->attr( 'class' => $1 );
               $node->text( $node->text =~ s/^.*//r );
           }
    });

    # <cpan>
    $doc->find('cpan')->replace_with(sub{
        my $module = $_->text;    

        my $url = sprintf "https://metacpan.org/%s/%s", ($module =~ /-/ ? 'release' :
        'module'), $module;

        "<a href='$url'>$module</a>";
    });

    # <galuga_code>
    $doc->find('galuga_code')->replace_with(sub { 
        my $f = $_->text;
        my $lang = $_->attr('code');

        my $file = $self->path; 
        $file =~ s#/entry.*?$##;
        $file .= "/files/$f";

        my $inner = escape_html( join "\n", $self->store_db->git->run(
                'show', 'HEAD:'.$file ) );

        "<pre><code class='$lang'>$inner</code></pre>"; 
    });

    # links to __ENTRY_DIR__
    
    $doc->find('a')->each(sub{
        my $anchor = $_->attr('href');
        if( $anchor =~ s#__ENTRY_DIR__# '/entry/'.$self->uri.'/files' #e ) {
            $_->attr('href'=>$anchor);
        }
    });
    $doc->find('img')->each(sub{
        my $anchor = $_->attr('src');
        if( $anchor =~ s#__ENTRY_DIR__# '/entry/'.$self->uri.'/files' #e ) {
            $_->attr('src'=>$anchor);
        }
    });

    # play-perl links
    $doc->find('a')->each(sub{ 
        my $href = $_->attr('href');

        return unless $href =~ s#^play-perl:(.*)#http://questhub.io/perl/quest/$1#;
        my $sha1 = $1;

        $_->attr( href => $href );
        $_->attr( class => $_->attr('class') . ' play_perl' );

        use LWP::Simple;
        use JSON;

        my $quest = eval { JSON::decode_json LWP::Simple::get
            "http://questhub.io/api/quest/$sha1" 
        } or return;

        $_->attr( title => $quest->{name} ) unless $_->attr('title');
        $_->text( $quest->{name} ) unless $_->text;
    });

    # github links
    $doc->find('a')->each(sub{ 
        my $href = $_->attr('href');

        return unless $href =~ s#^gh:##;
        $href = "https://github.com/$href";

        $_->attr( href => $href );
        $_->attr( class => $_->attr('class') . ' github' );
    });

    # blog
    $doc->find('a')->each(sub{ 
        my $href = $_->attr('href');

        return unless $href =~ s#^blog:##;
        $href = "/entry/$href";

        $_->attr( href => $href );
        $_->attr( class => $_->attr('class') . ' blog_entry' );
    });

    # cpan
    $doc->find('a')->each(sub{ 
        my $href = $_->attr('href');

        return unless $href =~ s#^cpan:##;

        $href = "module/$href" unless $href =~ m#/#;

        $href = "https://metacpan.org/$href";

        $_->attr( href => $href );
        $_->attr( class => $_->attr('class') . ' cpan' );
    });

    my $body = join '', $doc->find('body')->html;

    return $body;
}


1;



