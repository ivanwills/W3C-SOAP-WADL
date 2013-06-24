package W3C::SOAP::WADL::Document;

# Created on: 2013-04-21 10:44:31
# Create by:  Ivan Wills
# $Id$
# $Revision$, $HeadURL$, $Date$
# $Revision$, $Source$, $Date$

use strict;
use XML::Rabbit::Root;
use version;
use Carp;
use Data::Dumper qw/Dumper/;
use English qw/ -no_match_vars /;
use W3C::SOAP::WADL::Document::Resources;

our $VERSION     = version->new('0.0.1');

add_xpath_namespace wadl => 'http://wadl.dev.java.net/2009/02';
add_xpath_namespace json => 'http://rest.domain.gdl.optus.com.au/rest/3/common-json';

has_xpath_value target_namespace => './@targetNamespace';
has_xpath_value_list doc => './doc';

has_xpath_object grammars => (
    '//wadl:grammars' => 'W3C::SOAP::WADL::Document::Grammars',
);
has_xpath_object_list resources => (
    '//wadl:resources' => 'W3C::SOAP::WADL::Document::Resources',
);
has_xpath_object_list resource_type => (
    '//wadl:resource_type' => 'W3C::SOAP::WADL::Document::ResourceType',
);
has_xpath_object_list method => (
    '//wadl:method' => 'W3C::SOAP::WADL::Document::Method',
);
has_xpath_object_list representation => (
    '//wadl:representation' => 'W3C::SOAP::WADL::Document::Representation',
);
has_xpath_object_list param => (
    '//wadl:param' => 'W3C::SOAP::WADL::Document::Param',
);

has module => (
    is        => 'rw',
    isa       => 'Str',
    predicate => 'has_module',
);
has module_base => (
    is        => 'rw',
    isa       => 'Str',
    predicate => 'has_module_base',
);
has file => (
    is        => 'rw',
    isa       => 'Str',
    predicate => 'has_file',
);

finalize_class();

1;

__END__

=head1 NAME

W3C::SOAP::WADL::Document - <One-line description of module's purpose>

=head1 VERSION

This documentation refers to W3C::SOAP::WADL::Document version 0.1.


=head1 SYNOPSIS

   use W3C::SOAP::WADL::Document;

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
