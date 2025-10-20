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

# Update get_data_row again:
sub get_data_row {
    my ($self, $dataobj) = @_;
    
    my $type = $self->get_eprint_type($dataobj);
    
    return (
        '',
        $type,
        $self->get_authors($dataobj),
        $dataobj->get_value('date') ? substr($dataobj->get_value('date'), 0, 4) : "",
        $self->clean_field($dataobj->get_value('title')),
        $self->get_keywords($dataobj),  # Real keywords
        $self->clean_field($dataobj->get_value('abstract')),  # Real abstract
        '',
        '',
        '', '', '', '',
        '0', '1', '',
        '', '', '',
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
