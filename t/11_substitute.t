# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Pod-L10N.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 1;
use Pod::L10N::Html;

sub diff {
    my ($outfn, $expectfn) = @_;
    my $f = 0;

    open my $of, '<', $outfn;
    open my $ef, '<', $expectfn;

    while(<$of>){
	my $e = <$ef>;
	if($_ ne $e){
	    $f = 1;
	    last;
	}
    }
    close $of;
    close $ef;
    ok($f == 0, 'output differ');
}

{
    pod2html("--infile=t/substitute.pod",
	     "--outfile=t/substitute.out");
    diff('t/substitute.out', 't/substitute.html');
}

