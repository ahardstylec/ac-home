class AC.Models.File extends Backbone.AssociatedModel
	relations: [
		type: Backbone.Many
		key: 'children'
		collectionType: AC.Collections.Files
		relatedModel: Backbone.Self
	]

	descend: ()->
		arr =@get('path').split("/")
		first = [@get('path')]
		res = while arr.pop()
			arr.join("/")
		_.chain(first).union(res).reverse()

	isDirectory: ()->
		@get('directory') == true || @get('directory') == 'true'

	parent: ()->
		AC.filesystem_content.parent(@)

	share_with: (User)->
		AC.Ajax.post '/files/share_with', file: self.get('path'), User_id: User.id

	getIcon: ()->
		if @isDirectory()
			return 'folder'
		switch 
			when ('text/plain' == @mime_type) then 'file-text'
			when /image\//.test(@mime_type) then 'file-image-o'
			when /pdf/.test(@mime_type) then 'file-pdf-o'
			when /video/.test(@mime_type) then 'file-movie-o'
			when /audio/.test(@mime_type) then 'file-audio-o'
			when /zip|rar|tar/.test(@mime_type) then 'file-archive-o'
			else 'file-o'
	
	getTemplateKey: ()->
		return 'folder' if @isDirectory()
		switch 
			when /image/.test(@get('mime_type')) then 'image'
			when /video/.test(@get('mime_type')) then 'video'
			when /audio/.test(@get('mime_type')) then 'audio'
			when 'text/plain' == @get('mime_type') then 'text'
			else 'empty'

	renderPreview: ()->
		$('.content').html new AC.Views.FilePreview(model: @).el

	findFileByPath: (path)->
		founded= undefined
		_(@get('children').models).every (file)->
			if file.get('path').chomp("/") == path
				founded = file
				false
			else 
				founded = file.findFileByPath(path)
				if founded then false else true
		founded

	findParentByPath: (path)->
		self = @
		founded= undefined
		_(@get('children').models).every (file)->
			if file.get('path').chomp("/") == path
				founded = self
				false
			else 
				founded = file.findParentByPath(path)
				if founded then false else true
		if founded then founded else undefined