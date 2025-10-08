#!/usr/bin/perl

use lib "/opt/eprints3/perl_lib";
use Text::CSV;

print "=== RAW CSV DEBUG ===\n";

my $csv = Text::CSV->new({ binary => 1 });
open my $fh, "<:encoding(utf8)", '/opt/eprints3/archives/arcomt/taxonomy_test.csv' or die "Cannot open: $!";

# Read header
my $header = $csv->getline($fh);
print "Header: " . join(" | ", @$header) . "\n\n";

# Read first few rows and show exactly what we get
my $row_count = 0;
while( my $row = $csv->getline($fh) ) {
    $row_count++;
    
    print "Row $row_count:\n";
    print "  Raw row: " . join(" | ", @$row) . "\n";
    print "  Number of columns: " . scalar(@$row) . "\n";
    
    # Try to access each column
    for(my $i = 0; $i < @$row; $i++) {
        print "  Column $i: '" . ($row->[$i] // 'UNDEF') . "'\n";
    }
    
    last if $row_count >= 3; # Just show first 3 rows
}

close $fh;
