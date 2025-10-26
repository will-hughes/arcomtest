my $id = 147;  # replace with a known eprint ID
my $e = $repo->dataset("eprint")->dataobj($id);
if( $e )
{
    my $vals = $e->value("facet_iterm") || [];
    print "EPrint $id facet_iterm: ", join(", ", @$vals), "\n";
}
else
{
    print "No such eprint $id\n";
}
