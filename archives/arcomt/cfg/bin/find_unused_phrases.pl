#!/usr/bin/perl

use strict;
use warnings;
use lib "/opt/eprints3/perl_lib";
use EPrints;

my $repo = EPrints->new->repository( 'arcomt' ) or die "Could not load repository";

# Load all phrases
my $phrases = $repo->get_phrases();

# Common phrase patterns to check for removal
my @patterns_to_check = (
    'viewname_eprint_facet_',  # All the facet browse views
    'xmlui_eprint_fieldname_',
    'xmlui_eprint_fieldhelp_',
    'xmlui_eprint_fieldopt_',
    'eprint_fieldname_',
    'eprint_fieldhelp_',
    # Add your compound field names here
    'facet_iterm',
    'facet_domain', 
    'domain_subject',
    'subject_iterm',
    'taxonomy_path',
);

print "Checking for potentially unused phrases...\n\n";

foreach my $phrase_id (keys %$phrases) {
    foreach my $pattern (@patterns_to_check) {
        if ($phrase_id =~ /\Q$pattern\E/) {
            print "POTENTIALLY UNUSED: $phrase_id\n";
            last;
        }
    }
}

print "\nDone. Review these phrases before deleting.\n";
