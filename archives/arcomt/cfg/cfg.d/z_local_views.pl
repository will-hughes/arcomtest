push @{$c->{browse_views}},
{
        id => "journal_volume",
        menus => [
            {
                id => "publication_menu", # menu ID for better identification
                fields => [ "publication" ],
                hideempty => 1,
            },
            {
                id => "volume_menu", # menu ID for better identification        
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
        render_title => sub {
        my ($session, $current_view, $menu, $value) = @_;
        
        # Debug: Check what we're working with
        # $session->get_repository->log("Current menu: " . ($menu->{id} || 'no id'));
        # $session->get_repository->log("Menu fields: " . join(',', @{$menu->{fields}}));
        
        # Level 1: No publication selected yet
        if (!defined $current_view->{menus}->[0]{selected}) {
            return $session->html_phrase("viewtitle:browse_by_journal");
        }
        
        # Level 2: Publication selected, but no volume selected
        elsif (!defined $current_view->{menus}->[1]{selected}) {
            my $journal = $current_view->{menus}->[0]{selected};
            return $session->html_phrase(
                "viewtitle:browse_volumes_of_journal",
                journal => $session->make_text($journal)
            );
        }
        
        # Level 3: Both publication and volume selected
        else {
            my $journal = $current_view->{menus}->[0]{selected};
            my $volume = $current_view->{menus}->[1]{selected};
            return $session->html_phrase(
                "viewtitle:browse_volume_contents", 
                journal => $session->make_text($journal),
                volume => $session->make_text($volume)
            );
        }
    },
        render_up_link => sub {
        my ($session, $current_view, $menu) = @_;
        
        # Level 3: Back to volumes list
        if (defined $current_view->{menus}->[1]{selected}) {
            return $session->html_phrase("navigation:back_to_volumes");
        }
        # Level 2: Back to journals list  
        elsif (defined $current_view->{menus}->[0]{selected}) {
            return $session->html_phrase("navigation:back_to_journals");
        }
        # Level 1: No up link needed
        else {
            return undef;
        }
    },
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
    variations => [
        "creators_name;first_letter",
        "type",
        "DEFAULT"
    ],
},

{
    id => "iterm",
    allow_null => 0,
    hideempty => 1,
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
#    variations => [
#        "creators_name;first_letter",
#        "type",
#        "DEFAULT"
#    ],
};
