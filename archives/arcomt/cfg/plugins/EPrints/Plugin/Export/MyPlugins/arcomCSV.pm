package EPrints::Plugin::Export::MyPlugins::arcomCSV;

@ISA = ('EPrints::Plugin::Export');

use strict;

sub new {
    my ($class, %opts) = @_;
    my $self = $class->SUPER::new(%opts);

    $self->{name} = 'Custom CSV';
    $self->{accept} = [ 'dataobj/eprint', 'list/eprint' ];
    $self->{visible} = 'all';
    $self->{suffix} = '.csv';
    $self->{mimetype} = 'text/csv; charset=utf-8';

    return $self;
}

sub output_file_name {
    my ($plugin, $list) = @_;
    return "arcom.csv";
}

sub output_dataobj {
    my ($self, $dataobj) = @_;
    return "test,data\n";
}

1;
