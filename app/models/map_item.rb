require 'yahoo/geocode'
require 'csv'

class MapItem < ActiveRecord::Base
   
   CATEGORY_OPTIONS = ['LODGING','FOOD','NIGHTLIFE','CHILDREN','SHOPPING','OUTDOOR','TRANSPORTATION','TOURS','ENTERTAINMENT']
   
   CATEGORY_CODE_MAP = {'LODGING' => [102,103,105,107,110],
                        'FOOD' => [201,202,203],
                        'NIGHTLIFE' => [301,302],
                        'CHILDREN' => [401,402,403,404,405,406,407,408],
                        'SHOPPING' =>[501,502],
                        'OUTDOOR' => [601,602,603,604,605,606,607,608,609,610,611,612,613,614,615,616],
                        'TRANSPORTATION' => [701,702,703,704,705,706,707,708,709,710,713],
                        'TOURS' => [801,802,803,804],
                        'ENTERTAINMENT' => [901,902,903,904]
                        }
                        
   CODE_NAMES = {102 => "Bed & Breakfast",103=>"Vacation Rental",105=>"Hotel/Motel",107=>"Campground/RV Park",110=>"Resort",
                 201=>"Delivery",202=>"Fine Dining",203=>"Restaurants",
                 301=>"Bar/Pub/Nightclub",302=>"Wineries",
                 401=>"Arcade",402=>"Amusement Parks",403=>"Go Karts",404=>"Mini Golf",405=>"Waterpark",406=>"Kids eat free Restaurant",407=>"Kids stay free Lodging",408=>"Other family activities",
                 501=>"Shopping Mall",502=>"Individual Store listings",
                 601=>"Caves",602=>"Walking Trail",603=>"Biking Trail",604=>"Rock Climbing",605=>"Beaches",606=>"Parks",607=>"Golf",608=>"Water Skiing",609=>"Driving Range",610=>"Bungee Jumping",611=>"Parasailing",612=>"Marina",613=>"Hot Air Ballooning",614=>"Helicopter Rides",615=>"Lake Access",616=>"Horseback Riding",
                 701=>"RV Rental",702=>"Bike Rental",703=>"Shuttle Services",704=>"Car Rental",705=>"Taxi",706=>"After-Bar Shuttle",707=>"Motorcycle Rental",708=>"Limo Rental",709=>"ATV Rental",710=>"Watercraft Rental",713=>"Airports",
                 801=>"Boat Tour",802=>"Air Tour",803=>"Land Tour",804=>"Water/Fishing Guide",
                 901=>"Cinema",902=>"Live Show",903=>"Bingo",904=>"Bowling"}  
                 
   ZIP_MAP = {"65020"=>"Camdenton","65065"=>"Camdenton","65037"=>"Gravois Mills","65486"=>"Iberia","65047"=>"Kaiser",
              "65049"=>"Lake Ozark","65065"=>"Osage Beach","65556"=>"Richland","65078"=>"Stover","65079"=>"Sunrise Beach","63366"=>"O'Fallon",
              "65582"=>"Vienna","65463"=>"Eldridge","65082"=>"Tuscumbia","65011"=>"Barnett","65075"=>"Saint Elizabeth","65452"=>"Crocker","65072"=>"Rocky Mount",
              "65026"=>"Eldon","65084"=>"Versailes","65052"=>"Linn Creek","65038"=>"Laurie","65324"=>"Climax Springs","65032"=>"Eugene","65326"=>"Edwards",
              "65567"=>"Stoutland","65325"=>"Cole Camp","65787"=>"Urbana","65786"=>"Macks Creek","65064"=>"Olean","65048"=>"Koeltztown"}
                        
   GEOCODER = Yahoo::Geocode.new 'fkrK3rvV34EdrhpBOjZvecURLRbmnM0JFY9xahhgCUZjkVp1T7IQw6t5C7vtxtuDNDWu'
   
   has_many :discounts
   has_many :trips
   
   validates_presence_of :street_address, :city, :state, :zip, :category, :name, :code
   validates_inclusion_of :category, :in => CATEGORY_OPTIONS, :message=> "should be a valid category"
   
   def validate
     if((!self.category.nil?) and (CATEGORY_OPTIONS.include?(self.category)) and (!(CATEGORY_CODE_MAP[self.category].include?(self.code))))
       errors.add_to_base("Code must be one from category set.")     
     end
     
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
  
  def has_discounts
    self.discounts.size > 0
  end
    
  def self.categories
    CATEGORY_OPTIONS
  end
  
  def self.category_from_code(code)
    CATEGORY_CODE_MAP.keys.each do |key|
      CATEGORY_CODE_MAP[key].each {|val| return key if val == code}
    end 
  end
  
  def self.city_from_zip(zip)
    ZIP_MAP[zip]
  end
  
  def self.csv_import(csv_file)
     @parsed_file=CSV::Reader.parse(csv_file,',')
      n=0
      @parsed_file.each  do |row|
        s=MapItem.new
        s.code=row[0]
        s.category = self.category_from_code(s.code);
        s.name=row[1]
        s.street_address=row[2]
        s.zip=row[3]
        s.city = self.city_from_zip(s.zip)
        s.state="MO"
        s.phone=row[4]
        s.website_url=row[5]
        s.has_reservations = (row[6] == "y")
        s.can_order_online = (row[7] == "y")
        s.can_buy_tickets = (row[8] == "y")
        s.has_discount_coupon = (row[9] == "y")
        s.has_map = (row[10] == "y")
        s.verified = (row[11] == "y")
        
        begin
          s.save!
          n=n+1
          GC.start if n%50==0
        rescue Exception=>e
            puts "******PROBLEM SAVING: #{s.name}*********"
            puts "***#{e.message}"
        end
      end
      
      return n
  end
  
  def self.find_by_search_term(term)
    self.find(:all,:conditions=>["name LIKE ?","%#{term}%"],:limit=>8)
  end
  
  def name
    read_attribute(:name)
  end
  
  def address
    "#{self.street_address}, zip:#{self.zip}"
  end
  
  def reservable?
    read_attribute(:reservable)
  end
  
  def up_for_bid?
    false
  end
  
  def has_picture?
    false
  end
  
  def price
    "N/A"
  end
  
private

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
end
