#!/usr/bin/perl

use lib "/opt/eprints3/perl_lib";
use EPrints;
use Text::CSV;

print "=== TAXONOMY MATCHING DIAGNOSIS (FIXED) ===\n\n";

my $repo = EPrints->new->repository( 'arcomt' );

# Load taxonomy properly
print "Loading taxonomy...\n";
my $taxonomy_data = load_taxonomy( '/opt/eprints3/archives/arcomt/taxonomy_common_test.csv' );
my ($index_terms, $facets, $domains) = @$taxonomy_data;

print "Taxonomy loaded:\n";
print "  Unique lookup terms: " . scalar(keys %$index_terms) . "\n";
foreach my $term (sort keys %$index_terms) {
    print "    - '$term' -> " . join(", ", @{$index_terms->{$term}}) . "\n";
}
print "\n";

# Get eprint IDs first to avoid cursor issues
my $eprint_ids = $repo->dataset( 'eprint' )->search()->ids();
my $total = scalar(@$eprint_ids);

print "Testing eprints for matches...\n\n";
my $tested = 0;

foreach my $eprint_id (@$eprint_ids) {
    last if $tested >= 10; # Test only first 10
    
    my $eprint = $repo->dataset( 'eprint' )->dataobj( $eprint_id );
    next unless $eprint;
    
    print "EPrint " . $eprint->id . ":\n";
    print "  Title: " . ($eprint->value('title') || 'no title') . "\n";
    
    my $text = lc( join( ' ',
        $eprint->value('title') || '',
        $eprint->value('abstract') || '',
        join( ' ', @{$eprint->value('keywords') || []} )
    ));
    
    my @matches;
    foreach my $lookup_term (keys %$index_terms) {
        if( index($text, lc($lookup_term)) >= 0 ) {
            push @matches, $lookup_term;
        }
    }
    
    if( @matches ) {
        print "  MATCHES FOUND: " . join(", ", @matches) . "\n";
        foreach my $match (@matches) {
            print "    -> Would add: " . join(", ", @{$index_terms->{$match}}) . "\n";
        }
    } else {
        print "  NO MATCHES\n";
    }
    print "  ---\n";
    
    $tested++;
}

print "\n=== DIAGNOSIS COMPLETE ===\n";

sub load_taxonomy {
    my ($csv_file) = @_;
    my (%index_terms, %facets, %domains);
    
    my $csv = Text::CSV->new({ binary => 1 });
    open my $fh, "<:encoding(utf8)", $csv_file or die "Cannot open $csv_file: $!";
    
    my $header = $csv->getline($fh);
    
    while( my $row = $csv->getline($fh) ) {
        my ($index_term, $facet_category, $facet, $primary_domain, $subject, $lookup_term) = @$row;
        
        # Clean up the lookup term
        $lookup_term =~ s/^\s+|\s+$//g;
        
        next unless $lookup_term; # Skip empty lookup terms
        
        my $facet_id = "$facet_category:$facet";
        my $index_id = $index_term;
        
        push @{$index_terms{$lookup_term}}, $index_id;
        push @{$facets{$lookup_term}}, $facet_id;
        push @{$domains{$lookup_term}}, $primary_domain;
    }
    
    close $fh;
    return [\%index_terms, \%facets, \%domains];
}
