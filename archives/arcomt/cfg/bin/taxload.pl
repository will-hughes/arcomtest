#!/usr/bin/perl

use strict;
use warnings;
use DBI;

my $dbh = DBI->connect("DBI:mysql:database=arcomt", "eprints", "your_password_here") 
    or die "Could not connect to database: $DBI::errstr";

# Clear existing data
$dbh->do("TRUNCATE TABLE taxonomy");

# Load CSV
open my $fh, "<:encoding(utf8)", "taxonomy_common_test.csv" or die "Cannot open CSV: $!";
<$fh>; # Skip header

my $sth = $dbh->prepare("INSERT INTO taxonomy (iterm, domain, subject, facet, lword) VALUES (?, ?, ?, ?, ?)");

while (<$fh>) {
    chomp;
    my ($iterm, $facet_category, $facet, $domain, $subject, $lword) = split /,/;
    $sth->execute($iterm, $domain, $subject, $facet, $lword);
}

close $fh;
$dbh->disconnect;

print "Taxonomy loaded successfully!\n";
