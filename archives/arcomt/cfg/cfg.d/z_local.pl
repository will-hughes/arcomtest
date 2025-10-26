# Optional: explicit taxonomy DB override (set to your real DB credentials).
# This forces the TaxonomyDBHelpers module to use these credentials rather than
# trying to autodiscover them (useful for the test script and if autodiscovery fails).
$c->{taxonomy_db} = {
    dsn  => "DBI:mysql:database=arcomt;host=localhost;mysql_enable_utf8=1",
    user => "eprints",
    pass => "FRGmDrtWuaG93J6M",
};
