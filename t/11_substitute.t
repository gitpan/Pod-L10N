use Test::More tests => 1;

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

my $CWD      = Cwd::cwd();
my $CACHEDIR = "$CWD/subdir";

# l10n conversion
convert_ok("substitute.pod", "substitute.html", "l10n substitution");

sub slurp {
    my $file = shift;
    open my $in, $file or die "cannot open $file for input: $!";
    local $/ = undef;
    my $rec = <$in>;
    close $in;
    return $rec;
}

sub convert_ok {
    my $podfile  = shift;
    my $htmlfile = shift;
    my $testname = shift;
    my @extra_args = @{shift || []};

    my $base_dir = catdir $CWD, updir(), $ENV{PERL_CORE} ? ("lib", "Pod") : (curdir());
    my $infile   = $podfile;
    my $outfile  = "$htmlfile-t";

    Pod::L10N::Html::pod2html(
        "--podpath=t",
        "--podroot=$base_dir",
        "--infile=$infile",
        "--outfile=$outfile",
        @extra_args,
    );

    my $result = slurp($outfile);

    my $expect = slurp($htmlfile);
    $expect =~ s/\[PERLADMIN\]/$Config::Config{perladmin}/;

    is($result, $expect, $testname) and do {
        # remove the results if the test succeeded
        1 while unlink $outfile;
    };
}

