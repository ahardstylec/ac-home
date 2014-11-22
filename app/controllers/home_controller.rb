class HomeController < ApplicationController

  before_filter do
    @file_hirarchy = current_user.get_folders
  end

  def index
  end

  def refresh_sidebar
     render json: @file_hirarchy.to_json
  end

end
