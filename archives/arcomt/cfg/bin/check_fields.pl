#!/usr/bin/perl

use lib "/opt/eprints3/perl_lib";
use EPrints;

my $repo = EPrints->new->repository( 'arcomt' );
my $eprint = $repo->dataset( 'eprint' )->dataobj( 1 );  # Check first eprint

print "Checking field existence:\n";
foreach my $field (qw/taxonomy_terms taxonomy_domain taxonomy_subject taxonomy_facets/) {
    my $field_obj = $repo->dataset( 'eprint' )->field( $field );
    if ($field_obj) {
        print "  $field: EXISTS\n";
        print "    Type: " . $field_obj->get_type . "\n";
    } else {
        print "  $field: MISSING\n";
    }
}

if ($eprint) {
    print "\nSample eprint #1 field values:\n";
    foreach my $field (qw/taxonomy_terms taxonomy_domain taxonomy_subject taxonomy_facets/) {
        my $value = $eprint->value( $field );
        print "  $field: " . (defined $value ? join(', ', @$value) : 'NOT SET') . "\n";
    }
}
