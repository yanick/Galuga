#!/usr/bin/perl 

use strict;
use warnings;

use Galuga::Schema;

Galuga::Schema->connect( 'dbi:SQLite:read.sqlite' )->deploy;



