String.prototype.chomp = (char="")->
	last_char = char[char.length-1]
	if last_char
		re = new RegExp("(\n|\r|#{last_char})+$")
	else
		re = new RegExp("(\n|\r)+$")
	@replace(re, '')