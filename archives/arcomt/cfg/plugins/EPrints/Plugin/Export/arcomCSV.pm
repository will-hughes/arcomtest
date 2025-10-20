package EPrints::Plugin::Export::arcomCSV;

@ISA = ('EPrints::Plugin::Export');

use strict;
use Text::CSV_XS;

sub new {
    my ($class, %opts) = @_;
    my $self = $class->SUPER::new(%opts);

    $self->{name} = 'arcomCSV';
    $self->{accept} = [ 'dataobj/eprint', 'list/eprint' ];
    $self->{visible} = 'all';
    $self->{suffix} = '.csv';
    $self->{mimetype} = 'text/plain';

    return $self;
}

sub output_dataobj {
    my ($self, $dataobj) = @_;
    
    my $csv = Text::CSV_XS->new({ 
        binary => 1,
        eol => "\n",
    });
    
    if (!$self->{_headers_written}) {
        $self->{_headers_written} = 1;
        $csv->combine($self->get_headers());
        my $headers = $csv->string();
        $csv->combine($self->get_data_row($dataobj));
        my $data = $csv->string();
        return $headers . $data;
    }
    
    $csv->combine($self->get_data_row($dataobj));
    return $csv->string();
}

sub get_headers {
    return qw(
        absID absType absAuthor absYear absTitle absKeywords absAbstract
        absISBN absJournal absConfDesc absConfEds absThDept absThPub
        absThRev absThLive absThEmail absVolume absIssue absPages
        absURL absFormatted
    );
}

sub get_authors {
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

sub get_keywords {
    my( $self, $dataobj ) = @_;
    my $keywords = $dataobj->get_value('keywords');
    if (defined $keywords && ref($keywords) eq 'ARRAY') {
        return join('; ', @$keywords);
    }
    return "";
}

sub get_journal {
    my( $self, $dataobj ) = @_;
    return $dataobj->get_value('publication') || "";
}

sub get_thesis_status {
    my( $self, $dataobj ) = @_;
    my $thesis_type = $dataobj->get_value('thesis_type') || 'PhD';
    return "Unpublished " . $thesis_type . " thesis";
}

# Final get_data_row with thesis logic:
sub get_data_row {
    my ($self, $dataobj) = @_;
    
    my $type = $self->get_eprint_type($dataobj);
    my $is_thesis = ($type eq 'Thesis');
    my $is_journal = ($type eq 'Journal Article');
    
    return (
        '',
        $type,
        $self->get_authors($dataobj),
        $dataobj->get_value('date') ? substr($dataobj->get_value('date'), 0, 4) : "",
        $self->clean_field($dataobj->get_value('title')),
        $self->get_keywords($dataobj),
        $self->clean_field($dataobj->get_value('abstract')),
        $is_journal ? $dataobj->get_value('issn') || "" : "",
        $is_journal ? $self->get_journal($dataobj) : "",
        '', '', '',  # Conference fields remain empty
        $is_thesis ? $self->get_thesis_status($dataobj) : "",  # Thesis status
        '0', '1', '',  # Fixed thesis fields
        $dataobj->get_value('volume') || "",
        $dataobj->get_value('number') || "", 
        $dataobj->get_value('pagerange') || "",
        $self->get_url($dataobj),
        'NULL'
    );
}

sub get_eprint_type {
    my( $self, $dataobj ) = @_;
    my $type = $dataobj->get_value('type');
    return 'Thesis' if $type eq 'thesis';
    return 'Journal Article' if $type eq 'article';
    return 'Journal Article'; # default
}

sub clean_field {
    my( $self, $value ) = @_;
    return "" unless defined $value;
    $value =~ s/\s+/ /g;
    $value =~ s/^\s+|\s+$//g;
    return $value;
}

sub get_url {
    my( $self, $dataobj ) = @_;
    return $dataobj->get_value('official_url') ||
           $self->{session}->get_repository->get_conf( "base_url" ) . "/id/eprint/" . $dataobj->get_id;
}
1;
