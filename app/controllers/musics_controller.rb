class MusicsController < ApplicationController

  def index
    folders = current_user.get_folders
    @images = AC::FileUtilities.get_images folders
  end
end
