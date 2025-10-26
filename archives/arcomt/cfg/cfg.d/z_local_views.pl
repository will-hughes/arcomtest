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

# Separate browse views for each facet type
{   id => "facet_analytical",
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
        } 
    ],
    filters => [
        { meta_fields => [ "facet" ], value => "analytical_technique" },
        { meta_fields => [ "iterm" ], value => ".+" },
    ],
    order => "creators_name/date", 
},

{   id => "facet_concept",
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
        } 
    ],
    filters => [
        { meta_fields => [ "facet" ], value => "concept" },
        { meta_fields => [ "iterm" ], value => ".+" },
    ],
    order => "creators_name/date", 
},

{   id => "facet_empirical",
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
        } 
    ],
    filters => [
        { meta_fields => [ "facet" ], value => "empirical_technique" },
        { meta_fields => [ "iterm" ], value => ".+" },
    ],
    order => "creators_name/date", 
},

{   id => "facet_individual",
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
        } 
    ],
    filters => [
        { meta_fields => [ "facet" ], value => "phenomenon_individual" },
        { meta_fields => [ "iterm" ], value => ".+" },
    ],
    order => "creators_name/date", 
},

{   id => "facet_location",
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
        } 
    ],
    filters => [
        { meta_fields => [ "facet" ], value => "phenomenon_location" },
        { meta_fields => [ "iterm" ], value => ".+" },
    ],
    order => "creators_name/date", 
},

{   id => "facet_object",
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
        } 
    ],
    filters => [
        { meta_fields => [ "facet" ], value => "phenomenon_object" },
        { meta_fields => [ "iterm" ], value => ".+" },
    ],
    order => "creators_name/date", 
},

{   id => "facet_process",
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
        } 
    ],
    filters => [
        { meta_fields => [ "facet" ], value => "phenomenon_process" },
        { meta_fields => [ "iterm" ], value => ".+" },
    ],
    order => "creators_name/date", 
},

{   id => "facet_role",
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
        } 
    ],
    filters => [
        { meta_fields => [ "facet" ], value => "phenomenon_role" },
        { meta_fields => [ "iterm" ], value => ".+" },
    ],
    order => "creators_name/date", 
},

{   id => "facet_theoretical",
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
        } 
    ],
    filters => [
        { meta_fields => [ "facet" ], value => "theoretical_framing" },
        { meta_fields => [ "iterm" ], value => ".+" },
    ],
    order => "creators_name/date", 
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
