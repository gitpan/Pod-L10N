# 02_exception.t

use strict;
use Pod::L10N::Html;

use Test::More;

if (do {eval "use Test::Exception" or $@}) {
    plan skip_all =>'Test::Exception not available';
}
else {
    plan tests => 6;
}

my $no_such_path = '/on/a/path/to/nowhere';
if (-d $no_such_path) {
    my $suffix = 'a';
    my $new_path = "$no_such_path-$suffix";
    while (-d $new_path) {
        ++$suffix;
        $new_path = "$no_such_path-$suffix";
    }
    $no_such_path = $new_path;
}

dies_ok(
    sub {pod2html('--infile=t/die-end.pod', '--outfile=t/die-end.out')},
    'unmatched =end'
);

dies_ok(
    sub {pod2html('--infile=t/die-unbal.pod', '--outfile=t/die-unbal.out', '--quiet')},
    'mismatched =begin =end'
);

dies_ok(
    sub {pod2html('--infile=t/die-end.pod', '--outfile=t/die-end.out', "--cachedir=$no_such_path")},
    'cache directory DNE'
);

dies_ok(
    sub {pod2html('--infile=t/die-end.pod', "--outfile=$no_such_path")},
    'output directory DNE'
);

throws_ok(
    sub {pod2html('--help')}, qr/\AUsage:/,
    'usage'
);

dies_ok(
    sub {Pod::L10N::Html::relative_url('foo', 'bar')},
    'Pod::Html::relative_url() is fatally broken'
);
