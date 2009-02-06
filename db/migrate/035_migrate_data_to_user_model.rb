class MigrateDataToUserModel < ActiveRecord::Migration
  def self.up
    usrList = User.find(:all)
    if usrList
      usrList.each do |usr|
        usr.destroy
      end
    end
    
    # ownrList = Owner.find(:all)
    #     if ownrList
    #       ownrList.each do |owner|      
    #         usr = User.new
    #         usr.name = owner.name
    #         usr.email = owner.email    
    #         usr.password = owner.password
    #         usr.phone = owner.phone
    #         usr.street_address = owner.street_address
    #         usr.city = owner.city
    #         usr.state = owner.state
    #         usr.zip = owner.zip
    #         usr.cc_number = owner.cc_number
    #         usr.cc_expiry_month = owner.cc_expiry_month
    #         usr.cc_expiry_year = owner.cc_expiry_year
    #         usr.cc_security_number = owner.cc_security_number
    #         usr.cc_name_on = owner.cc_name_on
    #         usr.time_zone = owner.time_zone
    #         usr.text_me_start_time = owner.text_me_start_time
    #         usr.text_me_stop_time = owner.text_me_stop_time
    #         usr.call_me_start_time = owner.call_me_start_time
    #         usr.call_me_stop_time = owner.call_me_stop_time
    #         usr.timeout = owner.timeout
    #         usr.notify_of_failed = true   
    #         usr.response_preference = 'ONLINE'
    #         usr.default_search_single_count = 1
    #         usr.default_search_double_count = 1
    #         usr.default_search_max_price = 500
    #         if !usr.valid?
    #           usr.email = "prevOwner#{owner.id}@gmail.com"
    #           usr.phone = "#{owner.id}732395840"
    #         end
    #         usr.save!
    #         
    #         list = Listing.find(:all,:conditions=>"owner_id = #{owner.id}")
    #         if list
    #           list.each do |listing|
    #             listing.user_id = usr.id
    #             listing.save!
    #           end        
    #         end
    #       end
    #     end
    
    # cstList = Customer.find(:all)
    #     if cstList
    #       cstList.each do |cust|
    #         usr = User.new
    #         usr.name = cust.name
    #         usr.email = cust.email    
    #         usr.password = cust.password
    #         usr.phone = cust.phone
    #         usr.street_address = cust.street_address
    #         usr.city = cust.city
    #         usr.state = cust.state
    #         usr.zip = cust.zip      
    #         usr.notify_of_failed = true 
    #         usr.response_preference = cust.response_preference
    #         usr.default_search_single_count = cust.default_search_single_count
    #         usr.default_search_double_count = cust.default_search_double_count
    #         usr.default_search_max_price = cust.default_search_max_price
    #         if !usr.valid?
    #           usr.email = "prevCust#{cust.id}@gmail.com"  
    #           usr.phone = "573239584#{cust.id}"
    #         end
    #         usr.save!
    #         
    #         
    #         list = Rental.find(:all,:conditions=>"customer_id = #{cust.id}")
    #         if list
    #           list.each do |rent|
    #             rent.user_id = usr.id
    #             rent.save!
    #           end
    #         end
    #       end
    #     end
  end

  def self.down
    usrList = User.find(:all)
    if usrList
      usrList.each do |usr|
        usr.destroy
      end
    end
  end
end
