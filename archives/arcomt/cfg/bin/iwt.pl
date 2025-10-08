#!/usr/bin/perl

use lib "/opt/eprints3/perl_lib";
use EPrints;
use Text::CSV;

my $repo = EPrints->new->repository( 'arcomt' );

# Load simplified taxonomy
my $taxonomy = load_taxonomy( '/opt/eprints3/archives/arcomt/taxonomy_common_test.csv' );

my $eprint_ids = $repo->dataset( 'eprint' )->search()->ids();
my $total = scalar(@$eprint_ids);
print "Processing $total eprints\n";

my $batch_size = 50;
my $updated_count = 0;

for(my $i = 0; $i < $total; $i += $batch_size) {
    my @batch_ids = @$eprint_ids[$i .. ($i + $batch_size - 1)];
    $updated_count += process_batch(\@batch_ids, $taxonomy, $i + scalar(@batch_ids), $total);
}

print "Indexing complete. Updated $updated_count eprints.\n";

sub load_taxonomy {
    my ($csv_file) = @_;
    my %taxonomy;
    
    my $csv = Text::CSV->new({ binary => 1 });
    open my $fh, "<:encoding(utf8)", $csv_file or die "Cannot open $csv_file: $!";
    
    $csv->getline($fh); # skip header
    
    while( my $row = $csv->getline($fh) ) {
        my ($index_term, $facet, $primary_domain, $subject, $lookup_term) = @$row;
        
        # Store all variants that map to this canonical term
        $taxonomy{$lookup_term} = {
            domain => $primary_domain,
            subject => $subject, 
            facet => $facet,
            index_term => $index_term
        };
    }
    
    close $fh;
    return \%taxonomy;
}

sub process_batch {
    my ($batch_ids, $taxonomy, $current, $total) = @_;
    
    print "Processing batch ($current/$total)...\n";
    my $batch_updated = 0;
    
    foreach my $eprint_id (@$batch_ids) {
        next unless $eprint_id;
        
        my $eprint = $repo->dataset( 'eprint' )->dataobj( $eprint_id );
        next unless $eprint;
        
        my %found_domains;
        my %found_subjects;
        my %found_facets;
        my %found_terms;
        
        my $text = lc( join( ' ',
            $eprint->value('title') || '',
            $eprint->value('abstract') || '',
            join( ' ', @{$eprint->value('keywords') || []} )
        ));

                # DEBUG: Check first eprint's content and matching
        if ($eprint_id == 1) {
            print "\n=== DEBUG EPrint 1 ===\n";
            print "Title: " . ($eprint->value('title') || 'NO TITLE') . "\n";
            print "Text sample (first 300 chars): " . substr($text, 0, 300) . "\n";
            print "Looking for matches...\n";
            
            my $match_count = 0;
            foreach my $lookup_term (keys %$taxonomy) {
                if( index($text, lc($lookup_term)) >= 0 ) {
                    print "  MATCH: '$lookup_term' found in text\n";
                    my $data = $taxonomy->{$lookup_term};
                    $found_domains{$data->{domain}} = 1 if $data->{domain};
                    $found_subjects{$data->{subject}} = 1 if $data->{subject};
                    $found_facets{$data->{facet}} = 1 if $data->{facet};
                    $found_terms{$data->{index_term}} = 1 if $data->{index_term};
                    $match_count++;
                    last if $match_count >= 5; # Show first 5 matches
                }
            }
            print "Total matches found for eprint 1: $match_count\n";
        }
        
        # Match all lookup terms (synonyms) in text
        foreach my $lookup_term (keys %$taxonomy) {
            if( index($text, lc($lookup_term)) >= 0 ) {
                my $data = $taxonomy->{$lookup_term};
                $found_domains{$data->{domain}} = 1 if $data->{domain};
                $found_subjects{$data->{subject}} = 1 if $data->{subject};
                $found_facets{$data->{facet}} = 1 if $data->{facet};
                $found_terms{$data->{index_term}} = 1 if $data->{index_term};
            }
        }
        
        # Update with all matched taxonomy contexts
        $eprint->set_value( 'taxonomy_domain', [keys %found_domains] );
        $eprint->set_value( 'taxonomy_subject', [keys %found_subjects] );
        $eprint->set_value( 'taxonomy_facets', [keys %found_facets] );
        $eprint->set_value( 'taxonomy_terms', [keys %found_terms] );
        $eprint->commit();
        
        $batch_updated++ if keys %found_terms;
    }
    
    return $batch_updated;
}
