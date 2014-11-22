create_attachment= (modal, event)->
	link = modal.find('#attachment_link').val()
	remote_url = modal.find('#attachment_gif').val()
	embedded_html= modal.find('textarea').val()
	attachment={link: link, remote_url: remote_url, embedded_html: embedded_html}
	AC.Ajax.post('/attachments/create', {attachment: attachment}, success: (response)->
		if response.success
			$('.attachments').prepend($(response.html))
			modal.data('hide')
			modal.data('modal', null)
		else
			AC.Alert.error response.error, append_to: '.attachment_form'
	)

toggle_gif = (link)->
	image = $(link).find('img.thumb_image')
	gif = image.siblings()
	if image.data('show_gif')
		image.data('show_gif', false)
		gif.remove()
		image.show()
	else
		if /image/.test(image.data('type'))
			preview = $("<img class='img-rounded' src='#{image.data('gif')}' title='video not supported'>")
		else
			preview = $("<video autoplay='autoplay' loop='loop' style='width: 100%'>")
			preview.append($("<source>").attr('src', image.data('gif')).attr('type', image.data('type')))
			preview.append($("<source>").attr('src', image.data('remote_url')))
		image.after(preview)
		image.data('show_gif', true)
		image.hide()

$(document).ready ()->
	$('body').on 'click', '.attachment_thumb', (event)-> 
		event.preventDefault()
		if event.which == 2
			new_window = window.open($(@).data('show'), '_blank')
			new_window.focus()
		else
			toggle_gif(@)

	$('body').on 'click', '.delete_attachment', (event)-> 
		id = $(@).data('id')
		$attachment = $("#attachment_#{id}")
		console.log id 
		bootbox.confirm "Dateien wirklich löschen?", (res)->
			if res
				AC.Ajax.post "/attachments/destroy/#{id}", {}, success: (response)->
					if response.success
						$attachment.fadeOut()
					else
						AC.Alert.error response.error

	$('body').on 'click', '.edit_attachment', (event)-> 
		$attachment = $(@).parents('.attachment')
		id = $attachment.data('id')
		bootbox.confirm "Dateien wirklich löschen?", (res)->
			if res
				AC.Ajax.post "/attachments/edit/#{id}", {}, success: (response)->
					if response.success
						$attachment.fadeOut()
					else
						AC.Alert.error response.error

	$('body').on 'click', '.new_attachment', (event)->
		template= JST['templates/modal']
		new_attachment = JST['templates/new_attachment']
		modal = template(title: 'new attachment', body: new_attachment(), id: 'attachment_modal')
		$('body').append(modal)

		modal = $("#attachment_modal")
		button = $("#attachment_modal_success")
		if button.length > 0
			button[0].onclick= (event)->
				create_attachment(modal, event)
		$(modal).modal('show')