use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name       => 'W3C::SOAP::WADL',
    license           => 'perl',
    dist_author       => 'Ivan Wills <ivan.wills@gmail.com>',
    dist_version_from => 'lib/W3C/SOAP/WADL.pm',
    requires          => {
        'perl'                         => '5.006',
        'File::ShareDir'               => 0,
        'JSON'                         => 0,
        'List::Util'                   => 0,
        'Moose'                        => 0,
        'Moose::Role'                  => 0,
        'Moose::Util::TypeConstraints' => 0,
        'MooseX::Types::Moose'         => 0,
        'Path::Class'                  => 0,
        'Scalar::Util'                 => 0,
        'Template'                     => 0,
        'TryCatch'                     => 0,
        'W3C::SOAP::Utils'             => '0.1.0',
        'W3C::SOAP::XSD'               => '0.1.0',
        'XML::Rabbit'                  => 0,
        'XML::Rabbit::Root'            => 0,
        'version'                      => 0,
    },
    configure_requires => {
        'Module::Build' => 0.38,
    },
    build_requires => {
        'Test::More'        => 0,
        'Test::NoWarnings'  => 0,
        'Mojolicious::Lite' => 0,
        'WWW::Mechanize'    => 0,
    },
    recommends => {
        'Test::Spelling'     => 0,
        'Test::Perl::Critic' => 0,
        'Test::Kwalitee'     => 0,
        'Pod::Coverage'      => 0,
    },
    share_dir => {
        dist => [
            'templates',
        ],
    },
    add_to_cleanup     => [ 'W3C-SOAP-WADL-*' ],
    create_makefile_pl => 'traditional',
    create_license     => 1,
    meta_merge         => {
        resources => {
            repository => 'git://github.com/ivanwills/W3C-SOAP-WADL.git',
            bugtracker => 'http://rt.cpan.org/NoAuth/Bugs.html?Dist=W3C::SOAP::WADL',
        },
    },
);

$builder->create_build_script();
