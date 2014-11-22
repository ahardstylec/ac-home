require 'pathname'
require 'mime/types'
require 'rubygems/package'
require 'zip'
require 'zlib'
require 'bzip2'
require 'streamio-ffmpeg'
require 'rubygems'
require 'RMagick'

module AC
	class FileUtilities

		class Image

			attr_accessor :path, :image, :thumb_path, :thumb_file

			def initialize(file)
				self.path = file.is_a?(String) ? Pathname.new(file) : file.path
				self.image = Magick::Image.read(self.path.to_s).first
				self.thumb_path = Pathname.new(self.path.to_s.sub(/data/, 'thumbnails'))
				self.thumb_file= nil
				self
			end

			def rotate_left
				self.image.rotate(-90).write(self.path.to_s)
			end

			def rotate_right
				self.image.rotate(90).write(self.path.to_s)
			end

			def to_blob
				self.image.to_blob
			end

			def create_thumbnail(force=false)
				FileUtils.mkdir_p(self.thumb_path.dirname) unless self.thumb_path.dirname.exist?
				if !self.thumb_path.exist? || force
					
					self.image.resize_to_fill(150,150).write(self.thumb_path.to_s)
					self.thumb_file = self.image
				else 
					self.thumb_file = Magick::Image.read(self.thumb_path.to_s).first
				end
				self
			end
		end

		def self.get_images(files)
			images =[]
			files.each do |file|
				images |= self.get_images(file.children)
				if file.mime_type =~ /image/
					images << AcFile.new(file.dirname)
					break
				end
			end
			images
		end

		def self.thumb_of_video(path, new_path=nil)
			unless new_path
				tempfile = Tempfile.new ["movie", ".png"]
				new_path = tempfile.path
				tempfile.unlink
			end
			res = `ffmpeg -i #{path} -ss 0:00:01.000  -vframes 1 #{new_path}`
			if res 
				new_path
			else
				nil
			end
		end

		def self.tree_for_path path_to_dir=nil
			name =path_to_dir.gsub(/#{Rails.root}\/|data\//,'')
		    rootfile = AcFile.new(Pathname(path_to_dir))
		    # path = Pathname(data_path(sub_path))
		    search_path = Proc.new do |root|
		    	children = []
		      	root.path.children.sort{|a,b| a.directory? ^ b.directory? ? (a.directory? ? -1 : 1) : (a.basename.to_s.downcase <=> b.basename.to_s.downcase) }.each do |newfile|
		      		sub_file= AcFile.new newfile
					sub_file.children = search_path.call(sub_file) if sub_file.directory?
			    	children.push sub_file
				end
				children
			end
			rootfile.children= search_path.call(rootfile)
			rootfile
  		end

		def self.zip(files=[], filename="unknown.zip", temp=false)
			if temp
				file = Tempfile.new(File.basename(filename))
				Zip::OutputStream.open(file) { |zos| } rescue nil
			else
				if File.exist(filename)
					File.truncate(filename)
				else
					FileUtils.touch(filename)
				end
				file= File.open(filename)
			end
			begin
				#Add files to the zip file as usual
				Zip::File.open(file.path, Zip::File::CREATE) do |zip|
					files.each do |sub_file|
						file_pathname = Pathname.new(sub_file)
						zip.add(file_pathname.basename, file_pathname.to_s)
					end
				end
			ensure
				file.close
			end
			file.path
		end

		def self.unzip(zip, unzip_dir, remove_after = false)
			Zip::ZipFile.open(zip) do |zip_file|
				zip_file.each do |f|
					f_path=File.join(unzip_dir, f.name)
					FileUtils.mkdir_p(File.dirname(f_path))
					zip_file.extract(f, f_path) unless File.exist?(f_path)
				end
			end
			FileUtils.rm(zip) if remove_after
		end

		def self.tar(files, filename, compression=false, temp=false, type="tar")
			tarfile = StringIO.new("")
			files_paths = files.map do |file|
				File.directory?(file) ? Dir[File.join(file, "**/*")] : file
			end.flatten
			begin
				Gem::Package::TarWriter.new(tarfile) do |tar|
					files_paths.each do |file|
						mode = File.stat(file).mode
						relative_file = (file.sub /^#{Regexp::escape File.dirname files.first}?/, '').chomp("/")
						if File.directory?(file)
							tar.mkdir relative_file, mode
						else
							tar.add_file relative_file, mode do |tf|
								File.open(file, "rb") { |f| tf.write f.read }
							end
						end
					end
				end
			rescue Exception => e
				raise e.message
				nil
			ensure
				tarfile.rewind
			end
			tarfile = case compression
				when 'gz' then gzip(tarfile)
				when 'bz2' then bzip(tarfile)
				else tarfile
			end
			tarfile.string
		end

		def self.bzip(tarfile)
			gz = StringIO.new("")
			gz.write Bzip2.compress(tarfile.string)
			gz.close # this is necessary!
			# z was closed to write the gzip footer, so
			# now we need a new StringIO
			StringIO.new gz.string
		end

	 	def self.gzip(tarfile)
			gz = StringIO.new("")
			z = Zlib::GzipWriter.new(gz)
			z.write tarfile.string
			z.close # this is necessary!
			# z was closed to write the gzip footer, so
			# now we need a new StringIO
			StringIO.new gz.string
		end

		
  		def self.get_mime_type(file_path)
			type = MIME::Types.type_for(file_path)
			type = type.length > 1 ? type[2].to_s : type.first.to_s
			type.empty? ? "text/plain" : type
  		end

  		def self.real_size(file)
  			real_size = 0.0
  			if file.directory? 
  				file.children.each do |sub_file|
  					real_size+= (sub_file.directory? ? real_size(sub_file) : sub_file.size) if !sub_file.symlink?
				end 
			else
				real_size+= file.size
			end
			real_size
  		end

  		def self.real_size_to_s(file)
  			size =real_size(file)
  			case size
	  			when 0.0..1023.9
	  				"%.1f B" % size.to_s
	  			when 1024.0..1048575.9
	  				"%.1f KB" % (size/1024.0).to_s
	  			when 1048576.0..1073741823.9
	  				"%.1f MB" % (size/1048576.0).to_s
	  			when 1073741824.0..1099511627775.9
	  				"%.1f GB" % (size/1073741824).to_s
	  			else
  					"%.1f TB" % (size/1099511627776.0).to_s
			end	
  		end

  		def self.icon_for_file(file)
  			return 'folder' if file.directory?
  			case get_mime_type(file)
  				when 'text/plain'
  					'file-text'
  				when /image\//
  					'file-image-o'
  				when /pdf/
  					'file-pdf-o'
  				else
  					'file-o'
  			end
  		end
	end
end	