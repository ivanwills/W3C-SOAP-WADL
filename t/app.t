#!/usr/bin/perl

use strict;
use warnings;
use v5.12;
use Test::More;
use Path::Class;
use W3C::SOAP::WADL::Parser;
use WWW::Mechanize;
use TryCatch;

my $app = file($0)->parent->file('app.pl');

my $pid = fork;

if ( !defined $pid ) {
    plan skip_all => "Couldn't start test server! $!\n";
    exit 0;
}
elsif ( !$pid ) {
    # Keep test output clean by hiding server details
    #close STDERR;
    #open STDERR, '>', '/dev/null';
    #close STDOUT;
    #open STDOUT, '>', '/dev/null';

    exec $app, 'daemon', '--listen', 'http://*:4000';
}

sleep 1;
my $mech = WWW::Mechanize->new;

try {
    my $parser = get_parser();
}
catch ($e) {
    ok !$e, 'no errors';
    diag $e;
}

kill 9, $pid or diag "Error killing child! $!\n";
done_testing();

sub get_parser {
    $mech->get('http://localhost:4000/wadl');
    my $wadl = $mech->content;
    ok $wadl, 'Get the WADL text from the server'
        or diag $mech->status;

    my $parser = W3C::SOAP::WADL::Parser->new( string => $wadl );
    ok $parser, 'Get a parser object';

    return W3C::SOAP::WADL::Parser->new( location => 'http://localhost:4000/wadl' );
}
