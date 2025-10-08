#!/usr/bin/perl

use lib "/opt/eprints3/perl_lib";
use EPrints;

my $repo = EPrints->new->repository( 'arcomt' );

print "Checking taxonomy field population...\n";

my $ds = $repo->dataset( 'eprint' );
my $list = $ds->search();
my $total = $list->count;

my ($count_terms, $count_domain, $count_subject, $count_facets) = (0,0,0,0);

foreach my $eprint (@{$list->slice(0, $total-1)}) {
    $count_terms++ if $eprint->is_set("taxonomy_terms") && @{$eprint->value("taxonomy_terms") || []};
    $count_domain++ if $eprint->is_set("taxonomy_domain") && @{$eprint->value("taxonomy_domain") || []};
    $count_subject++ if $eprint->is_set("taxonomy_subject") && @{$eprint->value("taxonomy_subject") || []};
    $count_facets++ if $eprint->is_set("taxonomy_facets") && @{$eprint->value("taxonomy_facets") || []};
}

print "Total eprints: $total\n";
print "Eprints with taxonomy_terms: $count_terms\n";
print "Eprints with taxonomy_domain: $count_domain\n";
print "Eprints with taxonomy_subject: $count_subject\n";
print "Eprints with taxonomy_facets: $count_facets\n";

# Also show some sample values
print "\nSample taxonomy_terms:\n";
my $sample_count = 0;
foreach my $eprint (@{$list->slice(0, 9)}) {
    if ($eprint->is_set("taxonomy_terms")) {
        my @terms = @{$eprint->value("taxonomy_terms")};
        print "  EPrint " . $eprint->id . ": " . join(", ", @terms[0..2]) . "\n";
        last if $sample_count++ >= 4;
    }
}
