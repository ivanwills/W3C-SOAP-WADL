package W3C::SOAP::WADL::Parser;

# Created on: 2013-04-21 10:52:01
# Create by:  Ivan Wills
# $Id$
# $Revision$, $HeadURL$, $Date$
# $Revision$, $Source$, $Date$

use Moose;
use version;
use Carp;
use Scalar::Util;
use List::Util;
#use List::MoreUtils;
use Data::Dumper qw/Dumper/;
use English qw/ -no_match_vars /;
use W3C::SOAP::Utils qw/ns2module/;
use W3C::SOAP::WADL::Document;
use Path::Class;
use File::ShareDir qw/dist_dir/;
use Moose::Util::TypeConstraints;
use W3C::SOAP::Utils qw/split_ns/;
use W3C::SOAP::XSD;
use W3C::SOAP::WADL;
use W3C::SOAP::WADL::Traits;
use W3C::SOAP::WADL::Meta::Method;

Moose::Exporter->setup_import_methods(
    as_is => ['load_wadl'],
);

extends 'W3C::SOAP::Parser';

our $VERSION = version->new('0.0.1');

has '+document' => (
    isa      => 'W3C::SOAP::WADL::Document',
    required => 1,
    handles  => {
        module          => 'module',
        has_module      => 'has_module',
        ns_module_map   => 'ns_module_map',
        module_base     => 'module_base',
        has_module_base => 'has_module_base'
    },
);

around BUILDARGS => sub {
    my ($orig, $class, @args) = @_;
    my $args
        = !@args     ? {}
        : @args == 1 ? $args[0]
        :              {@args};

    # keep the interface the same as other W3C::SOAP parsers but need to
    # support XML::Rabbits parameters
    $args->{file} = $args->{location} if $args->{location};
    $args->{xml}  = $args->{string}   if $args->{string};

    return $class->$orig($args);
};

sub write_modules {
    my ($self) = @_;
    confess "No lib directory setup" if !$self->has_lib;
    confess "No module name setup"   if !$self->has_module;
    confess "No template object set" if !$self->has_template;

    my $wadl = $self->document;
    my $template = $self->template;
    my $file     = $self->lib . '/' . $self->module . '.pm';
    $file =~ s{::}{/}g;
    warn $file = file $file;
    my $parent = $file->parent;
    my @missing;
    while ( !-d $parent ) {
        push @missing, $parent;
        $parent = $parent->parent;
    }
    mkdir $_ for reverse @missing;


    warn Dumper $self->document;
    warn $self->document->_file;
}

my %cache;
sub load_wadl {
    my ($location) = @_;
    return $cache{$location} if $cache{$location};

    my $parser = __PACKAGE__->new(
        location => $location,
    );

    my $class = $parser->dynamic_classes;
    return $cache{$location} = $class->new;
}

sub dynamic_classes {
    my ($self) = @_;
    my @classes;

    for my $resources (@{ $self->document->resources }) {
        my $class_name = "Dynamic::WADL::" . ns2module($resources->path);
        push @classes, $class_name;
        my %methods;

        for my $resource (@{ $resources->resource }) {
            for my $method (@{ $resource->method }) {
                my $request  = $self->build_method_object( $class_name, $resources, $resource, $method, $method->request );
                my %responses;
                eval { $method->response };
                if ( $method->has_response ) {
                    for my $response (@{ $method->response }) {
                        $responses{$response->status} = $self->build_method_object( $class_name, $resources, $resource, $method, $response );
                    }
                }

                my $name = $resource->path . '_' . uc $method->name;
                $methods{$name} = W3C::SOAP::WADL::Meta::Method->wrap(
                    body         => sub { shift->_request( $name => @_ ) },
                    package_name => $class_name,
                    name         => $name,
                    path         => $resource->path,
                    method       => $method->name,
                    request      => $request,
                    response     => \%responses,
                );
            }
        }

        my $class = Moose::Meta::Class->create(
            $class_name,
            superclasses => [ 'W3C::SOAP::WADL' ],
            methods      => \%methods,
        );
        $class->add_attribute(
            '+location',
            default => $resources->path,
        );
    }

    return $classes[0];
}

sub build_method_object {
    my ( $self, $base, $resources, $resource, $method, $type ) = @_;
    my $class_name = $base . '::' . $resource->path . uc $method->name;
    $class_name .= '::' . $type->status if $type->can('status') && $type->status;

    my $class = Moose::Meta::Class->create(
        $class_name,
        superclasses => [ 'W3C::SOAP::WADL::Element' ],
    );

    $self->add_params( $class, $resources );
    $self->add_params( $class, $resource );
    $self->add_params( $class, $type );

    return $class_name;
}

sub add_params {
    my ($self, $class, $container) = @_;
    eval {$container->param};

    if ( $container->has_param ) {
        for my $param (@{ $container->param }) {
            my $name = $param->name;
            $name =~ s/\W/_/g;

            $class->add_attribute(
                $name,
                is            => 'rw',
                isa           => 'Str', # TODO Get type validation done
                predicate     => 'has_' . $name,
                required      => $param->required && $param->required eq 'true' ? 1 : 0,
                documentation => eval { $param->doc } || '',
                traits        => [qw{ W3C::SOAP::WADL }],
                style         => $param->style,
                real_name     => $param->name,
            );
        }
    }

    return;
}

1;

__END__

=head1 NAME

W3C::SOAP::WADL::Parser - <One-line description of module's purpose>

=head1 VERSION

This documentation refers to W3C::SOAP::WADL::Parser version 0.1.


=head1 SYNOPSIS

   use W3C::SOAP::WADL::Parser;

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
