
# Browse views. allow_null indicates that no value set is 
# a valid result. 
# Multiple fields may be specified for one view, but avoid
# subject or allowing null in this case.

##
# set a global max_items limit:
#	$c->{browse_views_max_items} = 3000;
#
# set a per view max_item limit:
#	 $c->{browse_views} = [{
#		 ...
#		 max_items => 3000,
#	 }];
# To disable the limit set max_items to 0.
#
# For views that take a long time to generate, you may want to define max_menu_age and/or max_list_age.
# These both default to 24hours, but can be defined for each view:
#	 $c->{browse_views} = [{
#		 ...
#		 max_menu_age => 10*24*60*60, # 10days
#		 max_list_age => 10*24*60*60,
#	 }];
# 
# If you are changing these, you may want to generate the views using the bin/generate_views script.


push @{$c->{browse_views}},
{
        id => "journal_volume",
        menus => [
            {
                fields => [ "publication" ],  # First level: Journals
                hideempty => 1,  # Hide journals with no articles
            },
            {
                fields => [ "volume" ],  # Second level: Volumes
                hideempty => 1,  # Hide volumes with no articles
                group => "publication",  # Group volumes under their respective journals
					sort_order => sub {
					my( $repo, $values, $lang ) = @_;
					my @sorted_values = sort { $a <=> $b } @$values; ## Use numeric sorting method
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
            { meta_fields => [ "type" ], value => "article" },  # Only include articles
            { meta_fields => [ "publication" ], value => ".+" },  # Exclude items with empty publication
            { meta_fields => [ "volume" ], value => ".+" },  # Exclude items with empty volume
			],
		order => "number/title",  # Sort articles by number, then title
        max_items => 10000,  # Set the limit to 10,000 items
        variation => [
			"DEFAULT;numeric",
		],
},

{
   id=>"doctype", # Browse by type of document
   menus => 
	[ 
	{	 
		fields => [ "type" ], 
	},
	], 
    order => "creators_name/date",
		variations => [
			"creators_name;first_letter",
			"type",
			"DEFAULT" ],
},
{
    id => "taxonomy_index",
    menus => [
        {
            fields => [ "taxonomy_terms" ],
            hideempty => 1,
            allow_null => 0,
            mode => "sections",
            open_first_section => 1,
            group_range_function => "EPrints::Update::Views::cluster_ranges_30",
            grouping_function => "group_by_a_to_z_hideempty",
        },
        {
            fields => [ "creators_name" ],
            hideempty => 1,
            allow_null => 0,
            mode => "sections",
            open_first_section => 1,
            group_range_function => "EPrints::Update::Views::cluster_ranges_30",
            grouping_function => "group_by_a_to_z_hideempty",
        }
    ],
    order => "creators_name/title",
    include => 1,
    variations => ["creators_name;first_letter", "type", "DEFAULT"],
    max_items => 10000,
},
};
	
