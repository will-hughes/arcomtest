push @{$c->{fields}->{eprint}},

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
    name => 'dscope',
    type => 'text',
    required => 0,
    input_boxes => 1,
},
;
