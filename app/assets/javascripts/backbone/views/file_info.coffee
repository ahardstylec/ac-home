class AC.Views.FileInfo extends Backbone.View

	template: JST['templates/file_info']

	initialize: ()->
      # _.bindAll @
      @render()

	render: (file)->
		$(@el).html @template(helper: AC.view_helper, file: @model)
		$(@el)