class ViewHelper
	icon_tag: (icon, text="", classes=[], options)->
		classes = classes.split(' ') if _.isString(classes)
		classes_str = (_(classes).map (c)->  "fa-#{c}").join(" ")
		icon_options = (_(options).map (value, key, list)-> " #{key}=\"#{value}\"").join(' ')
		"<i class='fa fa-#{icon} #{classes_str}' #{icon_options}>#{text}</i>"

	link_to: (text, url, options)->
		link_options = (_(options).map (value, key, list)->	" #{key}=\"#{value}\"").join(' ')
		
		a = "<a href=\"#{url}\" #{link_options}>#{text}</i>"

window.ViewHelper = ViewHelper