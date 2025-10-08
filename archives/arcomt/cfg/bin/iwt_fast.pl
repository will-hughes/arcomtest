#!/usr/bin/perl

use lib "/opt/eprints3/perl_lib";
use EPrints;
use Text::CSV;

print "Starting optimized taxonomy indexing...\n";

my $repo = EPrints->new->repository( 'arcomt' );
print "Repository loaded\n";

# Load taxonomy from CSV
print "Loading taxonomy from CSV...\n";
my (%index_terms, %facets, %domains) = load_taxonomy( '/opt/eprints3/archives/arcomt/taxonomy_test.csv' );
print "Taxonomy loaded: " . scalar(keys %index_terms) . " lookup terms\n";

# Pre-compile regex patterns for faster matching
my @lookup_patterns;
foreach my $lookup_term (keys %index_terms) {
    push @lookup_patterns, {
        pattern => qr/\b\Q$lookup_term\E\b/i,  # Word-boundary matching
        term => $lookup_term
    };
}

# Process eprints in smaller batches
my $eprints = $repo->dataset( 'eprint' )->search();
my $total = $eprints->count();
print "Found $total eprints to index\n";

my $count = 0;
my $batch_size = 50;
my @batch;

while( my $eprint = $eprints->item() ) {
    $count++;
    push @batch, $eprint;
    
    if( @batch >= $batch_size || $count == $total ) {
        process_batch(\@batch, \@lookup_patterns, \%index_terms, \%facets, \%domains, $count, $total);
        @batch = ();
    }
}

print "Taxonomy indexing complete.\n";

sub load_taxonomy {
    my ($csv_file) = @_;
    my (%index_terms, %facets, %domains);
    
    my $csv = Text::CSV->new({ binary => 1 });
    open my $fh, "<:encoding(utf8)", $csv_file or die "Cannot open $csv_file: $!";
    
    my $header = $csv->getline($fh);
    
    my $row_count = 0;
    while( my $row = $csv->getline($fh) ) {
        $row_count++;
        my ($index_term, $facet_category, $facet, $primary_domain, $subject, $lookup_term) = @$row;
        
        my $facet_id = "$facet_category:$facet";
        my $domain_id = $primary_domain;
        my $index_id = $index_term;
        
        push @{$index_terms{$lookup_term}}, $index_id;
        push @{$facets{$lookup_term}}, $facet_id;
        push @{$domains{$lookup_term}}, $domain_id;
    }
    
    close $fh;
    print "Loaded $row_count taxonomy rows\n";
    return (\%index_terms, \%facets, \%domains);
}

sub process_batch {
    my ($batch, $patterns, $index_terms, $facets, $domains, $count, $total) = @_;
    
    print "Processing batch (up to eprint $count/$total)...\n";
    
    foreach my $eprint (@$batch) {
        my %found_index_terms;
        my %found_facets;
        
        my $text = lc( join( ' ',
            $eprint->value('title') || '',
            $eprint->value('abstract') || '',
            join( ' ', @{$eprint->value('keywords') || []} )
        ));
        
        # Faster regex matching
        foreach my $pattern_data (@$patterns) {
            if( $text =~ $pattern_data->{pattern} ) {
                my $lookup_term = $pattern_data->{term};
                foreach my $term (@{$index_terms->{$lookup_term}}) {
                    $found_index_terms{$term} = 1;
                }
                foreach my $facet (@{$facets->{$lookup_term}}) {
                    $found_facets{$facet} = 1;
                }
            }
        }
        
        # Update if we found anything
        if( keys %found_index_terms ) {
            $eprint->set_value( 'subjects', [keys %found_index_terms] );
            $eprint->set_value( 'divisions', [keys %found_facets] );
            $eprint->commit();
        }
    }
    
    print "  Batch complete\n";
}
