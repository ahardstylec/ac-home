class AC.Views.FileFolder extends Backbone.View

	className: 'folder_content'

	templates:
		folder: JST['templates/file_folder']
		folder_tr: JST['templates/file_folder_tr']


	initialize: ()->
      # _.bindAll @
      @render()

	render: ()->
		folder= @
		$(@el).data('path', @model.get('path'))
		$(@el).html @templates['folder'](helper: AC.view_helper, file: @model)
		$(@el).find('tbody').append _(@model.get('children').models).map (c)->
			tr = $(folder.templates['folder_tr'](helper: AC.view_helper, file: c)).data('file', c)
			tr
		$(@el)