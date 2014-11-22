class AC.Views.ImageView extends Backbone.View

	templates:
		text: JST['templates/image_view']

	initialize: (options)->
		@view_helper = new ViewHelper()
		@render()

	fullscreen_init: ()->
		$('.image img').fullscreenslides(); 

		fullscreen_container = $('#fullscreenSlideshowContainer')


		fullscreen_container.bind("init", ()->
			fullscreen_container
				.append('<div class="ui" id="fs-close">&times;</div>')
				.append('<div class="ui" id="fs-loader"><i class="fa fa-spin fa-spinner"></i> Loading...</div>')
				.append('<div class="ui" id="fs-prev">&lt;</div>')
				.append('<div class="ui" id="fs-next">&gt;</div>')
				.append('<div class="ui" id="fs-caption"><span></span></div>');

			$('#fs-prev').click ()->  fullscreen_container.trigger("prevSlide");
			$('#fs-next').click ()->  fullscreen_container.trigger("nextSlide");
			$('#fs-close').click ()-> fullscreen_container.trigger("close");
		)
		.bind("startLoading", ()-> $('#fs-loader').show() )
		.bind("stopLoading", ()->  $('#fs-loader').hide() )
		.bind("endOfSlide", (event, slide)-> $('#fs-caption').hide() )
		.bind("startOfSlide", (event, slide)->
			$('#fs-caption span').text(slide.title)
			$('#fs-caption').show()
		)


	render: ()->
		$(@el).html _(@model.children).map (file, iterator)=>
			path = "/files/show_image_thumb?file=#{file.path}"
			$("<div>").addClass('image pull-left')
				.append($(@view_helper.link_to("<img src='#{path}' width='150' height='150'>", "/files/show_image?file=#{file.path}", rel: "gallery-1", title: file.basename)))
				.append($('<div class="caption">').html(file.basename))
		$('.thumb_images').empty().append($(@el))
		$('.image img').fullscreenslides(); 
		# @fullscreen_init()
		@el