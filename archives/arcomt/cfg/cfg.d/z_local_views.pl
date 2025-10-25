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
            # Prefer taxonomy table values; fallback to normal index if the helper fails.
            values_function => sub {
                my( $repo, $menu, $lang ) = @_;
                eval {
                    require_once "archives/arcomt/cfg/cfg.d/z_taxonomy_db.pl";
                    my $vals = TaxonomyDBHelpers::get_facets($repo);
                    return $vals;
                } or do {
                    # If anything fails, return undef so EPrints uses the default index-based values.
                    return;
                };
            },
        },
        {
            # second-level menu: get iterms from taxonomy table for the selected facet
            fields => [ "iterm" ],
            group => "facet_menu",
            hideempty => 1,
            values_function => sub {
                my( $repo, $menu, $selected_values, $lang ) = @_;
                my $facet = $selected_values && @$selected_values ? $selected_values->[0] : undef;
                return [] unless defined $facet && $facet ne '';
                eval {
                    require_once "archives/arcomt/cfg/cfg.d/z_taxonomy_db.pl";
                    my $iterms = TaxonomyDBHelpers::get_iterms_for_facet($repo, $facet);
                    return $iterms;
                } or do {
                    return;
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
