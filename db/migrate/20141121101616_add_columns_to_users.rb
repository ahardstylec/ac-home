class AddColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :role, :string
    add_column :users, :attachment_token, :string
    add_column :users, :first_name, :string
  end
end
