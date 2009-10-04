use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Tie::Hash::Interpolate',
    AUTHOR              => q{Dan Boorstein <danboo@cpan.org>},
    VERSION_FROM        => 'lib/Tie/Hash/Interpolate.pm',
    ABSTRACT_FROM       => 'lib/Tie/Hash/Interpolate.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More'   => 0,
        'Scalar::Util' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Tie-Hash-Interpolate-*' },
);
