$.fn.extend toggleIcons: (icons)->
	@.each ()->
		el = @
		_(icons.split(' ')).each (icon)->
			$(el).toggleClass("fa-#{icon}")