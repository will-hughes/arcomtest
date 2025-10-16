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
    ],
    order => "creators_name/date",
},

{
    id => "taxonomic",
        menus => [
        {
            fields => [ "iterm" ],
            new_column_at => [1, 1],
            mode => "sections",
            open_first_section => 1,
            group_range_function => "EPrints::Update::Views::cluster_ranges_30",
            grouping_function => "group_by_a_to_z_hideempty",
        },
    ],
    order => "creators_name/date",
    hideempty => 1,
    variations => [
        "iterm;filename=iterm,sections,grouping_function=group_by_a_to_z_hideempty,group_range_function=EPrints::Update::Views::cluster_ranges_30",
        "facet;filename=facet,sections,grouping_function=group_by_a_to_z_hideempty,group_range_function=EPrints::Update::Views::cluster_ranges_30",
        "domain;filename=domain,sections,grouping_function=group_by_a_to_z_hideempty,group_range_function=EPrints::Update::Views::cluster_ranges_30", 
        "subject;filename=subject,sections,grouping_function=group_by_a_to_z_hideempty,group_range_function=EPrints::Update::Views::cluster_ranges_30",
    ],
};

