class AddAttachmentPhotoToAttendee < ActiveRecord::Migration
  def self.up
    add_column :attendees, :photo_file_name, :string
    add_column :attendees, :photo_content_type, :string
    add_column :attendees, :photo_file_size, :integer
    add_column :attendees, :photo_updated_at, :datetime
  end

  def self.down
    remove_column :attendees, :photo_file_name
    remove_column :attendees, :photo_content_type
    remove_column :attendees, :photo_file_size
    remove_column :attendees, :photo_updated_at
  end
end
