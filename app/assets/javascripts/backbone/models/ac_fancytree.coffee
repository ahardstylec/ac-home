class AC.Fancytree
	@dblclicked = false
	@home_options:
		init: (event, data)->
			data.tree.rootNode.getFirstChild().setExpanded(true)
	@setNodeSelected: (node, selected=true)->
		node.setSelected(selected)
	@getSelectedNodes: ()->
		AC.home_tree.getSelectedNodes();

	@clearSelection: ()->
		_(@getSelectedNodes).each (node)->
			node.setSelected(false)

	@options: (home=false)->
		options = 
			dblclick: (event, data)->
				AC.Fancytree.dblclicked=true
				setTimeout ()->
					AC.Fancytree.dblclicked=false
				, 500
				
			click: (event, data)->
				node = data.node
				if data.targetType == 'title' or data.targetType == 'icon'
					if event.ctrlKey
						if data.node.isSelected() == true
							AC.Fancytree.setNodeSelected(node, false)
						else
							AC.Fancytree.setNodeSelected(node)
					else
						_(data.node.tree.getSelectedNodes()).each (node)->
							AC.Fancytree.setNodeSelected(node, false)
						AC.Fancytree.setNodeSelected(node)
					setTimeout ()->
						if !AC.Fancytree.dblclicked
							node.data.renderPreview()
					, 200
			keydown: (event, data)->
				console.log event, data
				if event.which == 113
					AC.filesystem_content.rename data.node
			selectMode: 2
			extensions: ["dnd"]
			dnd: 
				preventVoidMoves: true 
				preventRecursiveMoves: true # Prevent dropping nodes on own descendants
				autoExpandMS: 200
				dragStart: (node, data)->
					if not data.node.isSelected()
						_(data.node.tree.getSelectedNodes()).each (node)->
							AC.Fancytree.setNodeSelected(node, false)
						AC.Fancytree.setNodeSelected(node)
					true
				dragEnter: (node, data)->
					if not node.folder then return false
					files = _(data.tree.getSelectedNodes()).map (node)->
						node.data.get('path')
					if (_(files).some (file)-> file == node.data.get('path'))
						return false
					true
				dragDrop: (node, data)->
					dest = if node.folder then node else node.parent
					nodes = data.tree.getSelectedNodes()
					AC.filesystem_content.move nodes, dest

		_.extend options, @home_options if home
		options

