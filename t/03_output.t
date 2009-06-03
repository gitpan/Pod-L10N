# 03_output.t

use strict;
use Cwd;
use Pod::L10N::Html;

use Test::More;
if ($] < 5.007) {
    plan skip_all => "Test::Output unreliable on 5.6.x, this is $]";
}
elsif (do {eval "use Test::Output" or $@}) {
    plan skip_all =>'Test::Output not available';
}
else {
    plan tests => 14;
}

my $CWD       = Cwd::cwd();
my $CACHEDIR  = "$CWD/t/subdir";

stderr_is(
    sub {pod2html('--infile=t/fragment.pod', '--outfile=t/fragment.out')},
    <<EOM, 'no news is good news'
t/03_output.t: t/fragment.pod: cannot resolve L<Test::Pod::Html::Dummy> in paragraph 5.
EOM
);

stderr_is(
   sub {pod2html('--outfile=t/fragment.out', 't/fragment.pod')},
    <<EOM, 'no news is better news'
t/03_output.t: t/fragment.pod: cannot resolve L<Test::Pod::Html::Dummy> in paragraph 5.
EOM
);

stderr_is(
    sub {pod2html('--infile=t/unclosed.pod', '--outfile=t/unclosed.out')},
    <<EOM, 'unclosed'
t/03_output.t: t/unclosed.pod: undelimited <> in paragraph 3: 'bold'.
t/03_output.t: t/unclosed.pod: undelimited C<> in paragraph 4 (_go_ahead): 'code'.
EOM
);

stderr_is(
    sub {pod2html('--infile=t/unclosed.pod', '--outfile=t/unclosed.out', '--quiet')},
    '',
    'unclosed silent'
);

stderr_is( sub {pod2html(
        '--infile=t/notitle.pod',
        '--outfile=t/notitle.out',
        '--verbose',
    )}, <<EOM, 'no title' );
Scanning for sections in input file(s)
adopted 'My Title' as title for t/notitle.pod
Converting input file t/notitle.pod
Finished
EOM

stderr_is( sub {pod2html(
        "--infile=t/xref.pod",
        "--outfile=t/xref.out",
        "--htmlroot=/",
        "--podpath=t",
        "--cachedir=t",
        "--norecurse",
        "--verbose",
    )}, <<EOM, 'xref norecurse' );
Scanning for sections in input file(s)
t/03_output.t: t/xref.pod: cannot resolve L<torture/GWAP> in paragraph .
t/03_output.t: t/xref.pod: cannot resolve L<Test Torture|torture> in paragraph .
scanning directories in pod-path
caching items for later use
caching directories for later use
Converting input file t/xref.pod
t/03_output.t: t/xref.pod: cannot resolve L<Pod::Html::TestFragment/\$var> in paragraph 8.
Finished
EOM

stderr_is( sub {pod2html(
        "--infile=t/xref.pod",
        "--outfile=t/xref.out",
        "--htmlroot=/",
        "--podpath=t",
        "--cachedir=$CACHEDIR",
        "--verbose",
    )}, <<EOM, 'xref' );
Scanning for sections in input file(s)
scanning for item cache
scanning directories in pod-path
caching items for later use
caching directories for later use
Converting input file t/xref.pod
t/03_output.t: t/xref.pod: cannot resolve L<Pod::Html::TestFragment/\$var> in paragraph 8.
Finished
EOM

stderr_like( sub {pod2html(
        '--infile=t/noheads.pod',
        '--outfile=t/noheads.out',
        '--verbose',
    )},
    qr(\A\QScanning for sections in input file(s)
No headings in t/noheads.pod
t/03_output.t: no title for t/noheads.pod.
using \E\S+ at \S+ line \d+\Q.
scanning for item cache
loading item cache
scanning for directory cache
loading directory cache
Converting input file t/noheads.pod
Finished\E\Z),
    'no headings'
);

stderr_like(
    sub {eval{pod2html(
        '--infile=t/notitle.txt',
        '--outfile=t/notitle.out',
        '--verbose',
    )}},
    qr(\A\QScanning for sections in input file(s)
t/03_output.t: no title for t/notitle.txt.
using \E\S+ at \S+ line \d+\Q.
Converting input file t/notitle.txt
Finished\E\Z),
    'non-POD verbose title' );

stderr_like(
    sub {eval {pod2html('--aieee', '--infile=pam.pod')}},
    qr/\AUnknown option: aieee
\S+: -: invalid parameters
\Z/,
    'bad opt'
);

my @para = (14);
push @para, $para[-1]+1;
push @para, $para[-1]+21;
push @para, $para[-1]+10;
push @para, $para[-1]+5;
push @para, $para[-1]+3;
push @para, $para[-1]+1;
push @para, $para[-1]+10;

my $error_message = <<EOM;
t/03_output.t: t/torture.pod: invalid Z<> in paragraph $para[0].
t/03_output.t: t/torture.pod: unknown pod directive 'bogus' in paragraph $para[1].  ignoring.
t/03_output.t: t/torture.pod: unexpected =back directive in paragraph $para[2].  ignoring.
t/03_output.t: t/torture.pod: invalid X<> in paragraph $para[3].
t/03_output.t: t/torture.pod: unknown pod directive 'comment' in paragraph $para[4].  ignoring.
t/03_output.t: t/torture.pod: unexpected =item directive in paragraph $para[5].  ignoring.
t/03_output.t: t/torture.pod: cannot resolve L<impossible> in paragraph $para[6].
t/03_output.t: t/torture.pod: unterminated list(s) at =head in paragraph $para[7].  ignoring.
EOM

chomp $error_message;

stderr_is( sub {pod2html('--infile=t/torture.pod', '--outfile=t/torture.out')},
    <<EOM, 'torture carp' );
t/03_output.t: no title for t/torture.pod.
$error_message
EOM

my $error_qm = quotemeta($error_message);

my $re = qr(\A\QScanning for sections in input file(s)
t/03_output.t: no title for t/torture.pod.
using \E\S+ at \S+ line \d+\Q.
Converting input file t/torture.pod
\E$error_qm
Finished\Z);

combined_like( sub {pod2html(
        '--infile=t/torture.pod',
        '--outfile=t/torture.out',
        '--verbose',
    )}, $re, 'torture verbose' );

$re = qr(\A\QFlushing item and directory caches
Scanning for sections in input file(s)
t/03_output.t: no title for t/torture.pod.
using t/torture.pod at \E\S+ line \d+\Q.
scanning directories in pod-path
caching items for later use
caching directories for later use
Converting input file t/torture.pod
\E$error_qm
Finished\Z);

combined_like( sub {pod2html(
        '--infile=t/torture.pod',
        '--outfile=t/torture.out',
        '--verbose',
        '--flush',
        '--recurse',
        '--podroot=t',
    )}, $re, 'torture verbose and recurse' );

TODO: {
    local $TODO = 'direct to STDOUT writes to >-, not STDOUT';
    stdout_is( sub {pod2html(
            '--infile=t/noheads.pod',
        )}, slurp('t/noheads.html'), 'direct STDOUT'
    );
};

sub slurp {
    my $file = shift;
    open my $in, $file or die "cannot open $file for input: $!";
    local $/ = undef;
    my $rec = <$in>;
    close $in;
    return $rec;
}
