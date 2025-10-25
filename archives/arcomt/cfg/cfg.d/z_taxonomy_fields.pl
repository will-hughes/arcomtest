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
    maxlength => 10,
    required => 0,
    input_boxes => 1,
},
# NEW: Compound fields to preserve taxonomic relationships
{	
    name => 'facet_iterm',
    type => 'text',
    multiple => 1,
    required => 0,
},
{	
    name => 'facet_domain',
    type => 'text',
    multiple => 1,
    required => 0,		   
},
{	
    name => 'domain_subject',
    type => 'text',
    multiple => 1,
    required => 0,		   
},
{	
    name => 'subject_iterm',
    type => 'text',
    multiple => 1,
    required => 0,		   
},
{	
    name => 'taxonomy_path',
    type => 'text',
    multiple => 1,
    required => 0,		   
},
;
