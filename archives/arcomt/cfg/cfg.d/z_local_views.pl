
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
};
	
push @{$c->{browse_views}},
{
    id => "divisions",
    menus => [
        {
            fields => [ "divisions" ],  # Level 1: Research Facets
            hideempty => 1,
            allow_null => 0,
            mode => "tree",
            open_first_section => 1,
        },
        {
            fields => [ "subjects" ],   # Level 2: Index Terms under selected facet
            hideempty => 1,
            allow_null => 0,
            mode => "tree", 
            open_first_section => 1,
            group => "divisions",  # Filter subjects to only those related to the selected division
        }
    ],
    order => "creators_name/title",
    include => 1,
    variations => [
        "creators_name;first_letter",
        "type",
        "DEFAULT",
    ],
    max_items => 10000,
    render_title => sub {
        my ($session, $current_view, $menu, $value) = @_;
        
        if ($menu->{fields}->[0] eq "divisions") {
            return $session->html_phrase("browse_by_research_facets");
        }
        elsif ($menu->{fields}->[0] eq "subjects") {
            my $facet = $menu->{group_value} || "Research Facet";
            my $dataset = {
                facet => $session->make_text($facet),
                subject => defined $value ? $session->make_text($value) : undef
            };
            return defined $value
                ? $session->html_phrase("browse_facet_subject", %$dataset)
                : $session->html_phrase("browse_subjects_in_facet", %$dataset);
        }
        return $session->make_text("Browse Research Facets");
    },
},

{
    id => "subjects",
    menus => [
        {
            fields => [ "subjects" ],  # Level 1: Subject Groups  
            hideempty => 1,
            allow_null => 0,
            mode => "tree",
            open_first_section => 1,
        },
        {
            fields => [ "subjects" ],  # Level 2: Index Terms under selected subject group
            hideempty => 1, 
            allow_null => 0,
            mode => "tree",
            open_first_section => 1,
            group => "subjects",  # This will show the hierarchical children of the selected subject
        }
    ],
    order => "creators_name/title",
    include => 1,
    variations => [
        "creators_name;first_letter",
        "type",
        "DEFAULT",
    ],
    max_items => 10000,
    render_title => sub {
        my ($session, $current_view, $menu, $value) = @_;
        
        if ($menu->{fields}->[0] eq "subjects" && !$menu->{group}) {
            return $session->html_phrase("browse_by_subjects");
        }
        elsif ($menu->{fields}->[0] eq "subjects" && $menu->{group}) {
            my $subject_group = $menu->{group_value} || "Subject";
            my $dataset = {
                subject_group => $session->make_text($subject_group),
                index_term => defined $value ? $session->make_text($value) : undef
            };
            return defined $value
                ? $session->html_phrase("browse_subject_index_term", %$dataset)
                : $session->html_phrase("browse_index_terms_in_subject", %$dataset);
        }
        return $session->make_text("Browse Subjects");
    },
};
