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
    
    # For the first record, include headers
    if (!$self->{_headers_written}) {
        $self->{_headers_written} = 1;
        
        # Write headers
        $csv->combine($self->get_headers());
        my $headers = $csv->string();
        
        # Write first data row
        $csv->combine($self->get_data_row($dataobj));
        my $data = $csv->string();
        
        return $headers . $data;
    }
    
    # For subsequent records, just data
    $csv->combine($self->get_data_row($dataobj));
    return $csv->string();
}

# Add back your get_headers method
sub get_headers {
    return qw(
        absID absType absAuthor absYear absTitle absKeywords absAbstract
        absISBN absJournal absConfDesc absConfEds absThDept absThPub
        absThRev absThLive absThEmail absVolume absIssue absPages
        absURL absFormatted
    );
}

# Simplified get_data_row for testing
sub get_data_row {
    my ($self, $dataobj) = @_;
    
    return (
        '',  # absID
        'Journal Article',  # absType
        'Test Author',  # absAuthor  
        '2024',  # absYear
        $dataobj->get_value('title') || 'No Title',  # absTitle
        'test;keywords',  # absKeywords
        'Test abstract',  # absAbstract
        '',  # absISBN
        'Test Journal',  # absJournal
        '', '', '', '',  # conf fields + dept
        '0', '1', '',  # thesis fields
        '', '', '',  # volume, issue, pages
        'http://test.com',  # absURL
        'NULL'  # absFormatted
    );
}

1;
