package EPrints::Plugin::Export::arcomCSV;

@ISA = ('EPrints::Plugin::Export');

use strict;

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
    
    # Just return simple test data
    return "absID,absType,absAuthor\n,Journal Article,Test Author\n";
}

1;
