download_folder= (type, node) ->
	(event, ui) ->
		AC.filesystem_content.download (node.data.path || $.ui.fancytree.getNode(ui.target).data.path), type

buttons_file = (node)=>
				_.union([{
            title: "Copy", uiIcon: "ui-icon-copy", action: (event,ui)->
              AC.Menu.clipboard_event = 'copy'
              AC.Menu.clipboard = node.tree.getSelectedNodes()
            },
				  { title: "Cut", uiIcon: "ui-icon-scissors", action: (event,ui)->
              AC.Menu.clipboard_event = 'cut'
              AC.Menu.clipboard = node.tree.getSelectedNodes()
          },
				  { title: "Paste", cmd: 'paste', uiIcon: "ui-icon-clipboard", disabled: true, action: (event,ui)->
              if AC.Menu.clipboard_event == 'copy'
                AC.filesystem_content.copy AC.Menu.clipboard, node
              else if AC.Menu.clipboard_event == 'cut'
                AC.filesystem_content.move AC.Menu.clipboard, node
          },
				  { title: "Rename", uiIcon: "ui-icon-pencil", cmd: 'rename', action: (event,ui)->
				        AC.filesystem_content.rename node
          },
				  {title: "Delete", cmd: "delete", uiIcon: "ui-icon-trash", action: (event,ui)->
				      AC.filesystem_content.delete node
          },
				  { title: "Download", cmd: 'download', uiIcon: "ui-icon-arrowthickstop-1-s", action: download_folder('file', node)}
				  ], share_buttons(node))

download_folder_buttons = (node)=>
				_.union([{title: "Copy", uiIcon: "ui-icon-copy", action: (event,ui)-> 
					AC.Menu.clipboard_event = 'copy'
					AC.Menu.clipboard = [node.tree.getSelectedNodes()]}
				{title: "Cut", uiIcon: "ui-icon-scissors", action: (event,ui)->
					AC.Menu.clipboard_event = 'cut'
					AC.Menu.clipboard = [node.tree.getSelectedNodes()]}
				{title: "Paste", cmd: 'paste', uiIcon: "ui-icon-clipboard", disabled: true, action: (event,ui)->
				    if AC.Menu.clipboard_event == 'copy'
				    	AC.filesystem_content.copy AC.Menu.clipboard, node
			    	else if AC.Menu.clipboard_event == 'cut'
			    		AC.filesystem_content.move AC.Menu.clipboard, node
				    }
				{title: "Rename", uiIcon: "ui-icon-pencil", cmd: 'rename', action: (event,ui)->
				    AC.filesystem_content.rename node }
				{title: "Delete", cmd: "delete", uiIcon: "ui-icon-trash", action: (event,ui)->
				    AC.filesystem_content.delete node }
				{title: "Download", cmd: 'download', uiIcon: "ui-icon-arrowthickstop-1-s", children: [
					{title: "zip", uiIcon: 'ui-icon-arrowthickstop-1-s', action: download_folder("zip", node)}
					{title: "tar", uiIcon: 'ui-icon-arrowthickstop-1-s', action: download_folder('tar', node)}
					{title: "tar.gz", uiIcon: 'ui-icon-arrowthickstop-1-s', action: download_folder("gz", node)}
					{title: "tar.bz2", uiIcon: 'ui-icon-arrowthickstop-1-s', action: download_folder("bz2", node)}
				]}
				],share_buttons(node))

share_action = (User)->
		(event, ui)-> 
			node= $.ui.fancytree.getNode ui.target 
			node.data.share_with(User)

share_buttons= (node)=>
	share_children = AC.Users.without(AC.Users.findWhere({username: AC.current_user.get('username')})).map (a)->
		{title: a.get('username'), uiIcon: "ui-icon-arrowreturnthick-1-e", action: share_action(a)}
	[{title: "share", uiIcon: "ui-icon-arrowreturnthick-1-e", cmd: 'share', children: share_children}]

class AC.Menu
	@clipboard: []
	@clipboard_event: undefined
	@append_menu: (id, delegate)->
		$("##{id}").contextmenu
			delegate: delegate
			menu: []
			beforeOpen: (event, ui)->
				rename_flag =true
				node = $.ui.fancytree.getNode ui.target 
				node.setFocus();
				selected_nodes = node.tree.getSelectedNodes()	



				if node.folder
					$("##{id}").contextmenu "replaceMenu", download_folder_buttons(node)
				else
					$("##{id}").contextmenu "replaceMenu", buttons_file(node)

				if !_.isEmpty(AC.Menu.clipboard)
					$("##{id}").contextmenu 'enableEntry', 'paste', true
				else
					$("##{id}").contextmenu 'enableEntry', 'paste', false

				if selected_nodes.length > 1
					if not _.contains(selected_nodes, node) and not event.ctrKey
						AC.Fancytree.clearSelection()
					AC.Fancytree.setNodeSelected(node)
					$("##{id}").contextmenu 'enableEntry', 'rename', false
				else
					if not event.ctrKey
						AC.Fancytree.clearSelection()
					AC.Fancytree.setNodeSelected(node)
					$("##{id}").contextmenu 'enableEntry', 'rename', true