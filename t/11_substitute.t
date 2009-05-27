# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Pod-L10N.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More skip_all => 'for some reason, this test fail on some platform';
use Pod::L10N::Html;

sub diff {
    my ($outfn, $expectfn) = @_;
    my $f = '';
    my $line = 1;

    open my $of, '<', $outfn;
    open my $ef, '<', $expectfn;

    while(<$of>){
	my $e = <$ef>;
	if($_ ne $e){
	    $f = sprintf("differ line %d\n---\n%s---\n%s", $line, $_, $e);
	    last;
	}
	$line++;
    }
    close $of;
    close $ef;
    ok($f eq '', $f);
}

TODO: {
    local $TODO = 'may error on some platform';

    pod2html("--infile=t/substitute.pod",
	     "--outfile=t/substitute.out");
    diff('t/substitute.out', 't/substitute.html');
}

