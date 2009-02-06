require 'active_record_extension'

class User < ActiveRecord::Base  
  include Ipipi::SmsSender  
  
  has_many :rentals, {:dependent => :destroy}
  has_many :listings, {:dependent => :destroy}
  has_many :trips
  has_many :messages
  has_many :images
  validates_presence_of :password, :name, :email, :phone, :street_address, :city, :state, :zip
  validates_uniqueness_of :email,:phone
  validates_length_of :phone,:minimum=>11,:message=>"phone number should be at least 11 digits (must include country code), no spaces or other characters"
  validates_numericality_of :phone,:message=>"phone number should be at least 11 digits (must include country code), no spaces or other characters"
  validates_numericality_of :default_search_single_count, :only_integer => true, :message => "can only be whole number."
  validates_inclusion_of :default_search_single_count, :in => 1..20, :message => "can only be between 1 and 20."
  validates_numericality_of :default_search_double_count, :only_integer => true, :message => "can only be whole number."
  validates_inclusion_of :default_search_double_count, :in => 1..20, :message => "can only be between 1 and 20."
  validates_numericality_of :default_search_max_price, :only_integer => true, :message => "can only be whole number."
  validates_inclusion_of :default_search_max_price, :in => 1..10000, :message => "can only be between 1 and 10000."
  validates_inclusion_of :call_me_start_time, :in => VacationLinkTime.options.map {|disp,value| value}
  validates_inclusion_of :call_me_stop_time, :in => VacationLinkTime.options.map {|disp,value| value}
  validates_inclusion_of :text_me_start_time, :in => VacationLinkTime.options.map {|disp,value| value}
  validates_inclusion_of :text_me_stop_time, :in => VacationLinkTime.options.map {|disp,value| value}
  
  def self.find_by_full_number(p_number)
    User.find(:first,:conditions=>["phone = ?",p_number])
  end
  
  def self.auth(email,passwd)
    user = User.find_by_email(email)
    if user.nil? or (user.password != passwd)
      user = nil
    end
    user
  end
  
  def initialize(attributes=nil)
    super(attributes)
    set_if_nil(:call_me_start_time,9)
    set_if_nil(:call_me_stop_time,17)
    set_if_nil(:text_me_start_time,8)
    set_if_nil(:text_me_stop_time,21)
    set_if_nil(:default_search_single_count,1)
    set_if_nil(:default_search_double_count,1)
    set_if_nil(:default_search_max_price,500)
  end  
  
  def active_listings
    Listing.find(:all, :conditions => ["user_id = ? and active = ?",id,true])
  end
  
  def inactive_listings
    Listing.find(:all, :conditions => ["user_id = ? and active = ?",id,false])
  end
  
  def full_number
    self.phone.to_s
  end
  
  def add_map_item_to_trip(map_item)
    add_to_trip(map_item,:map_item_id,"MAP_ITEM")
  end
  
  def add_discount_to_trip(discount)
    add_to_trip(discount,:discount_id,"DISCOUNT")
  end
  
  def add_listing_to_trip(listing_unit, start = Date.today, stop = (Date.today + 1.day))
    add_to_trip(listing_unit,:listing_unit_id,"LISTING",start,stop)
  end
  
  def clear_trip
    self.trips.each{|trip| trip.destroy }
  end
  
  def on_trip(unit)
    Trip.find(:all,:conditions=>"user_id = #{self.id} and listing_unit_id = #{unit.id}").size > 0
  end
  
  def sms_trip
    self.trips.sort{|a,b| a.start <=> b.start }.each do |trip|
      message = ""
      if trip.status == 'NOT_RESERVABLE'
        message = "#{trip.name}, #{trip.start.strftime("%m/%d/%y %I:%M %p")}. Phone: #{trip.phone}. Address: #{trip.address}."
      else
        message = "#{trip.name} from #{trip.start.strftime("%m/%d/%y %I:%M %p")} to #{trip.stop.strftime("%m/%d/%y %I:%M %p")}. Phone: #{trip.phone}. Address: #{trip.address}. Price: #{trip.price}"
      end
      self.send_sms(self.full_number,message)
    end
  end
  
  def send_threaded_message(trip_id,msg,role)
    message = Message.new(:trip_id=>trip_id,:text=>msg,:user_id=>self.id,:role=>role)
    self.send_message_obj(message)
  end
  
  def cancel_threaded_message(trip_id,msg = nil)
    if !self.message_waiting_id.nil? and Message.find(self.message_waiting_id).trip_id == trip_id
      self.send_sms(self.full_number,msg) if msg 
      Message.find(self.message_waiting_id).destroy
      self.clear_waiting_data
      self.process_queue
    end
  end
  
  def send_message_obj(message)
    message.save!
    if !self.is_waiting_on_reply?
      self.wait_on_reply!(message)
    end
  end
  
  def is_waiting_on_reply?
    !self.message_waiting_id.nil?
  end
  
  def wait_on_reply!(message)
    self.message_waiting_id = message.id
    self.message_waiting_timestamp = DateTime.now
    self.save!
    self.send_sms(self.full_number,message.text)
  end
  
  def process_reply(data)
    message = Message.find(self.message_waiting_id)
    message.deliver_response(data)
    message.destroy
    self.clear_waiting_data
    self.process_queue
  end
  
  def clear_waiting_data
    self.message_waiting_id = nil
    self.message_waiting_timestamp = nil
    self.save!
  end
  
  def process_queue
    queued_message = Message.find(:first,:conditions=>"user_id = #{self.id}",:order => 'created_at')
    if !queued_message.nil?
      self.send_message_obj(queued_message) 
    end
  end
  
private 
  def set_if_nil(attr,value)
    write_attribute(attr,value) if read_attribute(attr).nil?
  end
  
  def add_to_trip(item,id_type,category,start = nil,stop = nil)
    start ||= DateTime.civil(Date.today.year,Date.today.month,Date.today.day,15,0)
    tomorrow = (Date.today + 1.day)
    stop ||= DateTime.civil(tomorrow.year,tomorrow.month,tomorrow.day,11,0)
    
    trip = Trip.new(:user_id=>self.id,id_type=>item.id,:category=>category,:start=>start,:stop=>stop)
    trip.mark_unreservable! if !item.reservable?  
    trip.save!
    return trip
  end
end
