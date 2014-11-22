class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  include ApplicationHelper

  alias_method :pat, :t
  protect_from_forgery with: :exception
  layout :set_layout
  before_filter :authenticate_user!
  #alias :pat :trans

  def set_layout
    current_user ? "application" : "sessions"
  end

end

module ActionView::Helpers
  alias_method :pat, :t
end
