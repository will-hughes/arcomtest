#!/usr/bin/perl

use strict;
use warnings;
use lib "/opt/eprints3/perl_lib";
use EPrints;

my $repoid = shift @ARGV || "arcomt";   # archive ID
my $session = EPrints::Session->new(1, $repoid, undef)
  or die "Failed to create session for $repoid\n";

my $db = $session->get_database;

# Just check a few rows
my $sth = $db->prepare("SELECT id, iterm, facet, subject, domain FROM taxonomy LIMIT 10");
$sth->execute;

while (my $row = $sth->fetchrow_hashref) {
    print join(" | ", $row->{id}, $row->{iterm}, $row->{facet}, $row->{subject}, $row->{domain}), "\n";
}

$sth->finish;
$session->terminate;
