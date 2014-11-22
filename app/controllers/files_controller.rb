class FilesController < ApplicationController
  def move
    files = params[:files]
    dest = Pathname.new(params[:dest])

    if allowed = current_user.allowed_to_change_files(dest, *files)
      files.each do |file|
        FileUtils.mv(file, dest)
      end
    end

    render json: {success: allowed ? true : false, error: allowed ? nil : "could not move. not allowed"}.to_json
  end

  def copy
    source = Pathname.new(params[:file])
    dest = Pathname.new(params[:dest])
    if current_user.allowed_to_change_files(dest, source)
      FileUtils.cp(source, dest)
      render json: {success: true}.to_json
    else
      render json: {success: false, error: "could not move. not allowed"}.to_json
    end
  end

  def share_with
    friends_User = User.find(params[:User_id])
    file = AcFile.new(params[:file])
    permission = params[:permission]
    if current_user.data_folder.include?(file)
      shared_folder= current_user.share(file, friends_User, permission)
      if shared_folder
        render json: {success: true, new_shared: shared_folder}.to_json
      else
        render json:{success: false, error: shared_folder.valid? ? shared_folder.errors : 'error in files:share_with'}.to_json
      end
    else
      render json:{success: true, error: 'not allowed to share file'}.to_json
    end
  end

  def delete
    files = [params[:files]].flatten
    begin
      raise "not allowed" unless current_user.allowed_to_change_files(*files)
      FileUtils.rm_rf files
      render json: {success: true}.to_json
    rescue
      render json: {success: false, error: e.message}.to_json
    end
  end

  def new_file
  end

  def rename
    new_filename = params[:filename]
    file = Pathname.new(params[:file])
    new_path = File.join(file.dirname, new_filename)
    begin
      raise "not allowed" unless current_user.allowed_to_change_files(file.to_s)
      FileUtils.mv file.to_s, new_path
      render json: {success: true, new_path: new_path}.to_json
    rescue Exception => e
      render json: {success: false, error: e.message}.to_json
    end
  end

  def download
    files_to_send = params[:files]
    filename = params[:filename]
    case params[:type]
      when 'tar', 'gz', 'bz2'
        compressed = params[:type] if params[:type] =~ /gz|bz2/
        begin
          zip_data = AC::FileUtilities.tar(files_to_send, filename, compressed, !!params[:download_type], params[:type])
          send_data(zip_data, File.basename(filename), AC::FileUtilities.get_mime_type(filename))
        rescue Exception => e
          puts e.message
          puts e.backtrace
          response status: 500
        end
      when 'zip'
        filepath= AC::FileUtilities.zip files_to_send, filename, !!params[:download_type]
        begin
          if filepath
            zip_data = File.read(filepath)
            send_data(zip_data, File.basename(filename), AC::FileUtilities.get_mime_type(filename))
          else
            raise "could not compress file"
          end
        rescue Exception => e
          response status: 500
        ensure
          if params[:download_type] == "temp" && filepath
            temp = Tempfile.open(File.basename(filepath))
            temp.unlink
          end
        end
      when 'file'
        send_file(filename, File.basename(filename), AC::FileUtilities.get_mime_type(filename))
    end
  end

  def upload
    file = params[:file]
    path = Pathname.new(params[:path])
    if current_user.allowed_to_change_files(path)

    else
      render status:  403
    end
  end

  def text_preview
    file = AcFile.new(params[:file])
    if current_user.allowed_to_visit_files(file)
      render json: {success: true, html: File.read(file.path)}.to_json
    else
      render json: {success: false, error: "not allowed to visit file #{file.path.to_s}"}.to_json
    end
  end

  def preview
    @file = Pathname.new(params[:file])
    @rendered_html= partial('/files/breadcrumb')
    if current_user.allowed_to_visit_files(@file)
      if !@file.directory?
        case AC::FileUtilities.get_mime_type(@file)
          when 'text/plain'
            @txt =File.read(@file)
            @rendered_html<< render_to_string(partial: '/files/text_preview')
          when nil

        end
      else
        @rendered_html << render_to_string(partial: '/files/folder_preview')
      end
    else
      @rendered_html= ""
    end
  end

  def show_image
    file = AcFile.new params[:file]
    if current_user.allowed_to_visit_files(file.path)
      # if Rails.end == :production
      #   unless 	file.thumb_path.exist?
      #     puts 'no thumb'
      #     image = AC::FileUtilities::Image.new(file)
      #     thumb_file =image.create_thumbnail()
      #     thumb_file=nil
      #     unless image.nil?
      #       image=nil
      #     end
      #     GC.start
      #   end
      #   # response.headers['X-Accel-Redirect'] = file.path.to_s.sub("#{Rails.root}",'')
      #   # response.headers['filename'] = file.basename.to_s
      #   # response.headers['Content-Type'] = AC::FileUtilities.get_mime_type(file.path.to_s)
      #   # response.headers['Content-Disposition'] = 'inline'
      #   # response.headers['Cache-Control'] = "public, max-age=180"
      #   # response
      # else
        image = AC::FileUtilities::Image.new(file)
        image.create_thumbnail()
        send_file(image.thumb_path, filename: file.basename.to_s, type: file.mime_type, disposition: :inline)
        image=nil
        GC.start
      # end
    else
      render status: 403
    end
  end

  def show_image_thumb
    file = AcFile.new(params[:file])
    # if ENV['RACK_ENV'] == 'production'
    #   unless file.thumb_path.exist?
    #     image = AC::FileUtilities::Image.new(file)
    #     thumb_file =image.create_thumbnail()
    #     thumb_file=nil
    #     unless image
    #       image = nil
    #     end
    #     GC.start
    #   end
    #   response.headers['X-Accel-Redirect'] = file.thumb_path.to_s.sub("#{Rails.root}",'')
    #   response.headers['filename'] = file.path.basename.to_s
    #   response.headers['Content-Type'] = AC::FileUtilities.get_mime_type(file.path.to_s)
    #   response.headers['Content-Disposition'] = 'inline'
    #   response.headers['Cache-Control'] = "public, max-age=180"
    #   response
    # else
      image = AC::FileUtilities::Image.new(file)
      thumb_file =image.create_thumbnail()
      thumb_file =nil
      image=nil
      GC.start
      send_file(image.thumb_path, filename:  file.basename.to_s, type: file.mime_type, disposition: :inline)
    # end
  end

  def stream_file

    file= AcFile.new(params[:file])

    headers 'Content-Type'=> file.mime_type
    headers "Content-Length" => file.size.to_s
    if current_user.allowed_to_visit_files(file.path)

      #
      # opened_file = File.open(file.path)
      #
      #   begin (chunk = opened_file.read(4*2024)) # Go and experiment with best buffer size for you
      #   response.stream.write chunk
      #   end while chunk.size == 4*2024
      #
      # opened_file.close
      # response.stream.close
      send_file(file.path, filename: file.basename.to_s, type: file.mime_type)
    else
      render status: 404
    end
  end

  def video_thumb
    movie_path = AcFile.new(params[:file])
    if movie_path.path.exist?
      thumb = AC::FileUtilities.thumb_of_video(movie_path.path.to_s)
      image_path = thumb ? thumb : "public/404-error.jpg"
    else
      image_path = "public/404-error.jpg"
    end
    begin
      send_file(image_path, filename: movie_path.basename, type: AC::FileUtilities.get_mime_type(image_path))
    ensure
      FileUtils.rm thumb rescue nil
      GC.start
    end
  end
end
