push @($c->{fields}->{eprint}}'

{	
    name => 'iterm',
    type => 'text',
    multiple => 1,
    required => 0,
},
{	
	name => 'facet',
	type => 'text',
	multiple => 1,
	required => 0,		   
},
{	
	name => 'domain',
	type => 'text',
	multiple => 1,
	required => 0,		   
},
{	
	name => 'subject',
	type => 'text',
	multiple => 1,
	required => 0,		   
},
{
    name => 'descriptive_scope',
    type => 'int',  # Store as integer (0-5)
    required => 0,
    input_boxes => 1,
},
;
