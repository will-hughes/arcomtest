#!/usr/bin/perl

use strict;
use warnings;
use DBI;
use lib "/opt/eprints3/perl_lib";
use EPrints;

print "Starting taxonomy indexing...\n";

my $repo = EPrints->new->repository('arcomt');
my $dbh = DBI->connect("DBI:mysql:database=arcomt", "eprints", "FRGmDrtWuaG93J6M") 
    or die "Could not connect to database: $DBI::errstr";

# Get all lookup terms
my $lookup_terms = $dbh->selectall_hashref("SELECT lword, iterm FROM taxonomy", "lword");

# Get all eprint IDs
my $eprint_ids = $repo->dataset('eprint')->search()->ids();
my $total = scalar(@$eprint_ids);
print "Found $total eprints to index\n";

my $batch_size = 100;
my $updated_count = 0;

for (my $i = 0; $i < $total; $i += $batch_size) {
    my @batch_ids = @$eprint_ids[$i .. ($i + $batch_size - 1)];
    $updated_count += process_batch(\@batch_ids, $lookup_terms, $i + scalar(@batch_ids), $total);
}

$dbh->disconnect;
print "Taxonomy indexing complete. Updated $updated_count eprints.\n";

sub process_batch {
    my ($batch_ids, $lookup_terms, $current, $total) = @_;
    
    print "Processing batch ($current/$total)...\n";
    my $batch_updated = 0;
    
    foreach my $eprint_id (@$batch_ids) {
        next unless $eprint_id;
        my $eprint = $repo->dataset('eprint')->dataobj($eprint_id);
        next unless $eprint;
        
        my %found_iterms;
        my $text = lc(join(' ', 
            $eprint->value('title') || '',
            $eprint->value('abstract') || '',
            $eprint->value('keywords') || '',
        ));
        
        # Efficient hash lookup instead of linear search
        foreach my $lword (keys %$lookup_terms) {
            if (index($text, lc($lword)) >= 0) {
                $found_iterms{$lookup_terms->{$lword}->{iterm}} = 1;
            }
        }
        
        if (keys %found_iterms) {
            $eprint->set_value('iterm', [keys %found_iterms]);
            $eprint->commit();
            $batch_updated++;
        } else {
            $eprint->set_value('iterm', []);
            $eprint->commit();
        }
    }
    
    print "  Batch complete ($batch_updated updated)\n";
    return $batch_updated;
}
