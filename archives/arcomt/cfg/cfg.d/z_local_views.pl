push @{$c->{browse_views}},

{
    id => "journal_volume",
    menus => [
        {
            id => "publication_menu",
            fields => [ "publication" ],
            hideempty => 1,
        },
        {
            id => "volume_menu", 
            fields => [ "volume" ],
            hideempty => 1,
            group => "publication",
            sort_order => sub {
                my( $repo, $values, $lang ) = @_;
                my @sorted_values = sort { $a <=> $b } @$values;
                return \@sorted_values;
            },
        },
    ],
        
    filters => [
        { meta_fields => [ "type" ], value => "article" },
        { meta_fields => [ "publication" ], value => ".+" },
        { meta_fields => [ "volume" ], value => ".+" },
    ],
    order => "number/title",
    max_items => 10000,
    variation => [ "DEFAULT;numeric" ],
},
{
    id => "doctype",
    menus => [ 
        { 
            fields => [ "type" ], 
        },
        { 
            fields => [ "date" ],
            new_column_at => [1,1,1],
        },
    ],
    order => "creators_name/date",
},

{   id => "iterm",
    allow_null => 0,
    hideempty => 1,
    menus => [
        { 
        fields => [ "iterm" ], 
        new_column_at => [1,1],
        mode => "sections",
        open_first_section => 1,
        group_range_function => "EPrints::Update::Views::cluster_ranges_30",
        grouping_function => "group_by_a_to_z_hideempty",
        }, 
    ],
    order => "creators_name/date", 
},

{   id => "subject",
    allow_null => 0,
    hideempty => 1,
    menus => [
        { 
        fields => [ "subject" ], 
        new_column_at => [1,1],
        mode => "sections",
        open_first_section => 1,
        group_range_function => "EPrints::Update::Views::cluster_ranges_30",
        grouping_function => "group_by_a_to_z_hideempty",
        }, 
    ],
    order => "creators_name/date", 
},

{   id => "domain",
    allow_null => 0,
    hideempty => 1,
    menus => [
        { 
        fields => [ "domain" ], 
        new_column_at => [1,1],
        mode => "sections",
        open_first_section => 1,
        group_range_function => "EPrints::Update::Views::cluster_ranges_30",
        grouping_function => "group_by_a_to_z_hideempty",
        }, 
    ],
    order => "creators_name/date", 
},

{   id => "facet",
    allow_null => 0,
    hideempty => 1,
    menus => [
        {
            id => "facet_menu",
            fields => [ "facet" ],
            hideempty => 1,
            values_function => sub {
                my( $repo, $menu, $lang ) = @_;

                # determine archive dir (fallback to your known path)
                my $conf = eval { $repo->get_conf } || {};
                my $archdir = $conf->{archivedir} || '/opt/eprints3/archives/arcomt';

                my $helper_file = "$archdir/cfg/cfg.d/z_taxonomy_db.pl";

                # load the helper file using do() so the path is resolved correctly
                if( -f $helper_file ) {
                    do $helper_file;
                    if( my $err = $@ ) {
                        # compile/runtime error
                        $repo->log( "z_taxonomy_db.pl load error: $err" ) if $repo->can('log');
                        return;  # let EPrints fall back to default indexing
                    }
                } else {
                    # file not found — fall back
                    return;
                }

                # Now call the helper package
                eval {
                    require TaxonomyDBHelpers;
                    my $vals = TaxonomyDBHelpers::get_facets($repo);
                    return $vals;
                } or do {
                    $repo->log("TaxonomyDBHelpers::get_facets failed: $@") if $repo->can('log');
                    return;
                };
            },
        },
        {
            fields => [ "iterm" ],
            group => "facet_menu",
            hideempty => 1,
            values_function => sub {
                my( $repo, $menu, $selected_values, $lang ) = @_;
                my $facet = $selected_values && @$selected_values ? $selected_values->[0] : undef;
                return [] unless defined $facet && $facet ne '';

                my $conf = eval { $repo->get_conf } || {};
                my $archdir = $conf->{archivedir} || '/opt/eprints3/archives/arcomt';
                my $helper_file = "$archdir/cfg/cfg.d/z_taxonomy_db.pl";

                if( -f $helper_file ) {
                    do $helper_file;
                    if( my $err = $@ ) {
                        $repo->log( "z_taxonomy_db.pl load error: $err" ) if $repo->can('log');
                        return [];
                    }
                } else {
                    return [];
                }

                eval {
                    require TaxonomyDBHelpers;
                    my $iterms = TaxonomyDBHelpers::get_iterms_for_facet($repo, $facet);
                    return $iterms;
                } or do {
                    $repo->log("TaxonomyDBHelpers::get_iterms_for_facet failed: $@") if $repo->can('log');
                    return [];
                };
            },
            sort_order => sub {
                my( $repo, $values, $lang ) = @_;
                my @sorted = sort { lc($a) cmp lc($b) } @$values;
                return \@sorted;
            },
        },
    ],
    filters => [
        { meta_fields => [ "facet" ], value => ".+" },
        { meta_fields => [ "iterm" ], value => ".+" },
    ],
    order => "creators_name/date",
    max_items => 10000,
},

{   id => "dscope",
    allow_null => 0,
    hideempty => 1,
    menus => [
        { 
        fields => [ "dscope" ], 
        }, 
    ],
    order => "creators_name/date", 
};
