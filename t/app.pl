#!/usr/bin/perl

use Mojolicious::Lite;

# This is a test script of a dynamic wadl

get '/wadl' => sub {
    my ($self) = @_;

    $self->render('wadl');
};

app->start;

__DATA__

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
            </method>

        </resource>
    </resources>
</application>
