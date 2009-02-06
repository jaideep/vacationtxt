class Image < ActiveRecord::Base
  belongs_to :user
  belongs_to :listing
  
  has_attachment :storage => :file_system,
                 :path_prefix => 'public/uploads',
                 :content_type => :image,
                 :size => 0.megabyte..4.megabyte,
                 :resize_to => '600x600>',
                 :thumbnails => {:thumb => '110x110>', :small => '30x30>'}

  validates_as_attachment
end
