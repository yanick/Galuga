package Galuga;

use utf8;

use Path::Tiny;

use Dancer2 ':syntax';

use Dancer2::Plugin::Feed;

use Galuga::Store;
use MIME::Types;

our $VERSION = '0.1';

my $store = Galuga::Store->new(
    blog_repository => config->{blog_repository},
    db => config->{store},
);

get '/feed/:format' => sub {

    my @entries = map {{
        title => $_->title,
        content => $_->html_body,
        issued => $_->created,
        link => uri_for( '/entry/' . $_->uri ),
        base => uri_for('/'),	
    }} most_recent_entries();

    create_feed(
        link => uri_for('/'),
        format => param('format'),
        title => config->{blog}{title},
        tagline => config->{blog}{tagline},
        author => config->{blog}{author},
        language => config->{blog}{language},
        modified => $entries[0]->{issued},
        entries => \@entries,
    );
};

get '/entry/:entry' => sub {

    my $entry = $store->get( 'Entry' => param('entry') ) 
        or return pass;

    return template '/entry' => {
        entry => $entry,
        recent_entries => [ most_recent_entries() ],
    };
};

get '/entry/*/files/**' => sub {
    my( $entry, $path ) = splat;
    
    $entry = $store->get( 'Entry' => $entry ) 
        or return pass;

    my $mimetypes = MIME::Types->new;

    send_file path(config->{blog_repository})->child($entry->path)->parent->child(
        'files', @$path )->stringify, content_type => $mimetypes->mimeTypeOf( $path->[-1]
        ), system_path => 1;
};

get '/' => sub {
    my( $latest ) = most_recent_entries(1);

    redirect '/entry/' . $latest->uri;
};

get '/entries' => sub {

    template '/entries' => {
        recent_entries => [ most_recent_entries() ],
        entries         => [ $store->search('Entry')->order_by('created DESC')->all 
        ],
    };
};

sub most_recent_entries {
    my $num = shift || 5;

    my $s = $store->search('Entry')->order_by('created DESC');

    my @entries;
    while( my $e = $s->next ) {
        push @entries, $e;
        last unless $num--;
    }

    return @entries; 
}


true;
