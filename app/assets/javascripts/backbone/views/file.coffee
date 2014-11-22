class AC.Views.File extends Backbone.View

	tagName: 'li'

	initialize: ()->
    	# _.bindAll @
    	@render()

	render: ()->
		$el = $(@el)
		$el.attr 'id', @model.get('basename')
		$el.data 'json', @model
		$el.html @model.get('basename')
		if @model.isDirectory()
			$el.addClass('folder')
			children_list = $("<ul></ul>")
			_(@model.get('children').models).each (child)->
				children_list.append new AC.Views.File(model: child).el
			$el.append(children_list)
		$el