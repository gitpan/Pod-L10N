#!/usr/bin/perl -w

use strict;
use Test::More;

use Cwd;
use Pod::L10N::Html;
use Config;
use File::Spec::Functions;

BEGIN {
    chdir 't' if -d 't';
    unshift @INC, qw( ../lib ../lib/Pod/t );
}

END {
    # pod2html creates these
    1 while unlink "pod2htmd.tmp";
    1 while unlink "pod2htmi.tmp";
}

if ($] < 5.007) {
    plan skip_all => "Test::Output unreliable on 5.6.x, this is $]";
}
elsif (do {eval "use Test::Output" or $@}) {
    plan skip_all =>'Test::Output not available';
}
else {
    plan tests => 1;
}


my $CWD      = Cwd::cwd();
my $CACHEDIR = "$CWD/subdir";

	convert_ok("minimal.pod", "xminimal.html", "minimal", <<EOM, ["--cachedir=$CACHEDIR"]
EOM
);

sub convert_ok {
    my $podfile  = shift;
    my $htmlfile = shift;
    my $testname = shift;
    my $expect = shift;
    my @extra_args = @{shift || []};

    my $base_dir = catdir $CWD, updir(), $ENV{PERL_CORE} ? ("lib", "Pod") : (curdir());
    my $infile   = $podfile;
    my $outfile  = "$htmlfile-t";


    stderr_is(
	sub {Pod::L10N::Html::pod2html(
        "--podpath=t",
        "--podroot=$base_dir",
        "--infile=$infile",
        "--outfile=$outfile",
        @extra_args,
	    )}, $expect, $testname) and do {
        # remove the results if the test succeeded
        1 while unlink $outfile;
    };
}
