require 'pathname'
#require 'fileutils'
#require 'dm-serializer'

class SharedFolder < ActiveRecord::Base
  # Properties
  # property :path,             String
  # property :permission,       String
  # property :owner_id, Integer, :key => true
  # property :friend_id, Integer, :key => true

  belongs_to :owner, class_name: 'User', foreign_key: :owner_id
  belongs_to :friend, class_name: 'User', foreign_key: :friend_id

  # Validations
  validates_presence_of  :path, :owner, :friend, :permission
end
