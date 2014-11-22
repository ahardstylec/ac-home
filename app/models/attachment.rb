require 'pathname'
#require 'dm-serializer'
require 'open-uri'

class Attachment < ActiveRecord::Base
  has_attached_file :file,
              path: "#{Rails.root}/data/attachments/:class/:attachment/:style/:filename",
              url: "data/attachments/:class/:attachment/:style/:filename",
              :styles => {:thumb => "300x300>"}

  before_file_post_process :allow_only_images


  # # Properties
  # property :link,               String
  # property :embedded_html,      String
  # property :remote_url,         String

  belongs_to :User


  def create_thumb_if_not_exist
      if !File.exist?(self.path(:thumb)) && File.exist?(self.path)
        AC::FileUtilities.thumb_of_video(self.file.path, self.thumb_path)
    end
  end

  def thumb_path
    if !allow_only_images
      new_thumb_path = self.path(:thumb).split('.')[0..-2].join('.')+".png"
    else
      self.path(:thumb)
    end 
  end

  def allow_only_images
    if !(file.content_type =~ %r{^(image|(x-)?application)/(x-png|pjpeg|jpeg|jpg|png|gif)$})
      return false
    else
      return true
    end
  end

  def thumb_url
    Rails.application.routes.url_helpers.attachments_show_thumb_path(self.id)
    # AcHome::App.url(:attachments, :show_thumb, id: self.id)
  end

  def original_url
    Rails.application.routes.url_helpers.attachments_show_image_path(self.id)
    # AcHome::App.url(:attachments, :show_image, id: self.id)
  end

  def embedded_html?
    self.embedded_html && !self.embedded_html.empty?
  end

  def url(style=nil)
    if style
      self.file.url(style.to_sym)
    else
      self.file.url
    end
  end

  def path(style=nil)
    if style
      self.file.path(style.to_sym)
    else
      self.file.path
    end
  end

  def create_file_from_remote_url(rurl=nil)
    rurl = self.remote_url if !rurl && self.remote_url
    if rurl
      filename = rurl.split('/').last
      fileending = filename.split('.').last
      filename_widthout_ending = (filename.split('.')[0..-2] || "").join('.')
      tempfile = Tempfile.new([filename_widthout_ending, ".#{fileending}"])
      tempfile.write(Curl.get(rurl).body_str.force_encoding('utf-8'))
      self.file_file_name= filename
      self.file = tempfile
      self.remote_url = rurl
    end
    rescue Exception => e
      nil# catch url errors with validations instead of exceptions (Errno::ENOENT, OpenURI::HTTPError, etc...)
    else
      true
  end
end