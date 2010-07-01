#!/usr/bin/perl -w

use strict;
use Test::More tests => 26;

use Cwd;
use Pod::L10N::Html;
use Config;
use File::Spec::Unix;

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

is(
    Pod::L10N::Html::relativize_url(
        catfile(qw(foo file.txt)),
        catfile(qw(foo other.txt))
    ),
    catfile( curdir(), 'file.txt' ),
    'relativize_url in current dir'
);

is(
    Pod::L10N::Html::relativize_url(
        catfile(qw(foo file.txt)),
        catfile(qw(foo bar other.txt))
    ),
    catfile( updir(), 'file.txt' ),
    'relativize_url in parent dir'
);

is(
    Pod::L10N::Html::relativize_url(
        catfile(qw(dog rat ding file.txt)),
        catfile(qw(dog rat other.txt))
    ),
    catfile( 'ding', 'file.txt' ),
    'relativize_url in child dir'
);

is(
    Pod::L10N::Html::relativize_url(
        '',
        catfile(qw(rat house.txt))
    ),
    '',
    'relativize_url in current dir'
);

{
    my $str = 'a B<bold> move';
    is( Pod::L10N::Html::_depod(\$str), 'a bold move', '_depod ref');
}

is( Pod::L10N::Html::_fragment_id_obfuscated('@#$'), '%40%23%24',
    'obfuscated fragment id' );

is( Pod::L10N::Html::_fragment_id_obfuscated('@#$ab'), '%40%23%24ab',
    'obfuscated fragment 2' );

convert_ok("torture.pod", "torture.html", "torture",
    [qw[--quiet --flush
        --libpods=perlunitut:perlflute:perlmore:perlutil.pod
	], "--cachedir=$CACHEDIR"]
);

convert_ok("fragment.pod", "fragment.html", "basic well-formed");

convert_ok("fragment.pod", "f-root.html",   "basic htmlroot",
    [qw[--htmlroot=http://www.example.com/doc]]);

convert_ok("fragment.pod", "f-html.html",   "htmldir",
    [qw[--htmlroot=http://www.example.com/doc --htmldir=html]]);

convert_ok("fragment.pod", "html/f-html.html",  "htmldir explicit",
    [qw[--htmldir=html]]);

convert_ok("fragment.pod", "f-html2.html",  "htmldir different",
    [qw[--htmldir=html]]);

convert_ok("fragment.pod", "f-basic.html",   "basic no htmlroot");
convert_ok("fragment.pod", "f-head.html",    "basic w/ header",
    [qw[--header --backlink=omega]]);

convert_ok("fragwin.pod", "fragwin.html",   "MS-DOS line-endings");

TODO: {
    local $TODO = 'non-exist module link with fragment cannot handle yet';
	convert_ok("xref.pod", "xref.html", "xref", ["--cachedir=$CACHEDIR"]);
};

TODO: {
    local $TODO = 'pure-text heuristic xrefs are broken';
	convert_ok("xreftodo.pod", "xreftodo.html", "xref heuristics", ["--cachedir=$CACHEDIR"]);
};

convert_ok("noheads.pod", "noheads.html",   "no headings", [qw[--quiet]]);

convert_ok("noheads.pod", "noheadi.html",   "no headings noindex", [qw[--quiet --noindex]]);

convert_ok("htmlescp.pod", "htmlescp.html", "html escape");
convert_ok("htmllink.pod", "htmllink.html", "html links");
convert_ok("htmlview.pod", "htmlview.html", "html view");
convert_ok("htmlview.pod", "htmlviei.html", "html view noindex", [qw[--noindex]]);
convert_ok("htmlview.pod", "htmlviec.html", "html view noindex title",
    [qw[--css=/nullcss.css --title=PodPageTitle]]);

TODO: {
    local $TODO = 'blank lines mangled in explicit HTML blocks';
    convert_ok("rt-9385.pod", "rt-9385.html", "RT #9385");
};

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

    my $base_dir = catdir($CWD, updir(), $ENV{PERL_CORE} ? ("lib", "Pod") : (curdir()));
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

    is($expect, $result, $testname) and do {
        # remove the results if the test succeeded
        1 while unlink $outfile;
    };
}

sub catdir {
    File::Spec::Unix->catdir(@_);
}

sub catfile {
    File::Spec::Unix->catfile(@_);
}

sub canonpath {
    File::Spec::Unix->canonpath(@_);
}

sub curdir {
    File::Spec::Unix->curdir(@_);
}

sub updir {
    File::Spec::Unix->updir(@_);
}

