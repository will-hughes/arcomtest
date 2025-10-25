#!/usr/bin/env perl
#
# Quick test script to verify TaxonomyDBHelpers and DB access for an archive.
# Usage: perl archives/arcomt/bin/test_taxonomy_db.pl [archive_dir] [sample_facet]
# Example: perl archives/arcomt/bin/test_taxonomy_db.pl /opt/eprints3/archives/arcomt "phenomenon_process"
#
use strict;
use warnings;
use FindBin;
use File::Spec;

my $archdir = shift @ARGV || '/opt/eprints3/archives/arcomt';
my $sample_facet = shift @ARGV || '';

# paths
my $cfg_dir = File::Spec->catdir($archdir, 'cfg', 'cfg.d');
my $db_cfg_file = File::Spec->catfile($cfg_dir, 'database.pl');
my $helper_file = File::Spec->catfile($cfg_dir, 'z_taxonomy_db.pl');

# load database.pl to get $c (it sets $c->{dbname}, etc)
if( -f $db_cfg_file ) {
    {
        package main;
        do $db_cfg_file or warn "Warning: could not load $db_cfg_file: $@ $!" if $@ || $!;
    }
    print "Loaded DB config: $db_cfg_file\n";
} else {
    die "database.pl not found at $db_cfg_file\n";
}

# load the helper
if( -f $helper_file ) {
    do $helper_file or die "Failed to load helper $helper_file: $@ $!";
    print "Loaded taxonomy helper: $helper_file\n";
} else {
    die "taxonomy helper not found at $helper_file\n";
}

# Create a minimal $repo-like object that TaxonomyDBHelpers expects (it calls $repo->get_conf)
{
    package DummyRepo;
    sub new { bless {}, shift }
    sub get_conf {
        # Expect $c from database.pl to be in package main
        return $main::c if defined $main::c;
        return {};
    }
}

my $repo = DummyRepo->new;

# Now call the helper functions (wrapped in eval to catch errors)
eval {
    no strict 'refs';
    die "TaxonomyDBHelpers package not available\n"
        unless defined &{ 'TaxonomyDBHelpers::get_facets' };

    my $facets = TaxonomyDBHelpers::get_facets($repo);
    unless( ref $facets eq 'ARRAY' ) {
        die "get_facets did not return arrayref\n";
    }
    printf "Facets: %d distinct facets returned\n", scalar(@$facets);
    for my $i ( 0 .. ($#$facets < 9 ? $#$facets : 9) ) {
        printf "  %2d: %s\n", $i+1, $facets->[$i];
    }

    if( $sample_facet ) {
        my $iterms = TaxonomyDBHelpers::get_iterms_for_facet($repo, $sample_facet);
        die "get_iterms_for_facet did not return arrayref\n" unless ref $iterms eq 'ARRAY';
        printf "It terms for facet '%s': %d\n", $sample_facet, scalar(@$iterms);
        for my $i ( 0 .. ($#$iterms < 19 ? $#$iterms : 19) ) {
            printf "  %3d: %s\n", $i+1, $iterms->[$i];
        }
    } else {
        print "No sample facet provided. Re-run with a facet to list its iterms.\n";
    }
    1;
} or do {
    my $err = $@ || 'unknown error';
    print "Error calling helper: $err\n";
    exit 2;
};

exit 0;
