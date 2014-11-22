window.breadcrumb_popover_timeout= null
$(document).ready ()->
	#, distance: 1
	$('body').on 'keyup', (event)->

		# file next
		if event.ctrlKey and event.which is 39
			next_file = AC.filesystem_content.next(AC.filesystem_content.getCurrent())
			if next_file
				$('.content').html new AC.Views.FilePreview(model: next_file).el
		# file before
		else if event.ctrlKey and event.which is 37
			prev_file = AC.filesystem_content.prev(AC.filesystem_content.getCurrent())
			if prev_file
				$('.content').html new AC.Views.FilePreview(model: prev_file).el

		# parent file
		else if event.ctrlKey and event.which is 38
			AC.file_stack_pointer= AC.file_stack_pointer-1
			previous_file = AC.file_view_stack[AC.file_stack_pointer]
			if previous_file
				$('.content').html new AC.Views.FilePreview(navigate: true, model: previous_file).el
			else
				AC.file_stack_pointer= AC.file_stack_pointer+1

		# previous file from stack
		else if event.ctrlKey and event.which is 40
			AC.file_stack_pointer= AC.file_stack_pointer+1
			previous_file = AC.file_view_stack[AC.file_stack_pointer]
			if previous_file
				$('.content').html new AC.Views.FilePreview(navigate: true, model: previous_file).el
			else
				AC.file_stack_pointer= AC.file_stack_pointer-1

	$('body').on 'mouseleave', '.popover', ()-> $(@).remove()
	$('body').on 'mouseenter', '.popover', ()->
		clearTimeout(window.breadcrumb_popover_timeout)
	$('body').on 'mouseleave','.breadcrumb_popover_div', ()-> 
		window.breadcrumb_popover_timeout = setTimeout ()->
			$('.popover').remove();
		, 300

	$(".files_table").on 'click', 'tbody tr', (e)->
		if (e.ctrlKey == false)
			# if command key is pressed don't deselect existing elements
			$( ".files_table > tbody tr" ).removeClass("ui-selected");
			$(this).addClass("ui-selected");
		else
			if ($(@).hasClass("ui-selected"))
				# remove selected class from element if already selected
				$(@).removeClass("ui-selected");
			else 
				# add selecting class if not
				$(@).addClass("ui-selected")

		$(".files_table").data("selectable")._mouseStop(null)

	$('body').on 'click', '.download_file_buttons', (e)->
		filepath = $(@).data('path')
		type = $(@).data('type')
		AC.Ajax.download_file filepath, type

	$('body').on 'click', '.breadcrump_link', (e)->
		console.log $(@).data('file')
		$(@).data('file').renderPreview()

	$('body').on 'click', '.delete_files_button', (e)->
		selected_files = _($('.select_file')).filter (file)->
			$(file).find('i').hasClass('fa-check-square-o')

		return if _(selected_files).isEmpty()
		files = _.map selected_files, (file)->
			$(file).data('path')
		bootbox.confirm "Dateien wirklich löschen?", (res)->
			if res
				AC.Ajax.post '/files/delete', {files: files}, success: (response)->
					if response.success
						_(selected_files).each (file)->
							$(file).parents('tr').fadeOut()
					else
						AC.error response.error

	$('body').on 'click','.download_files_buttons', (e)->
		selected_files = _($('.select_file')).filter (file)->
			$(file).find('i').hasClass('fa-check-square-o')

		return if _(selected_files).isEmpty()
		files = _.map selected_files, (file)->
			$(file).data('path')

		type = $(@).data('type')
		filename = "archiv"
		bootbox.prompt title: 'Archiv Name? (Dateiendung wird automatisch hinzugefügt)', value: filename, callback: (result)->
			filename = AC.filesystem_content.set_filename_from_type(result, type)
			$.fileDownload '/files/download', data: {files: files, filename: filename, type: type, download_type: 'temp'}, httpMethod: 'post'


	$('body').on 'click', '#select_all_files', (e)->
		e.preventDefault()
		el_icon = $(@).find('i')
		el_icon.toggleIcons 'square-o check-square-o'
		_($('.folder_content').find('tbody tr')).each (file)->
			tr = $(file)
			if el_icon.hasClass('fa-square-o')
				tr.removeClass('ui-selected')
			else
				tr.addClass('ui-selected')

	$('body').on 'dblclick', '.folder_content_tr', (e)->
		$(@).data('file').renderPreview();