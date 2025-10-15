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
    render_title => sub {
        my ($session, $current_view, $menu, $value) = @_;

    $session->get_repository->log("=== RENDER_TITLE CALLED ===");
    $session->get_repository->log("Menu 0 selected: " . ($current_view->{menus}->[0]{selected} || 'UNDEF'));
    $session->get_repository->log("Menu 1 selected: " . ($current_view->{menus}->[1]{selected} || 'UNDEF'));
    $session->get_repository->log("Number of menus: " . scalar(@{$current_view->{menus}}));
    
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

$session->get_repository->log("=== RENDER_UP_LINK CALLED ===");
$session->get_repository->log("Menu 0 selected: " . ($current_view->{menus}->[0]{selected} || 'UNDEF'));
$session->get_repository->log("Menu 1 selected: " . ($current_view->{menus}->[1]{selected} || 'UNDEF'));
    
    # Your existing logic here...
    if (defined $current_view->{menus}->[1]{selected}) {
        return $session->html_phrase("navigation:back_to_volumes");
    }
        
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
    render_title => sub {
        my ($session, $current_view, $menu, $value) = @_;
        
        # First level: Browse by Document Type
        if (!defined $current_view->{menus}->[0]{selected}) {
            return $session->html_phrase("viewtitle:browse_by_doctype");
        }
        # Second level: Browse by [Specific Type]
        else {
            my $type_value = $current_view->{menus}->[0]{selected};
            my $phrase_id = "viewtitle:browse_by_" . lc($type_value);
            
            if ($session->get_lang->has_phrase($phrase_id, $session)) {
                return $session->html_phrase($phrase_id);
            } else {
                return $session->make_text("Browse by " . $type_value);
            }
        }
    },
    render_up_link => sub {
        my ($session, $current_view, $menu) = @_;
        if (defined $current_view->{menus}->[0]{selected}) {
            return $session->html_phrase("navigation:back_to_doctypes");
        }
        return undef;
    },
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
