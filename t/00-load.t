#!/usr/bin/perl

use strict;
use warnings;
use Test::More tests => 1 + 1;
use Test::NoWarnings;

BEGIN {
	use_ok( 'W3C::SOAP::WADL' );
}

diag( "Testing W3C::SOAP::WADL $W3C::SOAP::WADL::VERSION, Perl $], $^X" );
