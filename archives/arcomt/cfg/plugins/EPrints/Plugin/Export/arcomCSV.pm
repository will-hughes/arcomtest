sub get_data_row {
    my ($self, $dataobj) = @_;
    
    my $type = $self->get_eprint_type($dataobj);
    my $is_thesis = ($type eq 'Thesis');
    my $is_journal = ($type eq 'Journal Article');
    
    return (
        '',  # absID
        $type,  # absType
        $self->get_authors($dataobj),  # absAuthor
        $dataobj->get_value('date') ? substr($dataobj->get_value('date'), 0, 4) : "",  # absYear
        $self->clean_field($dataobj->get_value('title')),  # absTitle
        $self->get_keywords($dataobj),  # absKeywords
        $self->clean_field($dataobj->get_value('abstract')),  # absAbstract
        $is_journal ? $dataobj->get_value('issn') || "" : "",  # absISBN
        $is_journal ? $self->get_journal($dataobj) : "",  # absJournal
        "", "", "", "",  # absConfDesc, absConfEds, absThDept, absThPub
        "0", "1", "",  # absThRev, absThLive, absThEmail
        $dataobj->get_value('volume') || "",  # absVolume
        $dataobj->get_value('number') || "",  # absIssue  
        $dataobj->get_value('pagerange') || "",  # absPages
        $self->get_url($dataobj),  # absURL
        "NULL"  # absFormatted
    );
}

# Add back your helper methods with the defensive get_keywords fix
sub get_eprint_type {
    my( $self, $dataobj ) = @_;
    my $type = $dataobj->get_value('type');
    return 'Thesis' if $type eq 'thesis';
    return 'Journal Article' if $type eq 'article';
    return 'Journal Article'; # default
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

sub get_url {
    my( $self, $dataobj ) = @_;
    return $dataobj->get_value('official_url') ||
           $self->{session}->get_repository->get_conf( "base_url" ) . "/id/eprint/" . $dataobj->get_id;
}

sub clean_field {
    my( $self, $value ) = @_;
    return "" unless defined $value;
    $value =~ s/\s+/ /g;
    $value =~ s/^\s+|\s+$//g;
    return $value;
}
1;
