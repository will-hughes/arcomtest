=head1 NAME

EPrints::Plugin::Export::MyPlugins::arcomCSV

=head1 DESCRIPTION

Custom CSV export plugin for specific requirements with fixed column headers.

=cut

package EPrints::Plugin::Export::MyPlugins::arcomCSV;

use Unicode::Normalize;
use Text::CSV_XS;
use strict;

our @ISA = qw( EPrints::Plugin::Export );

sub new
{
    my( $class, %opts ) = @_;

    my $self = $class->SUPER::new( %opts );

    $self->{name} = "Custom CSV";
    $self->{visible} = "all";
    $self->{accept} = [ 'dataobj/eprint' ];
    $self->{advertise} = 1;
    $self->{suffix} = ".csv";
    $self->{mimetype} = "text/csv; charset=utf-8";

    return $self;
}

sub output_dataobj
{
    my( $self, $dataobj ) = @_;

    my $csv = Text::CSV_XS->new({ 
        binary => 1,
        eol => "\n",
        quote_space => 0,
    });

    # For single record output, we need to include headers
    my $output = "";
    
    # Write headers
    $csv->combine($self->get_headers());
    $output .= $csv->string() . "\n";
    
    # Write data
    my @row = $self->get_data_row($dataobj);
    $csv->combine(@row);
    $output .= $csv->string();

    return $output;
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
    my @keywords = @{$dataobj->get_value('keywords') || []};
    return join('; ', @keywords);
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
    $value = ~ s/\s+/ /g;
    $value = ~ s/^\s+|\s+$/ /g;
    
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
