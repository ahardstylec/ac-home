class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable

  has_many :attachments
  has_many :shared_folders, foreign_key: 'owner_id'
  has_many :friends_folders, foreign_key: 'friend_id', class_name: 'SharedFolder'

  after_create :create_data_folder


  def get_folders
    friendsfolders = self.friends_folders.map{|sf| AcFile.new(sf.path) }
    [data_folder] | friendsfolders.select do |sharedfolder|
      friendsfolders.reject{|sf| sf == sharedfolder || sf.include?(sharedfolder) }
    end
  end

  def create_data_folder
    FileUtils.mkdir_p data_path("first\ folder")
    FileUtils.cp File.join(Rails.root, "data", "templates", "readme"), data_path
  end

  def data_path sub_path=""
    File.join(File.join(Rails.root, "data", name), sub_path)
  end

  def data_folder
    return @data_folder if @data_folder
    @data_folder = AcFile.new(self.data_path)
    @data_folder
  end

  def share(file, friend, permission="read")
    file = file.is_a?(AcFile) ? file : AcFile.new(file)
    if self.data_folder.include?(file) || file.path == self.data_folder.path
      sf = SharedFolder.new(friend: friend, path: file.path, permission: permission)
      self.shared_folders<< sf
      sf.save
      sf
    else
      nil
    end
  end

  def can_change_file(file)
    spath = Pathname.new(self.data_path).realpath.to_s
    opath = Pathname.new(file).realpath.to_s
    !opath.gsub!(/^#{spath}/,'').nil?
  end

  def allowed_to_change_files(*files)
    !files.reject{|file| self.can_change_file(file) }.any?
  end

  def allowed_to_visit_files(*files)
    true
  end

  def to_json(*arguments)
    hash= {}
    hash[:name]= self.name
    hash[:username] = self.name
    hash[:id] = self.id
    hash[:shared_folders] =self.shared_folders
    hash[:friends_folders] =self.shared_folders
    hash.to_json
  end

  def admin?
    "#{self.role}" == 'admin'
  end
end
