use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		       => 'Class::ActsLike',
    'VERSION_FROM'	   => 'lib/Class/ActsLike.pm', # finds $VERSION
    'PREREQ_PM'		   => {
		'Test::More'   => 0.45,
		'Scalar::Util' => 1.02,
	},
);
