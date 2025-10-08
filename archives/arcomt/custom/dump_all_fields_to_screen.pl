#!/usr/bin/perl
use lib "/opt/eprints3/perl_lib";
use strict;
use warnings;
use EPrints;
use Data::Dumper;

my $repoid = shift @ARGV or die "Usage: $0 <repositoryid>\n";

my $repo = EPrints->new->repository( $repoid );
die "Repository '$repoid' not found.\n" unless defined $repo;

my $ds = $repo->dataset("archive");
die "Dataset 'archive' not found.\n" unless defined $ds;

my $list = $ds->search;
print "Found ", $list->count, " items in archive list.\n";

$list->map(sub {
    my (undef, undef, $eprint) = @_;
    return unless defined $eprint;

    my $dataset = $eprint->dataset;
    my @fields = $dataset->fields;

    my %values;
    foreach my $field (@fields) {
        my $fname = $field->name;
        $values{$fname} = $eprint->get_value($fname);
    }

    use Data::Dumper;
    print Dumper(\%values);
    exit 0;  # stop after first item
});
