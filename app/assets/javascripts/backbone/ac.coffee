window.AC = 
	version: "1.0"
	Collections: {}
	Models: {}
	Views: {}
	filesystem: undefined
	view_helper: undefined
	current_user: undefined
	preview_content: undefined
	Users: undefined
	file_view_stack: []
	file_stack_pointer: 0

	Filesystem:
		init_filesystem_tree: ()->
			$('#filesystem_friends > ul').empty()
			$('#homefilesystem > ul').empty()

			_(AC.filesystem_content.models).each (file)->
				if file.get('basename') == AC.current_user.get('username')
					filesystem_home= new AC.Views.File(model: file).el
					$('#homefilesystem > ul').html filesystem_home
				else	
					$('#filesystem_friends > ul').append new AC.Views.File(model: file).el

			$('#homefilesystem').fancytree(AC.Fancytree.options(true))
			AC.home_tree = $("#homefilesystem").fancytree("getTree");
			$('#filesystem_friends').fancytree(AC.Fancytree.options());
			AC.Menu.append_menu('homefilesystem', 'span.fancytree-title')
			AC.Menu.append_menu('filesystem_friends', 'span.fancytree-title')
		init_content: (Currentfile)->
			home_folder = AC.filesystem_content.findWhere(basename: AC.current_user.get('username'))
			if _.isUndefined(Currentfile)
			 	Currentfile = home_folder
			$('.content').html new AC.Views.FilePreview(model: Currentfile).el

		init: (refresh=false)->
			AC.current_user = new AC.Models.File($('body').data('current_user'))
			AC.view_helper = new ViewHelper()
			AC.filesystem_content = new AC.Collections.Files($('.filesystem_content').data('filesystem'))
			AC.Users = new AC.Collections.Users($('body').data('Users'))
			
			@init_filesystem_tree()
			@init_content(if refresh then AC.filesystem_content.getCurrent() else undefined)
