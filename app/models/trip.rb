class Trip < ActiveRecord::Base
  include Ipipi::SmsSender
  
  belongs_to :user
  belongs_to :map_item
  belongs_to :discount
  belongs_to :listing_unit
  
  has_many :messages
  
  before_destroy do |record| 
    record.clear_renter_message_thread
    if record.status == 'QUERIED' or record.status == 'BOOKED'
      record.cancel!
    end
    record.messages.each do |m|
      m.destroy
    end
  end
  
  CATEGORIES = ['DISCOUNT','MAP_ITEM','LISTING']
  STATUSI = ['NOT_RESERVABLE','PICKED','QUERIED','AVAILABLE','UNAVAILABLE','COUNTEROFFER','BOOKED']
  validates_inclusion_of :category, :in => CATEGORIES, :message=> "should be a valid category!"
  validates_inclusion_of :status, :in => STATUSI,:message=> "should have a valid status!"
  validates_presence_of :start,:stop,:user_id
  
  def initialize(attrs={})
    super
    self.status ||= 'PICKED'
    self.start ||= DateTime.now
    self.stop ||= DateTime.now + 1.day
    self.bid ||= (self.item.nil?) ? 200 : self.item.price
  end
  
  def validate
    if (self.category == 'DISCOUNT' and !self.discount_id) or 
       (self.category == 'MAP_ITEM' and !self.map_item_id) or 
       (self.category == 'LISTING' and !self.listing_unit_id) 
      errors.add_to_base "Category must have an associated foreign key!"
    end
  end
  
  def name
    self.item.name
  end
  
  def phone
    self.item.phone
  end
  
  def address
    self.item.address
  end
  
  def long
    self.item.long
  end
  
  def lat
    self.item.lat
  end
  
  def description
    self.item.description
  end
  
  def item_id
    self.item.id
  end
  
  def item_category
    self.item.category
  end
  
  def code
    self.item.code
  end
  
  def website_url
    self.item.website_url
  end
  
  def thumbnail_url
    self.item.thumbnail_url
  end
  
  def has_picture?
    self.item.has_picture?
  end
  
  def price
    if self.up_for_bid?
      self.bid
    else
      self.item.price
    end
  end
  
  def reservable?
    self.item.reservable?
  end
  
  def has_defined_ending?
    self.category == "LISTING" or (self.category == "MAP_ITEM" and self.map_item.category == "LODGING")
  end
  
  def get_calendar_item(year,month)
    self.item.get_calendar_item(year,month)
  end
  
  def removable?
    true
  end

  def up_for_bid?
    self.item.up_for_bid?
  end
  
  def actionable?
    self.status != 'QUERIED' and self.status != 'BOOKED' and self.status != 'NOT_RESERVABLE'
  end
  
  def check_availability(clear_queue = true)
    if self.status != "QUERIED" #don't want to process a duplicate availability check
      clear_renter_message_thread if clear_queue
      auto_reply = self.item.availability_on(self.start,self.stop)
      if auto_reply
        self.status = (auto_reply == "AVAILABLE") ? 'AVAILABLE' : 'UNAVAILABLE'
      else
        self.item.send_owner_threaded_message(self.id,build_availability_message)
        self.status = 'QUERIED'
      end
      self.save!
    end
  end
  
  def book!
    clear_renter_message_thread
    self.item.book!(self.start,self.stop)
    self.status = 'BOOKED'
    self.save
    log_transaction
    send_sms(self.item.number,"#{self.item.name} booked. In #{self.start.strftime("%m/%d/%y")}, out #{self.stop.strftime("%m/%d/%y")}. Price: #{self.price}  Renter phone is '#{self.user.phone}'")
    send_sms(self.user.phone,"#{self.item.name} booked. In #{self.start.strftime("%m/%d/%y")}, out #{self.stop.strftime("%m/%d/%y")}. Price: #{self.price}  Owner phone is '#{self.item.number}'")
  end
  
  def log_transaction
    transaction = Transaction.new
    transaction.renter_id = self.user_id
    transaction.owner_id = self.item.listing.user_id
    transaction.listing_unit_id = self.item.id
    transaction.price = self.price
    transaction.start = self.start
    transaction.stop = self.stop
    transaction.timestamp = Time.now
    transaction.save!
  end
  
  def cancel!
    self.item.unbook!(self.start,self.stop) if self.status == "BOOKED"
    self.status = 'PICKED'
    self.save
    self.item.cancel_trip(self.id,"Reservation request for #{self.item.name} from #{self.start.strftime("%m/%d/%y")} to #{self.stop.strftime("%m/%d/%y")} has been cancelled! No reply necessary.")
  end
  
  def mark_unreservable!
    self.status = 'NOT_RESERVABLE'
    self.save
  end
  
  def item
    if (self.category == 'DISCOUNT')
      self.discount
    elsif (self.category == 'MAP_ITEM')
      self.map_item
    elsif (self.category == 'LISTING')
      self.listing_unit
    end
  end
  
  def can_modify_times
    ( !self.reservable? or 
      self.status == 'PICKED' or 
      self.status == 'UNAVAILABLE' )
  end
  
  def is_selected_status?
    self.status == 'PICKED'
  end
  
  IMG_MAP = {'PICKED'=> "picked.jpg",
             'QUERIED'=>"contacting.jpg",
             'AVAILABLE'=>"available.jpg",
             'UNAVAILABLE'=>"unavailable.jpg",
             'BOOKED'=>"booked.jpg",
             'NOT_RESERVABLE'=>"booked.jpg",
             'COUNTEROFFER'=>"available.jpg"}
  
  def status_image_url    
    IMG_MAP[self.status]
  end

  def process_owner_response(resp)
    message = ""
    if is_affirmative_response resp
      self.status = 'AVAILABLE'
      message = self.up_for_bid? ? "owner of '#{self.name}' has accepted the bid, text back 'Y' to confirm or confirm on vacationstxt.com" : "Property '#{self.name}' is available, text back 'Y' to confirm or confirm on vacationstxt.com"
    elsif is_negative_response resp
      self.status = 'UNAVAILABLE'
      message = self.up_for_bid? ? "owner of '#{self.name}' has declined the bid" : "Property '#{self.name}' is unavailable"
    elsif self.up_for_bid? and is_counteroffer(resp)
      self.status = 'COUNTEROFFER'
      self.bid = resp.to_i
      message = "owner of '#{self.name}' has offered $#{self.bid} per night; text back 'Y', 'N', or counteroffer (or respond on vacationstxt.com)"
    else
      raise "Improper SMS Response"
    end
    self.save
    send_renter_sms(message)
  end
  
  def process_renter_response(resp)
    if is_affirmative_response resp
      self.book!
    elsif is_negative_response resp
      self.destroy
    elsif self.up_for_bid? and is_counteroffer(resp)
      self.bid = resp.to_i
      self.check_availability(false)
    end
  end
  
  def send_renter_sms(message)
    self.user.send_threaded_message(self.id,message,"RENTER")
  end
  
  def clear_renter_message_thread
    self.user.cancel_threaded_message(self.id)
  end

private
  def is_affirmative_response(resp)
    resp.upcase['Y']
  end

  def is_negative_response(resp)
    resp.upcase['N']
  end  
  
  def is_counteroffer(resp)
    resp =~ /^\d+$/
  end
  
  def build_availability_message
    if self.up_for_bid?
      "Request #{self.item.name}, in #{self.start.strftime("%m/%d/%y")}, out #{self.stop.strftime("%m/%d/%y")}, BID $#{self.bid}! OK? (Text back 'Y' or 'N' or counteroffer)"
    else  
      "Request #{self.item.name}, in #{self.start.strftime("%m/%d/%y")}, out #{self.stop.strftime("%m/%d/%y")}! OK? (Text back 'Y' or 'N')"
    end
  end
end
