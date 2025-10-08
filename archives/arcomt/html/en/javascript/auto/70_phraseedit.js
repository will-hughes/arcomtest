
function ep_decode_html_entities( str )
{
	str = str.replace( /\&quot;/g, "\"" );
	str = str.replace( /\&squot;/g, "'" );
	str = str.replace( /\&lt;/g, "<" );
	str = str.replace( /\&gt;/g, ">" );
	str = str.replace( /\&amp;/g, "&" );
	return str;
}

function ep_phraseedit_addphrase( event, base_id, csrf_token='' )
{
	if( base_id == '' )
	{
		alert( "No phrase ID specified" );
		return false;
	}	
	var lang_id = eprints_lang_id;
	if( $("ep_phraseedit_newlang") != null )
	{
		lang_id = $("ep_phraseedit_newlang").value;
	}
	if( $("ep_lang_"+lang_id+"_phraseedit_"+base_id) != null )
	{
		alert( "The phrase '"+base_id+"' already exists for language code '"+lang_id+"'" );
		return false;
	}
	
	$("ep_phraseedit_add").disabled = true;
	$("ep_phraseedit_newid").disabled = true;
	if( $("ep_phraseedit_newlang") != null )
	{
		$("ep_phraseedit_newlang").disabled = true;
	}
	
	new Ajax.Request(
		eprints_http_cgiroot+"/users/home",
		{
			method: "post",
			onFailure: function() { 
				$("ep_phraseedit_add").disabled = false;
				$("ep_phraseedit_newid").disabled = false;
				if( $("ep_phraseedit_newlang") != null )
				{
					$("ep_phraseedit_newlang").disabled = false;
				}
				alert( "AJAX request failed..." );
			},
			onException: function(req, e) { 
				$("ep_phraseedit_add").disabled = false;
				$("ep_phraseedit_newid").disabled = false;
				if( $("ep_phraseedit_newlang") != null )
                {
                    $("ep_phraseedit_newlang").disabled = false;
                }
				alert( "AJAX Exception " + e.message );
			},
			onSuccess: function(response){ 
				var text = response.responseText;
				$("ep_phraseedit_add").disabled = false;
				$("ep_phraseedit_newid").disabled = false;
				if( $("ep_phraseedit_newlang") != null )
                {
                    $("ep_phraseedit_newlang").disabled = false;
                }
				if( text.length == 0 )
				{
					alert( "No response from server..." );
				}
				else
				{
					$("ep_phraseedit_newid").value = "";
					var table = $('ep_phraseedit_table');
					var first_tr = Element.down(table, 'tr');
					/* first tr is the table header */
					first_tr = first_tr.nextSibling;

					/* parse the new row */
					var parser = document.createElement( 'table' );
					Element.extend( parser );
					parser.update( text );
					var tr = Element.down(parser, 'tr');

					first_tr.parentNode.insertBefore( tr, first_tr );
				}
			},
			parameters: { 
				screen: "Admin::Phrases", 
				phraseid: base_id, 
				phrase: $('ep_phraseedit_newid').value,
				lang: lang_id,
				csrf_token: csrf_token
			} 
		} 
	);
	return false;
}

function ep_phraseedit_save(base_id, lang_id, phrase, csrf_token='')
{
	new Ajax.Request(
		eprints_http_cgiroot+"/users/home",
		{
			method: "post",
			onFailure: function() { 
				var form = $('ep_lang'+lang_id+'_phraseedit_'+base_id);
				ep_phraseedit_enableform(form);
				alert( "AJAX request failed..." );
			},
			onException: function(req, e) { 
				var form = $('ep_lang'+lang_id+'_phraseedit_'+base_id);
				ep_phraseedit_enableform(form);
				alert( "AJAX Exception " + e.message );
			},
			onSuccess: function(response){ 
				var text = response.responseText;
				if( text.length == 0 )
				{
					ep_phraseedit_enableform(form);
					alert( "No response from server..." );
				}
				else
				{
					var form = $('ep_lang_'+lang_id+'_phraseedit_'+base_id);

					/* parse the new row */
					var parser = document.createElement( 'table' );
					Element.extend( parser );
					parser.update( text );
					var new_tr = Element.down(parser, 'tr');

					var tr = form.up('tr');
					tr.parentNode.replaceChild( new_tr, tr );
				}
			},
			parameters: { 
				screen: "Admin::Phrases", 
				phraseid: base_id, 
				lang: lang_id,
				phrase: phrase,
				csrf_token: csrf_token
			} 
		} 
	);
}

function ep_phraseedit_disableform(form)
{
	for(var i = 0; i < form.childNodes.length; ++i)
	{
		var n = form.childNodes[i];
		n.disabled = true;
	}
}

function ep_phraseedit_enableform(form)
{
	for(var i = 0; i < form.childNodes.length; ++i)
	{
		var n = form.childNodes[i];
		n.disabled = false;
	}
}

function ep_phraseedit_edit(div, phrases, csrf_token='')
{
	var container = div.parentNode;
	container.removeChild( div );

	/* less "ep_phraseedit_" */
	var base_id = div.id.replace( /.*_phraseedit_/, '' );
	var lang_id = div.id.replace( /_phraseedit_.*/, '' );
	lang_id = lang_id.replace( /^ep_lang_/, '' );
	console.log( "base_id: "+base_id+" | lang_id: "+lang_id );

	var form = document.createElement( "form" );
	form.setAttribute( 'id', div.id );
	form._base_id = base_id;
	form._lang_id = lang_id;
	form._original = ep_decode_html_entities( div.innerHTML );
	form._widget = div;
	var textarea = document.createElement( 'textarea' );
	textarea.value = form._original;
	textarea.setAttribute( 'rows', '2' );
	textarea.setAttribute( 'aria-labelledby', div.id + "__label" );
	form.appendChild( textarea );

	var input;
	/* CSRF token */
	if ( csrf_token !== '' )
	{
		input = document.createElement( 'input' );
	        input.setAttribute( 'type', 'hidden' );
        	input.value = csrf_token;
		form.appendChild( input );
	}

	/* save */
	input = document.createElement( 'input' );
	input.setAttribute( 'type', 'button' );
	input.value = phrases['save'];
	Event.observe(input,'click',function(event) {
		var form = event.element().parentNode;
		ep_phraseedit_disableform(form);
		var textarea = form.firstChild;
		ep_phraseedit_save(form._base_id, form._lang_id, textarea.value, csrf_token);
	});
	form.appendChild( input );
	/* reset */
	input = document.createElement( 'input' );
	input.setAttribute( 'type', 'button' );
	input.value = phrases['reset'];
	Event.observe(input,'click',function(event) {
		var form = event.element().parentNode;
		var textarea = form.firstChild;
		textarea.value = form._original;
	});
	form.appendChild( input );
	/* cancel */
	input = document.createElement( 'input' );
	input.setAttribute( 'type', 'button' );
	input.value = phrases['cancel'];
	Event.observe(input,'click',function(event) {
		var form = event.element().parentNode;
		var container = form.parentNode;
		container.removeChild( form );
		container.appendChild( form._widget );
	});
	form.appendChild( input );

	container.appendChild( form );
	textarea.focus();
	while(textarea.scrollHeight > textarea.clientHeight && !window.opera)
	{
		textarea.rows += 1;
	}
}
