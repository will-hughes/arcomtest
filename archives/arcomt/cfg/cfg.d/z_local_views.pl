push @{$c->{browse_views}},
{
        id => "journal_volume",
        menus => [
            {
                fields => [ "publication" ],
                hideempty => 1,
            },
            {
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
            if ($menu->{fields}->[0] eq "publication") {
                return $session->html_phrase("viewtitle:browse_by_journal");
            } 
            elsif ($menu->{fields}->[0] eq "volume") {
                my $journal = $menu->{group_value} || "Journal";
                my $dataset = {
                    journal => $session->make_text($journal),
                    volume => defined $value ? $session->make_text($value) : undef
                };
                return defined $value 
                    ? $session->html_phrase("viewtitle:browse_volume_contents", %$dataset)
                    : $session->html_phrase("viewtitle:browse_volumes_of_journal", %$dataset);
            }
            return $session->make_text("Browse");
        },
        render_up_link => sub {
            my ($session, $current_view, $menu) = @_;
            return $session->html_phrase("navigation:back_to_journals");
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
		menus => [
			{
				fields => [ "iterm" ],
				hideempty => 1,
			}
		],
		order => "creators_name/title",
		include => 1,
		variations => [
			"creators_name;first_letter",
			"type",
		],
	};

#{
#    id => "iterm",
#    allow_null => 0,
#    hideempty => 1,
#    menus => [
#        {
#            fields => [ "iterm" ],
#            new_column_at => [1, 1],
#            mode => "sections",
#            open_first_section => 1,
#            group_range_function => "EPrints::Update::Views::cluster_ranges_30",
#            grouping_function => "group_by_a_to_z_hideempty",
#        },
#    ],
#    order => "creators_name/date",
#    variations => [
#        "creators_name;first_letter",
#        "type",
#        "DEFAULT"
#    ],
#};
