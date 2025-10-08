#!/usr/bin/perl
use lib "/opt/eprints3/perl_lib";
use strict;
use warnings;
use EPrints;

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

    my $note = $eprint->get_value("note");
    return unless defined $note;   # skip if no note at all

    if ($note =~ /Unmapped bibliographic data:\s*C7\s*-\s*(\d+)\s*\[EPrints field already has value set\]/) {
        $note =~ s/Unmapped bibliographic data:\s*C7\s*-\s*\d+\s*\[EPrints field already has value set\]\s*\n?//;

        $note =~ s/^\s+|\s+$//g;

        if ($note eq '') {
            $eprint->set_value("note", undef);
        } else {
            $eprint->set_value("note", $note);
        }

        $eprint->commit;

        print "Cleaned C7 line from note for eprint ID ", $eprint->id, "\n";
    }
});
