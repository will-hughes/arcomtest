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

sub get_data_row {
    my ($self, $dataobj) = @_;
    
    return (
        '',
        'Test Type',
        'Test Author',
        '2024',
        $dataobj->get_value('title') || 'No Title',
        'test',
        'test abstract',
        '',
        '',
        '', '', '', '',
        '0', '1', '',
        '', '', '',
        'http://test.com',
        'NULL'
    );
}

1;
