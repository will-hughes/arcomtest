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
{   id => "iterm",
    menus => [ { fields => [ "iterm" ], }, ],
    order => "creators_name/date", 
    },
{   id => "subject",
    menus => [ { fields => [ "subject" ], }, ],
    order => "creators_name/date", 
},
{   id => "domain",
    menus => [ { fields => [ "domain" ], }, ],
    order => "creators_name/date", 
},
{   id => "facet",
    menus => [ { fields => [ "facet" ], }, ],
    order => "creators_name/date", 
};

