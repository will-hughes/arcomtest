#!/usr/bin/perl

use lib "/opt/eprints3/perl_lib";
use EPrints;
use Text::CSV;

print "Starting taxonomy indexing with common terms...\n";

my $repo = EPrints->new->repository( 'arcomt' );

# Load taxonomy from common terms CSV
print "Loading taxonomy...\n";
my $taxonomy_data = load_taxonomy( '/opt/eprints3/archives/arcomt/taxonomy_common_test.csv' );
my ($index_terms, $facets, $domains, $subjects) = @$taxonomy_data;

print "Taxonomy loaded: " . scalar(keys %$index_terms) . " lookup terms\n";

# Get all eprint IDs first to avoid cursor issues
my $eprint_ids = $repo->dataset( 'eprint' )->search()->ids();
my $total = scalar(@$eprint_ids);
print "Found $total eprints to index\n";

# Process in batches
my $batch_size = 50;
my $updated_count = 0;

for(my $i = 0; $i < $total; $i += $batch_size) {
    my @batch_ids = @$eprint_ids[$i .. ($i + $batch_size - 1)];
    $updated_count += process_batch(\@batch_ids, $index_terms, $facets, $domains, $subjects, $i + scalar(@batch_ids), $total);
}

print "Taxonomy indexing complete. Updated $updated_count eprints.\n";

sub load_taxonomy {
    my ($csv_file) = @_;
    my (%index_terms, %facets, %domains, %subjects);
    
    my $csv = Text::CSV->new({ binary => 1 });
    open my $fh, "<:encoding(utf8)", $csv_file or die "Cannot open $csv_file: $!";
    
    my $header = $csv->getline($fh);
    
    while( my $row = $csv->getline($fh) ) {
        my ($index_term, $facet_category, $facet, $primary_domain, $subject, $lookup_term) = @$row;
        
        my $facet_id = "$facet_category:$facet";
        my $index_id = $index_term;
        
        push @{$index_terms{$lookup_term}}, $index_id;
        push @{$facets{$lookup_term}}, $facet_id;
        push @{$domains{$lookup_term}}, $primary_domain;
        push @{$subjects{$lookup_term}}, $subject;
    }
    
    close $fh;
    return [\%index_terms, \%facets, \%domains, \%subjects];
}

sub process_batch {
    my ($batch_ids, $index_terms, $facets, $domains, $subjects, $current, $total) = @_;
    
    print "Processing batch ($current/$total)...\n";
    
    my $batch_updated = 0;
    
    foreach my $eprint_id (@$batch_ids) {
        next unless $eprint_id;
        
        my $eprint = $repo->dataset( 'eprint' )->dataobj( $eprint_id );
        next unless $eprint;
        
        my %found_index_terms;
        my %found_facets;
        my %found_domains;
        my %found_subjects;
        
        my $text = lc( join( ' ',
            $eprint->value('title') || '',
            $eprint->value('abstract') || '',
            join( ' ', @{$eprint->value('keywords') || []} )
        ));
        
        # Simple text matching
        foreach my $lookup_term (keys %$index_terms) {
            if( index($text, lc($lookup_term)) >= 0 ) {
                foreach my $term (@{$index_terms->{$lookup_term}}) {
                    $found_index_terms{$term} = 1;
                }
                foreach my $facet (@{$facets->{$lookup_term}}) {
                    $found_facets{$facet} = 1;
                }
                foreach my $domain (@{$domains->{$lookup_term}}) {
                    $found_domains{$domain} = 1;
                }
                foreach my $subject (@{$subjects->{$lookup_term}}) {
                    $found_subjects{$subject} = 1;
                }
            }
        }
        
        # REPLACE existing taxonomy fields with taxonomy terms
        if( keys %found_index_terms ) {
            $eprint->set_value( 'taxonomy_terms', [keys %found_index_terms] );
            $eprint->set_value( 'taxonomy_facets', [keys %found_facets] );
            $eprint->set_value( 'taxonomy_domain', [keys %found_domains] );
            $eprint->set_value( 'taxonomy_subject', [keys %found_subjects] );
            $eprint->commit();
            print "  EPrint $eprint_id: Replaced with " . scalar(keys %found_index_terms) . " taxonomy terms\n";
            $batch_updated++;
        } else {
            # Clear taxonomy fields if no taxonomy terms found
            $eprint->set_value( 'taxonomy_terms', [] );
            $eprint->set_value( 'taxonomy_facets', [] );
            $eprint->set_value( 'taxonomy_domain', [] );
            $eprint->set_value( 'taxonomy_subject', [] );
            $eprint->commit();
        }
    }
    
    print "  Batch complete ($batch_updated updated)\n";
    return $batch_updated;
}
