package W3C::SOAP::WADL::Parser;

# Created on: 2013-04-21 10:52:01
# Create by:  Ivan Wills
# $Id$
# $Revision$, $HeadURL$, $Date$
# $Revision$, $Source$, $Date$

use Moose;
use version;
use Carp;
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
use MooseX::Types::Moose qw/Str Int HashRef/;
use JSON qw/decode_json/;

Moose::Exporter->setup_import_methods(
    as_is => ['load_wadl'],
);

extends 'W3C::SOAP::Parser';

our $VERSION = version->new('0.004');

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
    my $class_base = $self->document->module || 'Dynamic::WADL';

    for my $resources (@{ $self->document->resources }) {
        my $class_name = $class_base . '::' . ns2module($resources->path);
        my $file       = $self->lib . '/' . $self->module . '.pm';
        $file =~ s{::}{/}g;
        my %methods;

        for my $resource (@{ $resources->resource }) {
            for my $method (@{ $resource->method }) {
                my $request  = $self->write_method_object(
                    $class_name,
                    $resources,
                    $resource,
                    $method,
                    $method->request
                );

                my %responses;
                eval { $method->response };
                if ( $method->has_response ) {
                    for my $response (@{ $method->response }) {
                        $responses{$response->status}
                            = $self->write_method_object(
                                $class_name,
                                $resources,
                                $resource,
                                $method,
                                $response,
                            );
                    }
                }

                my $name = $resource->path . '_' . uc $method->name;
                $methods{$name} = {
                    package_name => $class_name,
                    name         => $name,
                    path         => $resource->path,
                    method       => $method->name,
                    request      => $request,
                    response     => \%responses,
                };
            }
        }

        $self->write_module(
            'wadl/pm.tt',
            {
                module   => $class_base,
                methods  => \%methods,
                location => $resources->path,
            },
            $file,
        );
    }

    return;
}

my %written;
sub write_module {
    my ($self, $tt, $data, $file) = @_;
    my $template = $self->template;

     if ($written{$file}++) {
        warn "Already written $file!\n";
        return;
    }

    $template->process($tt, $data, "$file");
    confess "Error in creating $file (via $tt): ". $template->error."\n"
        if $template->error;
}

sub write_method_object {
    my ( $self, $base, $resources, $resource, $method, $type ) = @_;
    my $class_name = $base . '::' . $resource->path . uc $method->name;
    $class_name .= '::' . $type->status if $type->can('status') && $type->status;
    my $file = $self->lib . '/' . $class_name . '.pm';
    $file =~ s{::}{/}g;

    $self->write_module(
        'wadl/element.pm.tt',
        {
            module => $class_name,
            params => [ $resources, $resource, $type ],
            representations => $type,
        },
        $file,
    );

    return $class_name;
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
                        $responses{$response->status}
                            = $self->build_method_object(
                                $class_name,
                                $resources,
                                $resource,
                                $method,
                                $response,
                            );
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
    $self->add_representations( $class, $class_name, $type );

    return $class_name;
}

sub add_params {
    my ($self, $class, $container) = @_;
    eval {$container->param};

    if ( $container->has_param ) {
        for my $param (@{ $container->param }) {
            my $name = $param->name;
            $name =~ s/\W/_/g;

            my $required = !!( ( $param->required || '' ) eq 'true' );
            $class->add_attribute(
                $name,
                is            => 'rw',
                isa           => Str, # TODO Get type validation done
                predicate     => 'has_' . $name,
                required      => $required,
                documentation => eval { $param->doc } || '',
                traits        => [qw{ W3C::SOAP::WADL }],
                style         => $param->style,
                real_name     => $param->name,
            );
        }
    }

    return;
}

sub add_representations {
    my ( $self, $class, $base, $type ) = @_;
    my %rep_map;

    eval { $type->representation };
    if ( $type->has_representation ) {
        for my $rep (@{ $type->representation }) {
            eval { $rep->media_type };
            $rep->media_type('text/plain') unless $rep->media_type;

            # work out if the representation has a matching class
            $rep_map{ $rep->media_type } = {};
        }
    }

    # Add the representations as semi constant
    $class->add_attribute(
        '_representations',
        is        => 'ro',
        isa       => HashRef,
        predicate => 'has_representations',
        default   => sub { \%rep_map },
    );

    return;
}

1;

__END__

=head1 NAME

W3C::SOAP::WADL::Parser - Parses a WADL file and produces a client for
calling the specified webservice.

=head1 VERSION

This documentation refers to W3C::SOAP::WADL::Parser version 0.1.

=head1 SYNOPSIS

   use W3C::SOAP::WADL::Parser;

   # generate a dynamic WADL object.
   my $ws = load_wadl('http://localhost/myws.wadl');


=head1 DESCRIPTION

C<W3C::SOAP::WADL> parses WADL files to generate WADL clients. The clients
can be either dynamic clients where the client is regenerated each time
the code is run see L<load_wadl> or static client where the clients are
written to disk as Perl modules and C<use>d by programs see L<write_modules>

=head1 SUBROUTINES/METHODS

=head2 C<write_modules ()>

Writes all the module WADL clients (and XSDs if found) to disk

=head2 C<write_module ()>

Helper to writes the top level WADL client object.

=head2 C<write_method_object ()>

Writes the modules that contain the WADL method details.

=head2 C<load_wadl($file_or_url)>

Generates a WADL client in memory for the passed WADL file/URL.

=head2 C<dynamic_classes ()>

Generates all the method classes.

=head2 C<build_method_object ()>

Generates all the individual method classes.

=head2 C<add_params ()>

Adds the parameters for a method

=head2 C<add_representations ()>

Adds the representations that a method can take

=head1 DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

=head1 INCOMPATIBILITIES

=head1 BUGS AND LIMITATIONS

There are no known bugs in this module.

Please report problems to Ivan Wills (ivan.wills@gmail.com).

Patches are welcome.

=head1 AUTHOR

Ivan Wills - (ivan.wills@gmail.com)

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2013 Ivan Wills (14 Mullion Close, Hornsby Heights, NSW Australia 2077).
All rights reserved.

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself. See L<perlartistic>.  This program is
distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.

=cut
