class AC.Views.Breadcrumb extends Backbone.View

	tagName: 'ol'
	className: 'breadcrumb col-xs-10'

	initialize: ()->
		@render()

	render: ()->
		model = @model
		breadcrumb =_.chain(model.descend()).select (dpath)->
			if /data\//.test(dpath) then true else false
		.map (dpath)->
			res = $("<li class='breadcrumb_li #{if (dpath==model.get('path')) then "active" else ''}'></li>")
			file = AC.filesystem_content.findFileByPath dpath.chomp("/")
			if file
				popover_content = new AC.Views.FileInfo({model: file}).el
				link= $(AC.view_helper.link_to(file.get('basename'), '#', class: 'breadcrump_link')).data('file', file)
				div = $("<div class='breadcrumb_popover_div' style='display: inline'>").append(link)
						.data('title', "Datei Informationen")
						.data('toggle','popover')
						.data('content', popover_content)
						.data('placement','bottom')
						.data('html', true)
						.popover()
						.on('mouseenter', ()-> $('.popover').remove(); $(@).popover('show'))
				res.append(div)
			else
				res.append('not found')
		$(@el).append breadcrumb.value()
		$(@el)