require 'yahoo/geocode'
require 'RMagick'

class Listing < ActiveRecord::Base  
  DIRECTORY = OUTPUT_DIRECTORY
  THUMB_MAX_SIZE = [110,110]
  GEOCODER = Yahoo::Geocode.new 'fkrK3rvV34EdrhpBOjZvecURLRbmnM0JFY9xahhgCUZjkVp1T7IQw6t5C7vtxtuDNDWu'
  PRICING_OPTIONS = ['FIXED','BID']
  REGIONS = ["North Shore","Horseshoe Bend","Lake Ozark","Osage Beach","West Side"]
  
  after_save :process
  after_destroy :cleanup
  
  belongs_to :user
  has_many :rentals
  has_many :listing_units
  has_many :images
  
  validates_presence_of :user_id, :street_address, :city, :state, :zip, :description, :strong_name, :pricing_type
  validates_uniqueness_of :strong_name
  validates_inclusion_of :pricing_type, :in => PRICING_OPTIONS, :message=> "should be a valid pricing option"
  validates_inclusion_of :region,:in=>REGIONS,:message=>"Must be a valid lake region"
  
  attr_reader :address_array
  
  def self.search(search_hash)
    region_condition = (search_hash[:region] == "ALL") ? "" : "and region = '#{search_hash[:region]}'"
    sql = "id in (select listing_id from listing_units where bed_count >= ? and max_people >= ? and price <= ? #{region_condition} and active = ?)"
    self.find(:all,:conditions=>[sql,search_hash[:bed_count],search_hash[:max_people],search_hash[:max_price],true]) 
  end
  
  def get_selected_unit(unit_id)
    if unit_id
      id = unit_id.to_i
      self.listing_units.each do |lu|
        return lu if lu.id == id
      end
    end
    return self.listing_units[0]
  end
  
  def initialize(attributes=nil)
    super(attributes)
    
  end
  
  def validate
    begin
      load_geocoordinates if errors.size == 0 and (read_attribute(:lat).nil? or read_attribute(:long).nil?)
    rescue OzarksException => e
      if e.message == "NO_MATCH"
        errors.add_to_base("Could not find coordinates for this address, or any similar addresses.  Please verify address.")        
      else
        message = "Could not find coordinates for this address.  Please use one of the following addresses: <br/>"
        @address_array.each {|address| message = message + "<b>#{address}</b> <br/>"}
        errors.add_to_base(message)
      end
    rescue 
      errors.add_to_base("Geocoding service may be down right now.  Please try again later")
    end    
  end
  
  def name
    self.strong_name
  end
  
  def phone
    self.number
  end
  
  def address
    "#{self.street_address}, zip:#{self.zip}"
  end
  
  def reservable?
    true
  end
  
  def up_for_bid?
    self.pricing_type == "BID"
  end
  
  def has_picture?
    true
  end
  
  def number
    self.user.full_number
  end
  
  def send_owner_threaded_message(trip_id,msg)
    self.user.send_threaded_message(trip_id,msg,"OWNER")
  end
  
  def cancel_trip(trip_id,msg)
    self.user.cancel_threaded_message(trip_id,msg)
  end
  
  def file_data=(file_data)
    if file_data != ""
      @file_data = file_data
      write_attribute 'extension' ,file_data.original_filename.split('.' ).last.downcase      
    end
  end
  
  def url
    "/pics/#{path.split("/").last}"
  end

  def thumbnail_url
    "/pics/#{thumbnail_path.split("/").last}"
  end

  def path
    File.join(DIRECTORY, "#{self.id}-full.#{extension}" )
  end

  def thumbnail_path
    File.join(DIRECTORY, "#{self.id}-thumb.#{extension}" )
  end
  
  def belongs_to(usr)
    user() == usr    
  end
  
  def gmap_html   
    read_attribute(:description)
  end
  
  def owner
    user()
  end
  
  def is_fixed_price
    read_attribute(:pricing_type) == PRICING_OPTIONS[0]
  end
  
  def is_up_for_bid
    read_attribute(:pricing_type) == PRICING_OPTIONS[1]
  end
  
  def self.pricing_types
    PRICING_OPTIONS
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
  
  def load_geocoordinates
    locations = GEOCODER.locate(read_attribute(:street_address) + "," + 
                                   read_attribute(:city) + "," + 
                                   read_attribute(:state) + ", " + 
                                   read_attribute(:zip))
                                   
    if locations.size > 1
      @address_array = Array.new
      index = 0
      while index < locations.size
        @address_array[index] = locations[index].address
        index = index + 1
      end
      
      raise OzarksException, "MULTIPLE_RESULTS"
    end
    
    if locations.first.precision != "address"
      raise OzarksException, "NO_MATCH"
    end
    
    write_attribute :lat,locations.first.latitude
    write_attribute :long,locations.first.longitude
  end
  
  private 
  def set_if_nil(attr,value)
    write_attribute(attr,value) if read_attribute(attr).nil?
  end
end
