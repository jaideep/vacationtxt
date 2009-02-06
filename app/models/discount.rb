require 'RMagick'
require 'ipipi'

class Discount < ActiveRecord::Base  
  include Ipipi::SmsSender
  DIRECTORY = "#{OUTPUT_DIRECTORY}/discounts"
  THUMB_MAX_SIZE = [110,110]
  
  belongs_to :map_item
  has_many :trips
  
  validates_presence_of :coupon_code
  validates_numericality_of :map_item_id, :priority
  
  after_save :process
  after_destroy :cleanup
  
  def name
    self.map_item.name
  end
  
  def phone
    self.map_item.phone
  end
  
  def address
    self.map_item.address
  end
  
  def price
    "N/A"
  end
  
  def reservable?
    false
  end
  
  def up_for_bid?
    false
  end
  
  def has_picture?
    false
  end
  
  def category
    self.map_item.category
  end
  
  def validate
    if (self.start_date > self.end_date)
      errors.add_to_base "Start date must not be later than end date"
    end
  end
  
  def file_data=(file_data)
    if file_data != ""
      @file_data = file_data
      write_attribute 'extension' ,file_data.original_filename.split('.' ).last.downcase      
    end
  end
  
  def url
    "/pics/discounts/#{path.split("/").last}"
  end

  def thumbnail_url
    "/pics/discounts/#{thumbnail_path.split("/").last}"
  end

  def path
    File.join(DIRECTORY, "#{self.id}-full.#{extension}" )
  end

  def thumbnail_path
    File.join(DIRECTORY, "#{self.id}-thumb.#{extension}" )
  end
  
  def send_as_sms(number)
    send_sms(number, "Ozarktxt coupon code: " + self.coupon_code)
  end
  
#######
private
#######

  def process
    if @file_data
      create_directory
      cleanup
      save_fullsize
      create_thumbnail
      @file_data = nil
    end
  end

  def save_fullsize
    File.open(path,'wb' ) do |file|
      file.puts @file_data.read
    end
  end

  def create_thumbnail
    img = Magick::Image.read(path).first
    thumbnail = img.thumbnail(*THUMB_MAX_SIZE)
    thumbnail.write thumbnail_path
  end
  
  def create_directory
    FileUtils.mkdir_p DIRECTORY
  end

  def cleanup
    Dir[File.join(DIRECTORY, "#{self.id}-*" )].each do |filename|
      File.unlink(filename) rescue nil
    end
  end
  

end
