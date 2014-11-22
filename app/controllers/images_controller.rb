class ImagesController < ApplicationController

  def index
    folders = current_user.get_folders
    @images = AC::FileUtilities.get_images folders
  end

  def manipulate_image
    image = AC::FileUtilities::Image.new(params[:file])
    current_user.allowed_to_change_files(params[:file])
    success = case params[:action]
                when 'rotate_left' then image.rotate_left(); image.create_thumbnail(true); true
                when 'rotate_right' then image.rotate_right(); image.create_thumbnail(true); true
                else true
              end

    respond_to { |format|
      format.json { render body:  {success: success ? true : false}.to_json}
    }

  end

end
