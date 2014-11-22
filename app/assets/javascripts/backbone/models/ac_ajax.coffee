class AC.Ajax
	@async: true
	
	@post: (url, params={}, options={dataType: 'json'})->
		options.type= 'post'
		@request url, params, options

	@get: (url, params={}, options={dataType: 'json'})->
		options.type = 'get'
		@request url, params, options

	@beforeSendDefault: (fun, options)->
		if options.refresh_content
			$('.content').hide()
			$('.load_content').removeClass("hide")
		if _.isFunction(fun)
			fun()

	@completeDefault: (fun, options)->
		if options.refresh_content
			$('.load_content').addClass("hide")
			$('.content').show()
		if _.isFunction(fun)
			fun()	
		
	@request: (url, params, options)->
		$.ajax
			dataType: options.dataType || 'json'
			url: url
			async: @async
			type: options.type || 'get'
			data: params
			success: options.success || ()->
			beforeSend: ()=>
				@beforeSendDefault options.beforeSend, options
			complete: ()=>
				@completeDefault options.complete, options
			error: options.error || ()->
			CSRFProtection: (xhr)->
				token = $('meta[name="csrf-token"]').attr('content')
				xhr.setRequestHeader('X-CSRF-Token', token) if (token)

	@download_file: (path, type)->
		filename = AC.filesystem_content.set_filename_from_type(path, type)
		$.fileDownload '/files/download', data: {files: [path], filename: filename, type: type, download_type: 'temp'}, httpMethod: 'post'


class AC.Ajax.Sync extends AC.Ajax
	@async: false
