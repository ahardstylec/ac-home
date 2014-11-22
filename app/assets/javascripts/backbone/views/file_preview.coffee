class AC.Views.FilePreview extends Backbone.View

	templates:
		video: JST['templates/file_video']
		image: JST['templates/file_image']
		audio: JST['templates/file_audio']
		text: JST['templates/file_text']
		empty: ()-> ""

	initialize: (options)->
		# _.bindAll 
		AC.filesystem_content.setCurrent(@model)
		if not options.navigate
			AC.file_view_stack.push(@model)
			if AC.file_view_stack.length > 30
				AC.file_view_stack.shift()
			AC.file_stack_pointer = _.size(AC.file_view_stack) - 1
		@render()

	render: ()->
		key = @model.getTemplateKey()
		breadcrumb = $(new AC.Views.Breadcrumb(model: @model).el)
		breadcrumb.css('width', '81%')
		
		$(@el).append($("<div>").addClass('row').append(@navigate_left()).append(breadcrumb).append(@navigate_right()).append(@navigate_up()))
		if @model.isDirectory()
			$(@el).append new AC.Views.FileFolder(model: @model).el
		else
			$(@el).append @templates[key](helper: AC.view_helper, file: @model)
		$(@el)

	navigate_up: ()->
		link = $(AC.view_helper.link_to AC.view_helper.icon_tag('chevron-up', '', '2x', style: 'margin-top: 5px'), '#')
					.css('text-align': 'center')
		if not AC.filesystem_content.isThereUp()
			link.addClass('disabled')
		link[0].onclick = ()=>
			parent = @model.parent()
			if parent
				$('.content').html new AC.Views.FilePreview(model: parent).el
		$("<div>").addClass("col-xs-1").append(link).css('width': '5.333%')

	navigate_left: ()->
		link = $(AC.view_helper.link_to AC.view_helper.icon_tag('chevron-left', '', '2x', style: 'margin-top: 5px'), '#')
					.css('text-align': 'center')
		if not AC.filesystem_content.isTherePrev()
			link.addClass('disabled')
		link[0].onclick = ()->
			prev = AC.filesystem_content.prev()
			if prev
				$('.content').html new AC.Views.FilePreview(model: prev).el
		$("<div>").addClass("col-xs-1").append(link).css('width': '5.333%')

	navigate_right: ()->
		link = $(AC.view_helper.link_to AC.view_helper.icon_tag('chevron-right', '', '2x', style: 'margin-top: 5px'), '#')
					.css('text-align': 'center').addClass('next_link')
		if not AC.filesystem_content.isThereNext()
			link.addClass('disabled')
		link[0].onclick = ()->
			next = AC.filesystem_content.next()
			if next
				$('.content').html new AC.Views.FilePreview(model: next).el
		$("<div>").addClass("col-xs-1").append(link).css('width': '5.333%')
