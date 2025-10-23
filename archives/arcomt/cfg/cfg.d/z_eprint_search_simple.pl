$c->{search}->{simple} = 
{
	search_fields => [
		{
			id => "q",
			meta_fields => [
				"abstract",
				"keywords",
				"subject",
				"domain",
				"creators_name",
				"title",
			]
		},
	],
	template => "default",
#	preamble_phrase => "cgi/search:preamble",
	title_phrase => "cgi/search:simple_search",
	citation => "result",
	page_size => 100,
	order_methods => {
		"bytitle"   => "title/type",
	    "byauthor"  => "creators_name/creators_name",
	},
	default_order => "bytitle",
	show_zero_results => 1,
};
		

=head1 COPYRIGHT

=for COPYRIGHT BEGIN

Copyright 2024 University of Southampton.
EPrints 3.4 is supplied by EPrints Services.

http://www.eprints.org/eprints-3.4/

=for COPYRIGHT END

=for LICENSE BEGIN

This file is part of EPrints 3.4 L<http://www.eprints.org/>.

EPrints 3.4 and this file are released under the terms of the
GNU Lesser General Public License version 3 as published by
the Free Software Foundation unless otherwise stated.

EPrints 3.4 is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with EPrints 3.4.
If not, see L<http://www.gnu.org/licenses/>.

=for LICENSE END

