class AC.Alert extends Backbone.View
	
	template: _.template '''
		<button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>
		<% if(typ == 'error'){%>
			<strong>Error!</strong>
		<%}%>
		<%= text %>
		'''

	className: 'alert alert-dismissable fade in'

	initialize: (text, options)->
		_.extend @, {options: options} if options not undefined
		@text= text
		if options.stable
			@render()
		else
			alert_view= @render()
			setTimeout ->
				alert_view.alert('close')
			, 1500
			alert_view

	@error: (text, options={typ: 'danger'})->
		new AC.Alert(text,options)
	
	@info: (text, options={typ: 'info'})->
		new AC.Alert(text,options)

	@success: (text, options={typ: 'success'})->
		new AC.Alert(text,options)

	@warning: (text, options={typ: 'warning'})->
		new AC.Alert(text,options)

	render: ()->
		$(@el).html @template({typ: @options.typ, text: @text})
		$(@el).addClass("alert-#{@options.typ}")
		if @options.append_to && $(@options.append_to).length > 0
			$(@options.append_to).append $(@el)
		else
			$('#alert-row').append($(@el))
		$(@el)