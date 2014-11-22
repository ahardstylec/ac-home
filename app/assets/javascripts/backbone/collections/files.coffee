class AC.Collections.Files extends Backbone.Collection
	model: AC.Models.File
	current: null
	findFileByPath: (path)->
		res = @findWhere(path: path)
		if res
			res
		else
			founded = undefined
			_(@models).every (file)->
				if file.get('path').chomp("/") == path
					founded = file
					true
				else 
					founded = file.findFileByPath(path)
					if founded then false else true
			founded

	getCollectionOfParent: (file)->
		path = file.get('path')
		res = @findWhere(path: path)
		if res
			return @
		else
			parent = @parent(file)
			if parent then parent.get('children') else undefined

	getCurrent: ()->
		@current

	setCurrent: (file)->
		@current = file

	next: ()->
		parent_collection = @getCollectionOfParent(@getCurrent())
		el = parent_collection.at(parent_collection.indexOf(@getCurrent()) + 1)
		if el 
			el
		else
			return null

	prev: ()->
		parent_collection = @getCollectionOfParent(@getCurrent())
		el = parent_collection.at(parent_collection.indexOf(@getCurrent()) - 1)
		if el 
			el
		else
			return null

	parent: (file)->
		path = file.get('path')
		res = @findWhere(path: path)
		if res
			return @
		else
			founded = undefined
			_(@models).every (file)->
				founded = file.findParentByPath(path)
				if founded then false else true
			return founded

	isThereNext: ()->
		parent_collection = @getCollectionOfParent(@getCurrent())
		!_.isUndefined(parent_collection.at(parent_collection.indexOf(@getCurrent()) + 1))

	isTherePrev: ()->
		parent_collection = @getCollectionOfParent(@getCurrent())
		!_.isUndefined(parent_collection.at(parent_collection.indexOf(@getCurrent()) - 1))

	isThereUp: ()->
		parent_collection = @getCollectionOfParent(@getCurrent())
		_.isUndefined(AC.filesystem_content.findWhere(path: @getCurrent().get('path')))


	delete: (node)->
		if node.folder
			title = "Ordner wirklich Löschen?"
		else
			title= "Datei wirklich löschen?"
		bootbox.confirm title, (res)->
			if res
				AC.Ajax.post '/files/delete', {files: [node.data.get('path')]}, success: (response)->
					if response.success
						node.remove()
					else
						AC.Alert.error response.error

	rename: (node)->
		# modal = JST['templates/modal']({title: "Rename #{node.title}"});
		if node.folder
			title = "Ordner umbenennen"
		else
			title= "Datei Umbenennen"
		bootbox.prompt title: title, value: node.title, callback: (new_filename)->
			AC.Ajax.post '/files/rename', {file: node.data.get('path'), filename: new_filename}, success: (res)->
				if res.success
					node.setTitle new_filename
					node.data.set('path', res.new_path)
					node.render()
				else
					AC.Alert.error res.error

	download: (path, type)->
		filename = path
		filename= @set_filename_from_type(filename, type)
		$.fileDownload '/files/download', data: {files: [path], filename: filename, type:  type, download_type: 'temp'}, httpMethod:'post'

	set_filename_from_type: (filename, type)->
		filetype = switch type
			when "tar" then 'tar'
			when "gz" then 'tar.gz'
			when "bz2" then 'tar.bz2'
			when "zip" then 'zip'
			when "file" then 'file'
		filename= "#{filename}.#{filetype}"	if filetype != "file"
		filename

	copy: (nodes, dest)->
		files = _(nodes).map (node)->
			node.data.get('path')
		AC.Ajax.post '/files/move', {files: files, dest: dest.data.get('path')}, success: (data)->
			if data.success
				_(nodes).each (node_to_move)->
					# cloned = node_to_move.clone
					# cloned.moveTo(dest, data.hitMode)
			else
				alert_view = AC.Alert.error(data.error)
	move: (nodes, dest)->
		files = _(nodes).map (node)->
			node.data.get('path')
		AC.Ajax.post '/files/move', {files: files, dest: dest.data.get('path')}, success: (data)->
			if data.success
				_(nodes).each (node_to_move)->
					node_to_move.moveTo dest, 'child', ()->
			else
				alert_view = AC.Alert.error(data.error)