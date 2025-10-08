#!/usr/bin/perl

use lib "/opt/eprints3/perl_lib";
use EPrints;
use Text::CSV;

my $repo = EPrints->new->repository( 'arcomt' );

# Load taxonomy from CSV
my (%index_terms, %facets, %domains) = load_taxonomy( '/opt/eprints3/archives/arcomt/taxonomy_test.csv' );

# Index eprints using repurposed subject fields
my $eprints = $repo->dataset( 'eprint' )->search();
while( my $eprint = $eprints->item() )
{
    index_eprint( $eprint, \%index_terms, \%facets, \%domains );
}

sub load_taxonomy {
    my ($csv_file) = @_;
    my (%index_terms, %facets, %domains);
    
    my $csv = Text::CSV->new({ binary => 1 });
    open my $fh, "<:encoding(utf8)", $csv_file or die "Cannot open $csv_file: $!";
    
    my $header = $csv->getline($fh);
    
    while( my $row = $csv->getline($fh) ) {
        my ($index_term, $facet_category, $facet, $primary_domain, $subject, $lookup_term) = @$row;
        
        # Build structured identifiers for each dimension
        my $facet_id = "$facet_category:$facet";
        my $domain_id = $primary_domain;
        my $index_id = $index_term;
        
        # Map lookup terms to their classifications
        push @{$index_terms{$lookup_term}}, $index_id;
        push @{$facets{$lookup_term}}, $facet_id;
        push @{$domains{$lookup_term}}, $domain_id;
    }
    
    close $fh;
    return (\%index_terms, \%facets, \%domains);
}

sub index_eprint {
    my ($eprint, $index_terms, $facets, $domains) = @_;
    
    my %found_index_terms;
    my %found_facets;
    my %found_domains;
    
    my $text = lc( join( ' ',
        $eprint->value('title') || '',
        $eprint->value('abstract') || '',
        join( ' ', @{$eprint->value('keywords') || []} )
    ));
    
    # Find all matching taxonomy terms
    foreach my $lookup_term (keys %$index_terms) {
        if( index($text, lc($lookup_term)) >= 0 ) {
            # Add index terms (to subjects field)
            foreach my $term (@{$index_terms->{$lookup_term}}) {
                $found_index_terms{$term} = 1;
            }
            # Add facets (to divisions field)  
            foreach my $facet (@{$facets->{$lookup_term}}) {
                $found_facets{$facet} = 1;
            }
            # Domains could go to another field if needed
            foreach my $domain (@{$domains->{$lookup_term}}) {
                $found_domains{$domain} = 1;
            }
        }
    }
    
    # Update the repurposed fields
    if( keys %found_index_terms ) {
        $eprint->set_value( 'subjects', [keys %found_index_terms] );
    }
    
    if( keys %found_facets ) {
        $eprint->set_value( 'divisions', [keys %found_facets] );
    }
    
    $eprint->commit();
    
    if( keys %found_index_terms ) {
        print "EPrint " . $eprint->id . ": " . 
              scalar(keys %found_index_terms) . " index terms, " .
              scalar(keys %found_facets) . " facets\n";
    }
}

print "Taxonomy indexing complete.\n";
