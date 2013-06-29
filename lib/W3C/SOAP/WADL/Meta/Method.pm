package W3C::SOAP::WADL::Meta::Method;

# Created on: 2012-07-15 19:45:13
# Create by:  Ivan Wills
# $Id$
# $Revision$, $HeadURL$, $Date$
# $Revision$, $Source$, $Date$

use Moose;
use warnings;
use version;
use Carp;
use Scalar::Util;
use List::Util;
#use List::MoreUtils;
use Data::Dumper qw/Dumper/;
use English qw/ -no_match_vars /;

extends 'Moose::Meta::Method';

our $VERSION     = version->new('0.0.7');

has name => (
    is        => 'rw',
    isa       => 'Str',
    predicate => 'has_name',
);
has path => (
    is        => 'rw',
    isa       => 'Str',
    required  => 1,
    predicate => 'has_path',
);
has method => (
    is        => 'rw',
    isa       => 'Str',
    required  => 1,
    predicate => 'has_method',
);
has request => (
    is        => 'rw',
    isa       => 'Str',
    predicate => 'has_request',
);
has response => (
    is        => 'rw',
    isa       => 'HashRef[Str]',
    predicate => 'has_response',
);


1;

__END__

=head1 NAME

W3C::SOAP::WADL::Meta::Method - <One-line description of module's purpose>

=head1 VERSION

This documentation refers to W3C::SOAP::WADL::Meta::Method version 0.0.7.


=head1 SYNOPSIS

   use W3C::SOAP::WADL::Meta::Method;

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

Copyright (c) 2012 Ivan Wills (14 Mullion Close, Hornsby Heights, NSW Australia 2077).
All rights reserved.

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself. See L<perlartistic>.  This program is
distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.

=cut
