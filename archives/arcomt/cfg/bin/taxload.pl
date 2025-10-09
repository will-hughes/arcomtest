#!/usr/bin/perl

use strict;
use warnings;
use DBI;

my $dbh = DBI->connect("DBI:mysql:database=arcomt", "eprints", "FRGmDrtWuaG93J6M") 
    or die "Could not connect to database: $DBI::errstr";

# Clear existing data
$dbh->do("TRUNCATE TABLE taxonomy");

# Load CSV
open my $fh, "<:encoding(utf8)", "/opt/eprints3/archives/arcomt/taxonomy.csv" or die "Cannot open CSV: $!";
my $header = <$fh>;  # Read and discard the header line
my $sth = $dbh->prepare("INSERT INTO taxonomy (iterm, domain, subject, facet, lword) VALUES (?, ?, ?, ?, ?)");

while (<$fh>) {
    chomp;
    print "RAW LINE: $_\n";  # DEBUG
    my ($iterm, $facet, $domain, $subject, $lword) = split /,/;
     print "PARSED: iterm='$iterm', lword='$lword'\n"; # DEBUG
    $sth->execute($iterm, $domain, $subject, $facet, $lword);
}

close $fh;
$dbh->disconnect;

print "Taxonomy loaded successfully!\n";
