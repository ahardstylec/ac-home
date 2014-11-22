require 'mime/types'
require 'pathname'


class AcFile
	attr_accessor :directory, :path, :basename, :dirname, :children, :mime_type, :size, :ctime, :mtime, :thumb_path

	def self.get_mime_type(file)
		type = MIME::Types.type_for(file.path.to_s)
		type = type.length > 1 ? type[2].to_s : type.first.to_s
		type.empty? ? "text/plain" : type
	end

	def include?(file)
		self.children.select{|c| c.path == file.path || c.include?(file)}.any?
	end

	
	def initialize(pathname)
		self.path = path.is_a?(Pathname) ? pathname : Pathname.new(pathname)
		self.thumb_path = Pathname.new( self.path.to_s.sub(/data/, 'thumbnails') )
		self.directory = self.path.directory?
		self.basename = self.path.basename.to_s
		self.dirname = self.path.dirname.to_s
		self.children = self.directory? ? search_for_chilren : []
		self.mime_type = self.class.get_mime_type(self)
		self.ctime = self.path.ctime.strftime("%d.%m.%C %H:%M") if self.path.exist?
		self.mtime = self.path.mtime.strftime("%d.%m.%C %H:%M") if self.path.exist?
		self.size = real_size  if self.path.exist?
	end

	def images
		self.children.select do |file|
			file.mime_type =~ /image/
		end
	end

	def to_json(only_images=false)
		to_hash(only_images).to_json
	end

	def to_hash(only_images=false)
		hash= {}
		hash[:children] = only_images==true ? self.images.map{|i| i.to_hash} : self.children.map{|c| c.to_hash}
		hash[:basename] = self.basename
		hash[:dirname] = self.dirname
		hash[:size] = self.size
		hash[:size_as_string] = self.size_to_s
		hash[:path]= self.path.to_s.chomp("/")
		hash[:mime_type]= self.mime_type
		hash[:directory]= self.directory
		hash[:ctime]= self.path.ctime.strftime("%d.%m.%C %H:%M")
		hash[:mtime]= self.path.mtime.strftime("%d.%m.%C %H:%M")
		hash
	end

	def search_for_chilren
		self.children = []
      	self.path.children.sort{|a,b| a.directory? ^ b.directory? ? (a.directory? ? -1 : 1) : (a.basename.to_s.downcase <=> b.basename.to_s.downcase) }.each do |newfile|
	    	self.children.push AcFile.new newfile
		end
		children
	end


	def real_size
		real_size = 0.0
		if self.directory? 
			self.children.each do |child|
				real_size+= (child.directory? ? child.real_size : child.path.size) if !child.path.symlink?
			end 
		else
			real_size+= self.path.size
		end
		real_size
	end


	def size_to_s
		case self.size
  			when 0.0..1023.9
  				"%.1f B" % self.size.to_s
  			when 1024.0..1048575.9
  				"%.1f KB" % (self.size/1024.0).to_s
  			when 1048576.0..1073741823.9
  				"%.1f MB" % (self.size/1048576.0).to_s
  			when 1073741824.0..1099511627775.9
  				"%.1f GB" % (self.size/1073741824).to_s
  			else
				"%.1f TB" % (self.size/1099511627776.0).to_s
		end	
	end

	def directory?
		self.directory == true
	end
end