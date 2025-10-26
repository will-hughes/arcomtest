package TaxonomyDBHelpers;

use strict;
use warnings;
use DBI;
use Exporter 'import';
our @EXPORT_OK = qw( dbh get_facets get_iterms_for_facet );

our $DBH;

sub _build_conn_info {
    my( $repo ) = @_;
    my $c = $repo->get_conf || $repo->config || {};

    if( $c->{taxonomy_db} && ($c->{taxonomy_db}{dsn} || $c->{taxonomy_db}{user} || defined $c->{taxonomy_db}{pass}) ) {
        return ( $c->{taxonomy_db}{dsn}, $c->{taxonomy_db}{user} // '', $c->{taxonomy_db}{pass} // '' );
    }

    my $dbname = $c->{dbname}  || 'arcom';
    my $host   = $c->{dbhost}  || 'localhost';
    my $port   = $c->{dbport};
    my $sock   = $c->{dbsock};
    my $user   = $c->{dbuser}  || '';
    my $pass   = $c->{dbpass}  || '';

    my $dsn = "DBI:mysql:database=$dbname;host=$host";
    $dsn .= ";port=$port"     if defined $port && length("$port");
    $dsn .= ";mysql_socket=$sock" if defined $sock && length("$sock");

    return ( $dsn, $user, $pass );
}

sub dbh {
    my( $repo ) = @_;
    return $DBH if defined $DBH && $DBH->ping;

    my( $dsn, $user, $pass ) = _build_conn_info($repo);
    my %attr = (
        RaiseError => 0,
        PrintError => 0,
        AutoCommit => 1,
        mysql_enable_utf8 => 1,
    );

    $DBH = DBI->connect( $dsn, $user, $pass, \%attr )
        or die "TaxonomyDBHelpers: cannot connect to DB ($dsn): " . DBI->errstr;

    return $DBH;
}

sub get_facets {
    my( $repo ) = @_;
    my $dbh = dbh($repo);
    my $sql = q{ SELECT DISTINCT facet FROM taxonomy WHERE facet IS NOT NULL AND facet != '' ORDER BY LOWER(facet) };
    my $sth = $dbh->prepare($sql) or return [];
    $sth->execute or return [];
    my @out;
    while( my ($v) = $sth->fetchrow_array ) {
        push @out, $v if defined $v && $v ne '';
    }
    $sth->finish;
    return \@out;
}

sub get_iterms_for_facet {
    my( $repo, $facet ) = @_;
    return [] unless defined $facet && $facet ne '';

    my $dbh = dbh($repo);
    my $sql = q{ SELECT iterm FROM taxonomy WHERE facet = ? AND iterm IS NOT NULL AND iterm != '' ORDER BY LOWER(iterm) };
    my $sth = $dbh->prepare($sql) or return [];
    $sth->execute($facet) or return [];
    my @out;
    while( my ($v) = $sth->fetchrow_array ) {
        push @out, $v if defined $v && $v ne '';
    }
    $sth->finish;
    return \@out;
}

sub get_facet_iterm_pairs {
    my( $repo, $facet ) = @_;
    return [] unless defined $facet && $facet ne '';

    my $dbh = dbh($repo);   # <-- use your own helper here
    my $sql = q{
        SELECT iterm
        FROM taxonomy
        WHERE facet = ?
          AND iterm IS NOT NULL
          AND iterm != ''
        ORDER BY LOWER(iterm)
    };
    my $sth = $dbh->prepare($sql) or return [];
    $sth->execute($facet) or return [];
    my @out;
    while( my ($v) = $sth->fetchrow_array ) {
        push @out, "$facet--$v" if defined $v && $v ne '';
    }
    $sth->finish;
    return \@out;
}

1;
