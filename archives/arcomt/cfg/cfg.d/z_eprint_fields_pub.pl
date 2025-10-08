
push @{$c->{fields}->{eprint}},

{	# Added WPH 2025-03-07 for RIS.pm and Views
	name => 'thesis_type_display',
	type => 'text',
},
 
{	# Added WPH for wider range of doctorates
	name => 'thesis_name',
	type => 'set',
	options => [qw(
		phd
		mphil
		archd
		archdr
		darch
		dba
		dbl
		dcom
		ddes
		de
		ded
		delead
		deng
		dengr
		denv
		des
		diba
		dit
		dlittphil
		dm
		dman
		dpa
		dph
		dphil
		dprof
		dr
		dreng
		dring
		drsc
		drtech
		drtechn
		dsc
		dsctech
		dsc(tec)
		dsc(tech)
		sdsocsci
		dtech
		edd
		engd
		jd
		lld
		scd
		sjd
		skogldr
		takndr
		other
	)],
	input_style => 'medium',
        required => 1,  # Required for manual input
        allow_null => 0,  # Do not allow null values
},

;

