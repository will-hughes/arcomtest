#!/usr/bin/perl

use strict;
use warnings;
use lib "/opt/eprints3/perl_lib";
use EPrints;

my $repo = EPrints->new->repository( 'arcomt' ) or die "Could not load repository";

# Get the phraseids by loading the phrase files directly
my $phraseids = {};

# Load phrases from all phrase files
my @phrase_files = (
    '/opt/eprints3/archives/arcomt/cfg/lang/en/phrases/core.xml',
    '/opt/eprints3/archives/arcomt/cfg/lang/en/phrases/local.xml', 
    '/opt/eprints3/archives/arcomt/cfg/lang/en/phrases/zz_local.xml',
    # Add other phrase files as needed
);

foreach my $file (@phrase_files) {
    next unless -f $file;
    open my $fh, '<', $file or next;
    while (my $line = <$fh>) {
        if ($line =~ /<epp:phrase\s+id="([^"]+)"/) {
            $phraseids->{$1} = $file;
        }
    }
    close $fh;
}

print "Found " . scalar(keys %$phraseids) . " phrases in configuration\n\n";

# Common phrase patterns to check for removal (your compound fields)
my @patterns_to_check = (
    'facet_iterm',
    'facet_domain', 
    'domain_subject',
    'subject_iterm', 
    'taxonomy_path',
    'viewname_eprint_facet_',  # All the facet browse views
);

print "Checking for potentially unused phrases...\n\n";

foreach my $phrase_id (sort keys %$phraseids) {
    foreach my $pattern (@patterns_to_check) {
        if ($phrase_id =~ /\Q$pattern\E/) {
            print "POTENTIALLY UNUSED: $phrase_id (from $phraseids->{$phrase_id})\n";
            last;
        }
    }
}

print "\nReview these phrases before deleting from your phrase files.\n";
