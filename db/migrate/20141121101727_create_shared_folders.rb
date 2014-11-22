class CreateSharedFolders < ActiveRecord::Migration
  def change
    create_table :shared_folders do |t|
      t.integer :owner_id
      t.integer :friend_id
      t.string :permission
      t.string :path
    end
  end
end
