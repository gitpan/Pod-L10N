use strict;
use warnings;
use Test::More;

if ($] < 5.008) {
    plan skip_all => "Test::Pod with pre-5.8 handle =encoding poorly";
}
elsif (do {eval "use Test::Pod 1.00" or $@}) {
    plan skip_all => 'Test::Pod 1.00 required for testing POD';
}

all_pod_files_ok();
