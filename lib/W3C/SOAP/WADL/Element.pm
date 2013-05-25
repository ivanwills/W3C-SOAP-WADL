package W3C::SOAP::WADL::Element;

# Created on: 2013-04-27 21:58:42
# Create by:  Ivan Wills
# $Id$
# $Revision$, $HeadURL$, $Date$
# $Revision$, $Source$, $Date$

use Moose;
use version;
use Carp qw/carp croak cluck confess longmess/;
use Scalar::Util;
use List::Util;
#use List::MoreUtils;
use Data::Dumper qw/Dumper/;
use English qw/ -no_match_vars /;


our $VERSION     = version->new('0.0.1');
our @EXPORT_OK   = qw//;
our %EXPORT_TAGS = ();
#our @EXPORT      = qw//;

around BUILDARGS => sub {
    my ($orig, $class, @args) = @_;
    my $args
        = !@args     ? {}
        : @args == 1 ? $args[0]
        :              {@args};

    if ( blessed $args
        && ( $args->isa('HTTP::Request') || $args->isa('HTTP::Response') )
    ) {
        my $http = $args;
        my $uri  = $http->can('uri') ? $http->uri : undef;
        $args = {};

        my %map = $class->_map_fields;

        # process headers
        for my $header ( $http->header_field_names ) {
            if ( $map{$header} ) {
                $args->{ $map{$header} } = $http->header($header);
            }
            elsif ( $map{lc $header} ) {
                $args->{ $map{lc $header} } = $http->header($header);
            }
            else {
                $args->{$header} = $http->header($header);
            }
        }

        # process URI params
        if ( $uri ) {
            my @query = $uri->query_form;
            while ( my $key = shift @query ) {
                my $value = shift @query;
                # TODO make work with multiple values
                $args->{ $map{$key} } = $value;
            }
        }
    }

    return $class->$orig($args);
};

sub _map_fields {
    my ($self) = @_;
    my $meta = $self->meta;

    my @parent_nodes;
    my @supers = $meta->superclasses;
    for my $super (@supers) {
        push @parent_nodes, $super->_map_fields
            if $super ne __PACKAGE__ && UNIVERSAL::can($super, '_map_fields');
    }

    return @parent_nodes, map {
            $meta->get_attribute($_)->real_name => $_,
            lc $meta->get_attribute($_)->real_name => $_
        }
        grep {
            $meta->get_attribute($_)->does('W3C::SOAP::WADL::Traits')
        }
        $meta->get_attribute_list;
}

sub _get_headers {
    my ($self) = @_;
    my $meta = $self->meta;
    my %headers;

    for my $name ( $meta->get_attribute_list ) {
        my $attr = $meta->get_attribute($name);
        next if !$attr->does('W3C::SOAP::WADL');
        next if !$attr->style eq 'header';

        my $has = 'has_' . $name;
        next if !$self->$has;

        $headers{$attr->real_name} = $self->$name;
    }

    return %headers;
}

my $urlencode = sub {
    my $url = shift;
    $url =~ s/(\W)/sprintf('%%%x',ord($1))/eg;
    return $url;
};
sub _get_query {
    my ($self) = @_;
    my $meta = $self->meta;
    my %query;

    for my $name ( $meta->get_attribute_list ) {
        my $attr = $meta->get_attribute($name);
        next if !$attr->does('W3C::SOAP::WADL');
        next if !$attr->style eq 'query';

        my $has = 'has_' . $name;
        next if !$self->$has;

        $query{ $urlencode->( $attr->real_name )} = $urlencode->( $self->$name );
        $query{$attr->real_name} = $self->$name;
    }

    return wantarray ? %query : join '&', map { "$_=$query{$_}"} keys %query;
}

1;

__END__

=head1 NAME

W3C::SOAP::WADL::Element - <One-line description of module's purpose>

=head1 VERSION

This documentation refers to W3C::SOAP::WADL::Element version 0.1.


=head1 SYNOPSIS

   use W3C::SOAP::WADL::Element;

   # Brief but working code example(s) here showing the most common usage(s)
   # This section will be as far as many users bother reading, so make it as
   # educational and exemplary as possible.


=head1 DESCRIPTION

A full description of the module and its features.

May include numerous subsections (i.e., =head2, =head3, etc.).


=head1 SUBROUTINES/METHODS

A separate section listing the public components of the module's interface.

These normally consist of either subroutines that may be exported, or methods
that may be called on objects belonging to the classes that the module
provides.

Name the section accordingly.

In an object-oriented module, this section should begin with a sentence (of the
form "An object of this class represents ...") to give the reader a high-level
context to help them understand the methods that are subsequently described.




=head1 DIAGNOSTICS

A list of every error and warning message that the module can generate (even
the ones that will "never happen"), with a full explanation of each problem,
one or more likely causes, and any suggested remedies.

=head1 CONFIGURATION AND ENVIRONMENT

A full explanation of any configuration system(s) used by the module, including
the names and locations of any configuration files, and the meaning of any
environment variables or properties that can be set. These descriptions must
also include details of any configuration language used.

=head1 DEPENDENCIES

A list of all of the other modules that this module relies upon, including any
restrictions on versions, and an indication of whether these required modules
are part of the standard Perl distribution, part of the module's distribution,
or must be installed separately.

=head1 INCOMPATIBILITIES

A list of any modules that this module cannot be used in conjunction with.
This may be due to name conflicts in the interface, or competition for system
or program resources, or due to internal limitations of Perl (for example, many
modules that use source code filters are mutually incompatible).

=head1 BUGS AND LIMITATIONS

A list of known problems with the module, together with some indication of
whether they are likely to be fixed in an upcoming release.

Also, a list of restrictions on the features the module does provide: data types
that cannot be handled, performance issues and the circumstances in which they
may arise, practical limitations on the size of data sets, special cases that
are not (yet) handled, etc.

The initial template usually just has:

There are no known bugs in this module.

Please report problems to Ivan Wills (ivan.wills@gmail.com).

Patches are welcome.

=head1 AUTHOR

Ivan Wills - (ivan.wills@gmail.com)
<Author name(s)>  (<contact address>)

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2013 Ivan Wills (14 Mullion Close, Hornsby Heights, NSW Australia 2077).
All rights reserved.

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself. See L<perlartistic>.  This program is
distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.

=cut
