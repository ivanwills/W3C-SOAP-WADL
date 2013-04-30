#!/usr/bin/perl

use Mojolicious::Lite;

# This is a test script of a dynamic wadl

get '/wadl' => sub {
    my ($self) = @_;

    $self->render('wadl');
};

my $x_r = 0;
my $i_r = 1;
get '/ping' => sub {
    my ($self) = @_;

    $self->res->headers->header('X-Response-ID', $x_r++);
    $self->res->headers->header('I-Response-ID', $i_r++);
    $self->render_json({message => 'get'});
};
post '/ping' => sub {
    my ($self) = @_;

    $self->res->headers->header('X-Response-ID', $x_r++);
    $self->res->headers->header('Response-ID', $i_r++);

    if ( !$self->req->headers->{'I-Status'} ) {
        $self->render(json => {message => 'post'}, status => 200 );
    }
    elsif ( $self->req->headers->{'I-Status'} == 400 ) {
        $self->render(status => 400 );
    }
    elsif ( $self->req->headers->{'I-Status'} == 401 ) {
        $self->types->type( multi => "x-application-urlencoded" );
        $self->render(text => "multi=true", format => 'multi', status => 401 );
    }
    elsif ( $self->req->headers->{'I-Status'} == 402 ) {
        $self->types->type( form => "application/x-www-form-urlencoded" );
        $self->render(text => "multi=true&form=1", format => 'form', status => 402 );
    }
    elsif ( $self->req->headers->{'I-Status'} == 403 ) {
        $self->types->type( url => "multipart/form-data" );
        $self->render(text => "multi=true&form=1&url=u", format => 'url', status => 403 );
    }
    else {
        $self->render(json => {message => 'post'}, status => 200 );
    }
};

app->start;

__DATA__

@@ ping.json.ep
{"message":"pong"}

@@ wadl.html.ep
<?xml version="1.0" encoding="UTF-8"?>
<application xmlns="http://wadl.dev.java.net/2009/02"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:tns="http://rest.domain.gdl.optus.com.au/rest/3/service/bis/ping"
    xmlns:json="http://rest.domain.gdl.optus.com.au/rest/3/common-json"
    xsi:schemaLocation="http://wadl.dev.java.net/2009/02 wadl20090202.xsd
                     http://rest.domain.gdl.optus.com.au/rest/3/service/bis/ping ping.xsd">

    <doc xml:lang="en" title="Business - Ping" version="${project.version}">
        This service provides basic "ping" functionality which allows the calling
        clients/partners to test their connectivity to the platform.
    </doc>
    <resources path="http://localhost:4000/">
        <resource path="ping" id="Ping">
            <method name="GET" id="ping">
                <doc xml:lang="en" title="Ping">
                    A calling client/partner can request a GET ping to the server
                    to ensure connectivity.
                </doc>
                <request>
                    <param name="X-Request-ID"             style="header" type="xs:string" required="true"/>
                    <param name="X-Request-DateTime"       style="header" type="xs:string" required="true"/>
                    <param name="X-Request-TimeZone"       style="header" type="xs:string" required="true"/>
                    <param name="X-Partner-ID"             style="header" type="xs:string" required="true"/>
                    <param name="I-Request-ID"             style="header" type="xs:string" required="false"/>
                    <param name="I-Correlation-Request-ID" style="header" type="xs:string" required="false"/>
                    <param name="I-Partner-ID"             style="header" type="xs:string" required="false"/>
                    <param name="message"                  style="query"  type="xs:string" required="false"/>
                </request>
                <response status="200">
                    <param name="X-Response-ID"             style="header" type="xs:string" required="true"/>
                    <param name="I-Response-ID"             style="header" type="xs:string" required="false"/>
                    <param name="I-Correlation-Response-ID" style="header" type="xs:string" required="false"/>
                    <representation mediaType="application/json"
                        json:serialize="au.com.optus.gdl.rest.domain.v3.service.ping.dto.PingResponse"/>
                </response>
                <response status="400"/>
            </method>

            <method name="POST" id="pingPost">
                <doc xml:lang="en" title="Ping">
                    A calling client/partner can request a POST ping the server
                    to ensure connectivity.
                </doc>
                <request>
                    <param name="X-Request-ID"             style="header" type="xs:string" required="true"/>
                    <param name="X-Request-DateTime"       style="header" type="xs:string" required="true"/>
                    <param name="X-Request-TimeZone"       style="header" type="xs:string" required="true"/>
                    <param name="X-Partner-ID"             style="header" type="xs:string" required="true"/>
                    <param name="I-Request-ID"             style="header" type="xs:string" required="false"/>
                    <param name="I-Correlation-Request-ID" style="header" type="xs:string" required="false"/>
                    <param name="I-Partner-ID"             style="header" type="xs:string" required="false"/>
                    <param name="I-Status"                 style="header" type="xs:string" required="false"/>
                    <representation mediaType="application/json"
                        json:serialize="au.com.optus.gdl.rest.domain.v3.service.ping.dto.PingRequest"/>
                </request>
                <response status="200">
                    <param name="Response-ID"               style="header" type="xs:string" required="true"/>
                    <param name="X-Response-ID"             style="header" type="xs:string" required="true"/>
                    <param name="I-Response-ID"             style="header" type="xs:string" required="false"/>
                    <param name="I-Correlation-Response-ID" style="header" type="xs:string" required="false"/>
                    <representation mediaType="application/json"
                        json:serialize="au.com.optus.gdl.rest.domain.v3.service.ping.dto.PingResponse"/>
                </response>
                <response status="400"/>
                <response status="401">
                    <representation mediaType="x-application-urlencoded">
                        <param name="multi" style="query" type="xs:string" required="true" />
                    </representation>
                </response>
                <response status="402">
                    <representation mediaType="application/x-www-form-urlencoded">
                        <param name="form" style="query" type="xs:string" required="true" />
                    </representation>
                </response>
                <response status="403">
                    <representation mediaType="multipart/form-data">
                        <param name="url" style="query" type="xs:string" required="true" />
                    </representation>
                </response>
                <response status="412">
                    <representation mediaType="application/json"
                        json:serialize="au.com.optus.gdl.rest.domain.v3.service.ping.dto.PingResponse"/>
                </response>
            </method>

        </resource>
    </resources>
</application>
