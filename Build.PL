use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
	module_name       => 'W3C::SOAP::WADL',
	license           => 'perl',
	dist_author       => 'Ivan Wills <ivan.wills@gmail.com>',
	dist_version_from => 'lib/W3C/SOAP/WADL.pm',
	requires          => {
		'perl'             => 5.008,
	},
	build_requires => {
		'Test::More'       => 0,
		'Test::NoWarnings' => 0,
	},
	add_to_cleanup     => [ 'W3C-SOAP-WADL-*' ],
	create_makefile_pl => 'traditional',
	create_license     => 1,
	meta_merge => {
		resources => {
			repository => 'git://github.com/ivanwills/W3C-SOAP-WADL.git',
			bugtracker => 'http://rt.cpan.org/NoAuth/Bugs.html?Dist=W3C::SOAP::WADL',
		},
	},
);

$builder->create_build_script();
