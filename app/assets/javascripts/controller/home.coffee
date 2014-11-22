# $(document).ready ()->
# 	$('.attachment_index_link').on 'click', ()->
# 		bootbox.prompt title: "password", value: "", callback: (password)->
# 			AC.Ajax.post '/attachments/authorize', {password: password}, success: (response)->
# 				if response.success
# 					window.location= '/attachments/index'
# 				else
# 					AC.Alert.error "not authorized"
