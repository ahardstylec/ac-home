class CreateAttachment < ActiveRecord::Migration
  def change
    create_table :attachments do |t|
      t.string :link
      t.string :embedded_html
      t.string :remote_url
    end

    add_attachment :attachments, :file
  end
end
