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
    $self->{mimetype} = 'text/plain; charset=utf-8';
    # NO disposition - let it display in browser

    return $self;
}

sub output_list {
    my ($self, %opts) = @_;

    my $list = $opts{list};
    my @output;
    
    # Create CSV object
    my $csv = Text::CSV_XS->new({ 
        binary => 1,
        eol => "\n",
    });
    
    # Headers
    my @headers = (
        'absID', 'absType', 'absAuthor', 'absYear', 'absTitle', 
        'absKeywords', 'absAbstract', 'absISBN', 'absJournal', 
        'absConfDesc', 'absConfEds', 'absThDept', 'absThPub', 
        'absThRev', 'absThLive', 'absThEmail', 'absVolume', 
        'absIssue', 'absPages', 'absURL', 'absFormatted'
    );
    
    $csv->combine(@headers);
    push @output, $csv->string();
    
    # Just 2 test rows
    my @test_row1 = ('', 'Journal Article', 'Test Author', '2024', 'Test Title', 
                    'test;keywords', 'Test abstract', '', 'Test Journal', 
                    '', '', '', '', '0', '1', '', '1', '1', '1-10', 
                    'http://test.com', 'NULL');
    
    my @test_row2 = ('', 'Thesis', 'Another Author', '2023', 'Thesis Title', 
                    'thesis;keywords', 'Thesis abstract', '', '', 
                    '', '', '', 'Unpublished PhD thesis', '0', '1', '', 
                    '', '', '', 'http://thesis.com', 'NULL');
    
    $csv->combine(@test_row1);
    push @output, $csv->string();
    
    $csv->combine(@test_row2);
    push @output, $csv->string();
    
    return join('', @output);
}

1;
