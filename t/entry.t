use strict;
use warnings;

use Test::More tests => 1;

use Galuga::Store::Model::Entry;

is( Galuga::Store::Model::Entry->new(
    store_db => 1,
    path => 'foo/entry',
    raw => { title => 'hello there' },
)->uri => 'hello_there' );

is( Galuga::Store::Model::Entry->new(
    store_db => 1,
    path => 'foo/entry',
    raw => { url => 'xxx' },
)->uri => 'xxx' );

subtest 'markdown' => sub {
    plan tests => 1;

    like( Galuga::Store::Model::Entry->new(
        store_db => 1,
        path => 'foo/entry',
        format => 'markdown',
        raw => { text => <<'END' },
this is 

    #syntax: perl
    old style

stuff
END
    )->html_body => qr#<pre><code class="perl"># );

    like( Galuga::Store::Model::Entry->new(
        store_db => 1,
        path => 'foo/entry',
        format => 'markdown',
        raw => { text => <<'END' },
this is 

``` ada
new style
```

stuff
END
    )->html_body => qr#<pre><code class="ada"># 
);


};


like( Galuga::Store::Model::Entry->new(
    store_db => 1,
    path => 'foo/entry',
    format => 'markdown',
    raw => { text => <<'END' },
<cpan>Moose</cpan>
END
    )->html_body => qr#<a href="https://metacpan.org/module/Moose">Moose</a># 
);

