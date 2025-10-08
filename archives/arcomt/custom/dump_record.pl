#!/usr/bin/perl
use lib "/opt/eprints3/perl_lib";
use strict;
use warnings;
use EPrints;
use Data::Dumper;

my $repoid = shift @ARGV or die "Usage: $0 <repositoryid> [eprintid]\n";
my $target_eprintid = shift @ARGV;

my $repo = EPrints->new->repository( $repoid )
    or die "Repository '$repoid' not found.\n";

my $ds = $repo->dataset("archive")
    or die "Dataset 'archive' not found.\n";

my $eprint;

if (defined $target_eprintid) {
    $eprint = $ds->dataobj($target_eprintid);
    die "EPrint ID $target_eprintid not found.\n" unless defined $eprint;
    print "Found eprint ID: " . $eprint->id . "\n";
} else {
    my $list = $ds->search;
    $eprint = $list->item(0);
    die "No records found in archive dataset.\n" unless defined $eprint;
    print "Found first eprint ID: " . $eprint->id . "\n";
}

# Dump its field values
my $values = {};
foreach my $field ($eprint->dataset->fields) {
    $values->{$field->name} = $eprint->get_value($field->name);
}

print Dumper($values);
