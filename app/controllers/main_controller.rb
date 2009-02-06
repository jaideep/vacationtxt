class MainController < ApplicationController  
  def welcome
    @customer = (session[:user_id]) ? User.find(session[:user_id]) : nil
    @search_context = session[:map_context]
    @see_trip = params[:see_trip] or false
    @see_trip_item = params[:see_trip_item] 
    @see_trip_item = (@see_trip_item.nil? or @see_trip_item == "") ? "false" : Trip.find(@see_trip_item).id
  end
  
  def exec_report_issue
    InternalMailer.deliver_bug_or_issue params[:comments]
    flash[:notice] = "Thanks for your input!"
    redirect_to :action => :welcome
  end
  
  def discounts
    find_clipped_coupons
    page = params[:page] || 1
    if params[:map_item]
      raw_discounts = pad_discounts(Discount.find :all, :conditions => ["map_item_id = ?", params[:map_item]], 
        :order => :priority)
      @discounts = raw_discounts.paginate :per_page => 6, :page => page,
        :conditions => { :map_item_id => params[:map_item] }
      @map_item = params[:map_item]
    else
      raw_discounts = pad_discounts(Discount.find :all, :order => :priority)
      @discounts = raw_discounts.paginate :per_page => 6, :page => page
    end
  end
  
  def map_item_click
    puts "map item " + params[:type] + " click for item " + params[:id]
    click = Click.new
    click.map_item_id = params[:id]
    click.target = params[:type]
    click.timestamp = Time.now
    click.save!
    render :text => ""
  end
  
  def sms_clipped_coupons
    find_clipped_coupons
    @sms_enabled_coupons = @clipped_coupons.select {|c| c.sms_enabled}
  end
  
  def sms_send_clipped_coupons
    find_clipped_coupons
    @sms_enabled_coupons = @clipped_coupons.select {|c| c.sms_enabled}
    phone_number = params[:phone_number]
    @sms_enabled_coupons.each {|c|
      c.send_as_sms(phone_number)
    }

    size = @sms_enabled_coupons.size
    
    flash[:notice] = 
      size.to_s + " SMS message(s) sent to " + phone_number.to_s + "."
    redirect_to :action => :print_clipped_coupons
  end
  
  def print_clipped_coupons
    find_clipped_coupons
  end
  
  def clip_coupon
    find_clipped_coupons
    @clipped_coupons << Discount.find(params[:id])
    respond_to { |format| format.js }
  end

  def clear_clipped_coupons
    session[:clipped_coupons] = nil
    redirect_to :action => :discounts
  end
  
  def remote_map_search
    session[:map_context] = {:bed_count => params[:bed_count],:max_people=>params[:max_people],:max_price => params[:max_price],:region=>params[:region]}
    gen_json_search_results
  end
  
  def cached_map_search
    gen_json_search_results
  end
  
  def process_sms
    user = User.find_by_full_number(params[:sender])
    begin
      user.process_reply(params[:data])
      respond_to do |wants|
        wants.html {render :html => "<result>success</result>"}
        wants.xml {render :xml => "<result>success</result>"}
      end
    rescue
      user.send_sms(user.phone,"Your message could not be processed by vacationstxt.com!  Please try again....");
    end
  end
  
  def fake_sms_response
    
  end
private
  def gen_json_search_results
    search_hash = session[:map_context]
    if search_hash
      sanitize_hash(search_hash)
      @search_results = Listing.search(search_hash)
      render :text=>(@search_results.to_json(:only=>[:strong_name,:long,:lat,:thumbnail_url,:description,:id],:methods=>:thumbnail_url))
    else
      render :text=>"";    
    end
  end
  
  def sanitize_hash(search_hash)
    search_hash[:bed_count] = 0 if search_hash[:bed_count].nil? || search_hash[:bed_count] == ""
    search_hash[:max_people] = 0 if search_hash[:max_people].nil? || search_hash[:max_people] == ""
  end
  
  def desanitize_search_hash(search_hash)
    search_hash[:bed_count] = nil if search_hash[:bed_count] == 0
    search_hash[:max_people] = nil if search_hash[:max_people] == 0
  end
  
  def today_as_caledariffic_string
    td = Date.today
    VacationLinkTime.as_date_string(td.year,td.month,td.day)
  end

  # This may become a bottleneck as the number of discounts increases.
  # If so, make this a proper iterator.
  def pad_discounts(ds)
    accumulator = []
    ds.each { |d|
      accumulator << d
      if d.priority == 1
        accumulator << nil
      end
    }
    accumulator
  end
  
  def find_clipped_coupons
    @clipped_coupons = (session[:clipped_coupons] ||= [])
  end

end
