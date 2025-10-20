package EPrints::Plugin::Export::arcomCSV;

@ISA = ('EPrints::Plugin::Export');

use Unicode::Normalize;
use Text::CSV_XS;
use strict;

sub new {
    my ($class, %opts) = @_;
    my $self = $class->SUPER::new(%opts);

    $self->{name} = 'arcomCSV';
    $self->{accept} = [ 'dataobj/eprint', 'list/eprint' ];
    $self->{visible} = 'all';
    $self->{suffix} = '.csv';
    $self->{mimetype} = 'text/csv; charset=utf-8';
    $self->{disposition} = 'attachment';

    return $self;
}

sub output_file_name {
    my ($plugin, $list) = @_;
    return "arcom.csv";
}

sub output_dataobj {
    my ($self, $dataobj) = @_;
    
    # Debug: log that we're being called
    warn "output_dataobj called for eprint ID: " . $dataobj->get_id;
    
    my $result = $self->output_headers() . $self->output_data_row($dataobj);
    
    # Debug: log the result size
    warn "output_dataobj returning " . length($result) . " bytes";
    
    return $result;
}

sub output_headers {
    my ($self) = @_;
    
    my @headers = $self->get_headers();
    
    # Debug: log headers
    warn "Headers: " . join(", ", @headers);
    
    my $csv = Text::CSV_XS->new({ 
        binary => 1,
        eol => "\n",
    });
    
    if ($csv->combine(@headers)) {
        my $header_row = $csv->string();
        warn "Header row: $header_row";
        return $header_row;
    } else {
        warn "Failed to combine headers: " . $csv->error_diag();
        return "";
    }
}

sub output_list
{
    my( $self, %opts ) = @_;

    my $list = $opts{list};
    
    # Debug: log that we're being called
    warn "output_list called for list with " . $list->count . " items";
    
    my @rows;
    my $csv = Text::CSV_XS->new({ 
        binary => 1,
        eol => "\n",
    });

    # Write headers
    my @headers = $self->get_headers();
    if ($csv->combine(@headers)) {
        push @rows, $csv->string();
        warn "Headers written: " . $csv->string();
    } else {
        warn "Failed to combine headers: " . $csv->error_diag();
    }

    # Write each data row
    $list->map(sub {
        my( $session, $dataset, $dataobj ) = @_;
        
        warn "Processing eprint: " . $dataobj->get_id;
        
        my @row = $self->get_data_row($dataobj);
        if ($csv->combine(@row)) {
            push @rows, $csv->string();
            warn "Row written for eprint " . $dataobj->get_id;
        } else {
            warn "Failed to combine row for eprint " . $dataobj->get_id . ": " . $csv->error_diag();
        }
    });

    my $result = join("", @rows);
    warn "output_list returning " . length($result) . " bytes";
    
    return $result;
}

sub get_headers
{
    my( $self ) = @_;
    
    return qw(
        absID
        absType
        absAuthor
        absYear
        absTitle
        absKeywords
        absAbstract
        absISBN
        absJournal
        absConfDesc
        absConfEds
        absThDept
        absThPub
        absThRev
        absThLive
        absThEmail
        absVolume
        absIssue
        absPages
        absURL
        absFormatted
    );
}

sub get_data_row
{
    my( $self, $dataobj ) = @_;
    
    my $type = $self->get_eprint_type($dataobj);
    my $is_thesis = ($type eq 'Thesis');
    my $is_journal = ($type eq 'Journal Article');
    
    my @row;
    
    # absID - always empty
    push @row, "";
    
    # absType - only 'Journal Article' or 'Thesis'
    push @row, $type;
    
    # absAuthor - formatted author names
    push @row, $self->get_authors($dataobj);
    
    # absYear - publication year
    push @row, $dataobj->get_value('date') ? substr($dataobj->get_value('date'), 0, 4) : "";
    
    # absTitle
    push @row, $self->clean_field($dataobj->get_value('title'));
    
    # absKeywords - from keywords field, not subjects
    push @row, $self->get_keywords($dataobj);
    
    # absAbstract
    push @row, $self->clean_field($dataobj->get_value('abstract'));
    
    # absISBN - ISSN for journal articles, blank for thesis
    push @row, $is_journal ? $dataobj->get_value('issn') || "" : "";
    
    # absJournal - for journal articles
    push @row, $is_journal ? $self->get_journal($dataobj) : "";
    
    # absConfDesc - conference description (blank for thesis/journal)
    push @row, "";
    
    # absConfEds - conference editors (blank for thesis/journal)
    push @row, "";
    
    # absThDept - always blank
    push @row, "";
    
    # absThPub - thesis publication status
    push @row, $is_thesis ? $self->get_thesis_status($dataobj) : "";
    
    # absThRev - ALWAYS 0 (crazy, but that's what they want!)
    push @row, "0";
    
    # absThLive - ALWAYS 1 (crazy, but that's what they want!)
    push @row, "1";
    
    # absThEmail - always blank
    push @row, "";
    
    # absVolume
    push @row, $dataobj->get_value('volume') || "";
    
    # absIssue
    push @row, $dataobj->get_value('number') || "";
    
    # absPages
    push @row, $dataobj->get_value('pagerange') || "";
    
    # absURL
    push @row, $self->get_url($dataobj);
    
    # absFormatted - always NULL
    push @row, "NULL";
    
    return @row;
}

sub get_eprint_type
{
    my( $self, $dataobj ) = @_;
    
    my $type = $dataobj->get_value('type');
    
    # Only two types allowed
    if ($type eq 'thesis') {
        return 'Thesis';
    }
    elsif ($type eq 'article') {
        return 'Journal Article';
    }
    else {
        # Default to Journal Article for non-thesis types? Or handle error?
        return 'Journal Article';
    }
}

sub get_authors
{
    my( $self, $dataobj ) = @_;
    
    my @creators = @{$dataobj->get_value('creators') || []};
    my @author_names;
    
    foreach my $creator (@creators) {
        my $name = $creator->{family} || '';
        if ($creator->{given}) {
            $name .= ", " . $creator->{given} if $name;
        }
        push @author_names, $name if $name;
    }
    
    return join('; ', @author_names);
}

sub get_keywords
{
    my( $self, $dataobj ) = @_;
    
    # Use the actual keywords field, not subjects
    my $keywords = $dataobj->get_value('keywords');
    if (defined $keywords && ref($keywords) eq 'ARRAY') {
        return join('; ', @$keywords);
    }
    return "";  # Return empty string for undefined or non-array keywords
}

sub get_journal
{
    my( $self, $dataobj ) = @_;
    
    return $dataobj->get_value('publication') || "";
}

sub get_thesis_status
{
    my( $self, $dataobj ) = @_;
    
    my $thesis_type = $dataobj->get_value('thesis_type') || 'PhD';
    return "Unpublished " . $thesis_type . " thesis";
}

sub get_url
{
    my( $self, $dataobj ) = @_;
    
    my $url = $dataobj->get_value('official_url') ||
              $dataobj->get_value('id_number') ||
              $self->{session}->get_repository->get_conf( "base_url" ) . "/id/eprint/" . $dataobj->get_id;
    
    return $url;
}

sub clean_field
{
    my( $self, $value ) = @_;
    
    return "" unless defined $value;
    
    # Remove extra whitespace and normalize
    $value =~ s/\s+/ /g;
    $value =~ s/^\s+|\s+$//g;
    
    return $value;
}

# For multiple records export
sub output_list
{
    my( $self, %opts ) = @_;

    my $r = [];
    
    my $csv = Text::CSV_XS->new({ 
        binary => 1,
        eol => "\n",
        quote_space => 0,
    });

    # Write headers
    $csv->combine($self->get_headers());
    push @$r, $csv->string();

    # Write each data row
    my $list = $opts{list};
    $list->map(sub {
        my( $session, $dataset, $dataobj ) = @_;
        
        my @row = $self->get_data_row($dataobj);
        $csv->combine(@row);
        push @$r, $csv->string();
    });

    return join("\n", @$r);
}

1;
