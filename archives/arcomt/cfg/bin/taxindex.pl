#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use lib "/opt/eprints3/perl_lib";
use EPrints;

# Command line options
my ($archive_id, $eprint_ids_file, $since_date, $help, $verbose);
GetOptions(
    'archive=s'      => \$archive_id,
    'eprints-file=s' => \$eprint_ids_file, 
    'since-date=s'   => \$since_date,
    'verbose'        => \$verbose,
    'help'           => \$help
);

# Help and usage
if ($help || !$archive_id) {
    print <<"USAGE";
Usage: $0 --archive <archive_id> [options]

Options:
    --archive <id>        archive ID (required)
    --eprints-file <file> File containing eprint IDs to process
    --since-date <date>   Process eprints modified since date (YYYY-MM-DD)
    --verbose             Show detailed term matching output
    --help                Show this help message

Examples:
    $0 --archive arcom                    # Process all eprints
    $0 --archive arcom --verbose          # Verbose output
    $0 --archive arcom --since-date 2024-01-01  # Incremental update
    $0 --archive arcomt                 # Process test repository

USAGE
    exit;
}

my $archive = EPrints->new->repository($archive_id) or die "Could not load archive $archive_id";
my $dbh = $archive->get_database->{dbh};

print "Starting taxonomy indexing for archive: $archive_id\n";

# Get all lookup terms with all fields
my $lookup_terms = $dbh->selectall_hashref(
    "SELECT lword, iterm, domain, subject, facet FROM taxonomy", 
    "lword"
);

# Get eprint IDs based on options
my $eprint_ids = get_eprint_ids($archive, $eprint_ids_file, $since_date);
my $total = scalar(@$eprint_ids);
print "Found $total eprints to index\n";

my $batch_size = 100;
my $updated_count = 0;

for (my $i = 0; $i < $total; $i += $batch_size) {
    my @batch_ids = @$eprint_ids[$i .. ($i + $batch_size - 1)];
    $updated_count += process_batch(\@batch_ids, $lookup_terms, $i + 1, $total, $verbose);
}

print "Taxonomy indexing complete. Updated $updated_count eprints.\n";

sub get_eprint_ids {
    my ($archive, $eprint_ids_file, $since_date) = @_;
    
    if ($eprint_ids_file) {
        open my $fh, '<', $eprint_ids_file or die "Cannot open $eprint_ids_file: $!";
        chomp(my @ids = <$fh>);
        close $fh;
        return \@ids;
    }
    elsif ($since_date) {
        return $archive->dataset('eprint')->search(
            filters => [
                { meta_fields => ['lastmod'], value => $since_date, match => 'gt' }
            ]
        )->ids;
    }
    else {
        return $archive->dataset('eprint')->search()->ids();
    }
}

sub process_batch {
    my ($batch_ids, $lookup_terms, $current, $total, $verbose) = @_;
    
    my $batch_end = $current + scalar(@$batch_ids) - 1;
    print "Processing records $current to $batch_end of $total\n";
    
    my $batch_updated = 0;
    
    foreach my $eprint_id (@$batch_ids) {
        next unless $eprint_id;
        
        # Simple progress indicator
        print "  Processing record: $eprint_id\r";
        
        my $eprint = $archive->dataset('eprint')->dataobj($eprint_id);
        next unless $eprint;
        
        my %found_iterms;
        my %found_domains;
        my %found_subjects; 
        my %found_facets;
        
        my $text = lc(join(' ', 
            $eprint->value('title') || '',
            $eprint->value('abstract') || '',
            $eprint->value('keywords') || '',
        ));
        
        # Efficient hash lookup with word boundaries
        foreach my $lword (keys %$lookup_terms) {
            if( $text =~ /\b\Q$lword\E\b/i ) {
                $found_iterms{$lookup_terms->{$lword}->{iterm}} = 1;
                $found_domains{$lookup_terms->{$lword}->{domain}} = 1;
                $found_subjects{$lookup_terms->{$lword}->{subject}} = 1;
                $found_facets{$lookup_terms->{$lword}->{facet}} = 1;
            }
        }
        
        if (keys %found_iterms) {
            # Calculate descriptive scope before commit
            my $descriptive_scope = update_descriptive_scope($eprint, \%found_facets);
            
            # Verbose debug output
            if ($verbose) {
                print "\n  EPrint $eprint_id found:\n";
                print "    Terms: " . join(', ', keys %found_iterms) . "\n";
                print "    Domains: " . join(', ', keys %found_domains) . "\n";
                print "    Subjects: " . join(', ', keys %found_subjects) . "\n";
                print "    Facets: " . join(', ', keys %found_facets) . "\n";
                print "    Descriptive Scope: $descriptive_scope\n";
            }
            
            $eprint->set_value('iterm', [keys %found_iterms]);
            $eprint->set_value('domain', [keys %found_domains]);
            $eprint->set_value('subject', [keys %found_subjects]);
            $eprint->set_value('facet', [keys %found_facets]);
            $eprint->set_value('descriptive_scope', $descriptive_scope);
            
            $eprint->commit();
            $batch_updated++;
        } else {
            $eprint->set_value('iterm', []);
            $eprint->set_value('domain', []);
            $eprint->set_value('subject', []);
            $eprint->set_value('facet', []);
            $eprint->set_value('descriptive_scope', "0");
            $eprint->commit();
        }
    }
    
    print "\n  Batch complete ($batch_updated updated)\n";
    return $batch_updated;
}

sub update_descriptive_scope {
    my ( $eprint, $found_facets_ref ) = @_;
    
    my %facet_letters;
    
    # Map facets to their letters
    foreach my $facet (keys %$found_facets_ref) {
        if ($facet =~ /phenomenon_/) {
            $facet_letters{P} = 1;
        }
        elsif ($facet eq 'concept') {
            $facet_letters{C} = 1;
        }
        elsif ($facet eq 'theoretical_framing') {
            $facet_letters{T} = 1;
        }
        elsif ($facet eq 'empirical_technique') {
            $facet_letters{E} = 1;
        }
        elsif ($facet eq 'analytical_technique') {
            $facet_letters{A} = 1;
        }
    }
    
    my $scope_count = scalar(keys %facet_letters);
    # Manual ordering instead of sort
    my $facet_code = '';
    $facet_code .= 'P' if exists $facet_letters{P};
    $facet_code .= 'C' if exists $facet_letters{C};
    $facet_code .= 'T' if exists $facet_letters{T};
    $facet_code .= 'E' if exists $facet_letters{E};
    $facet_code .= 'A' if exists $facet_letters{A};
    
    return "$scope_count $facet_code";
}
