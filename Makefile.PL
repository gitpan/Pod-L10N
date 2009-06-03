use 5;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Pod::L10N',
    VERSION_FROM      => 'lib/Pod/L10N/Html.pm', # finds $VERSION
    PREREQ_PM         => {}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (
	   ABSTRACT       => 'handle POD with L10N',
	   EXE_FILES      => [qw(bin/pod2htmll10n)],
           LICENSE        => 'perl',
	   AUTHOR         => 'SHIRAKATA Kentaro <argrath@cpan.org>') : ()),
);
