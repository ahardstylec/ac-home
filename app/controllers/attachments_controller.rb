class AttachmentsController < ApplicationController
  # match  '/attachments/:page'

  def index
    page = params[:page] || 1
    @attachments = current_user.attachments.page(page).per(5)
  end

  def authorize
    if  current_user.has_password?(params[:password])
      cookies['attachment_token'] ={ value: current_user.attachment_token, expires: 3.hours.from_now }
    else
      render status: 403, body: "not Authorized"
    end
  end

  def create
    @attachment = Attachment.new(params[:attachment].merge(User_id: current_user.id))
    @attachment.create_file_from_remote_url
    if @attachment.save
      @attachment.create_thumb_if_not_exist
      render json: {success: true, html: partial('/attachments/attachment', locals: {attachment: @attachment})}.to_json
    else
      render json: {success: false, error: pat(:create_error, :model => 'attachment')}.to_json
    end
  end

  def update
    @attachment = Attachment.find(params[:id])
    if @attachment && @attachment.User_id == current_user.id
      if @attachment.update(params[:User])
        render json: {success: true, html: partial('attachments/attachment', locals: {attachment: @attachment})}.to_json
      else
        render json: {success: false, error: pat(:update_error, :model => 'attachment')}.to_json
      end
    else
      render json: {success: false, error:  pat(:update_warning, :model => 'attachment', :id => "#{params[:id]}")}.to_json
    end
  end

  def destroy
    attachment = Attachment.find(params[:id])
    if attachment && attachment.User_id == current_user.id
      if attachment.destroy
        render json: {success: true}.to_json
      else
        render json: {success: false, error: pat(:delete_error, :model => 'attachment')}.to_json
      end
    else
      render json: {success: false, error: pat(:delete_warning, :model => 'attachment', :id => "#{params[:id]}")}.to_json, status: 404
    end
  end

  def show
    @attachment = Attachment.find(params[:id])
    unless @attachment.User_id == current_user.id
      render status: 403
    end
  end

  #match '/attachments/show_image/:id/show_image.gif
  def show_image
    @attachment = Attachment.find(params[:id])
    file = AcFile.new @attachment.path
    if file.path.exist? && @attachment.User_id == current_user.id
      # if Rails.env == 'production'
      #   response.headers['X-Accel-Redirect'] = file.path.to_s.sub("#{Rails.root}",'')
      #   response.headers['filename'] = file.basename.to_s
      #   response.headers['Content-Type'] = AC::FileUtilities.get_mime_type(file.path.to_s)
      #   response.headers['Content-Disposition'] = 'inline'
      #   response.headers['Cache-Control'] = "public, max-age=180"
      #   response
      # else
        # send_data(File.read(file.path), file.basename.to_s, file.mime_type)
        send_file file.path, filename: file.basename.to_s, type: file.mime_type, disposition: :'inline'
      # end
    else
      render status: 404
    end
  end

  def show_thumb
    @attachment = Attachment.find(params[:id])
    file = AcFile.new @attachment.thumb_path
    if file.path.exist? && @attachment.User_id == current_user.id
      # if Rails.env == ''
      #   response.headers['X-Accel-Redirect'] = file.path.to_s.sub("#{Rails.root}",'')
      #   response.headers['filename'] = file.basename.to_s
      #   response.headers['Content-Type'] = file.mime_type
      #   response.headers['Content-Disposition'] = 'inline'
      #   response.headers['Cache-Control'] = "public, max-age=180"
      #   response
      # else
        send_file file.path, filename: file.basename.to_s, type: file.mime_type, disposition: :'inline'
      # end
    else
      render status: 404
    end

  end

end
