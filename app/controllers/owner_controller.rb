class OwnerController < ApplicationController
  
  def register
    @owner = User.new
  end
  
  def activate_registration
    if is_post
      @owner = User.new params[:owner]
      if @owner.save        
        session[:user_id] = @owner.id
        redirect_to :action => :account
      else
        render :action => :register
      end
    end
  end
  
  def login
  end
  
  def logout
    session[:user_id] = nil
    redirect_to :action => :welcome,:controller=>:main
  end
  
  def activate_login
    if is_post     
      name = params[:username]
      passwd = params[:password]
      @owner = User.auth(name,passwd)
      if @owner
        session[:user_id] = @owner.id
        redirect_to :action => :welcome,:controller=>:main
      else
        flash[:notice] = "Email or Password is Invalid!"
        render :action => :login
      end
    end    
  end
  
  def account    
    if confirm_login "see your account"
      render :layout=>false
    end    
  end
  
  def edit_account
    confirm_login "edit account details"    
  end
  
  def save_account_changes
    if confirm_login "edit account details" and is_post
      @owner.update_attributes(params[:owner])
      save_owner_if_valid(:edit_account)
    end
  end
  
  def preferences
    if confirm_login "edit preferences"
      render :layout=>false
    end
  end
  
  def save_preferences
    if confirm_login "edit preferences" and is_post
      @owner.update_attributes(params[:owner])
      save_owner_if_valid(:preferences)
    end
  end
  
  def see_discounts
    if confirm_login "see your discounts"
      page = params[:page] || 1
      @discounts = Discount.paginate :per_page => 15, :page => page
      render :layout=>false
    end
  end

  
  def see_listings
    if confirm_login "see your listings"
      render :layout=>false
    end
  end
  
  def add_listing
    if confirm_login "add a listing"
      @listing = Listing.new
      render :layout=>false
    end
  end
  
  def delete_listing
    if confirm_login("delete a listing") and is_post
      confirm_existance_and_ownership_of_listing(params[:id],"delete","listing deleted."){|listing| listing.destroy}      
      redirect_to :action=> :see_listings
    end
  end
  
  def edit_listing
    if confirm_login("edit listings")
      if !confirm_existance_and_ownership_of_listing(params[:id],"edit"){|listing| @listing = listing}
        redirect_to :action => :see_listings
      else
        render :layout => false
      end
    end
  end
  
  def save_listing_changes
    if confirm_login("edit listings") and is_post
      redirect_to :action=>:see_listings unless confirm_existance_and_ownership_of_listing(params[:id],"edit","changes to listing saved") do |listing|
        @listing = listing
        @listing.update_attributes(params[:listing])
        params[:attachment_data] ||= []
        params[:attachment_data].each do |file|
          @listing.images.create({:uploaded_data => file, :user => @owner}) unless file == "" 
        end
        save_listing_if_valid :edit_listing
      end
    end
  end
  
  def exec_add_listing   
    if confirm_login("add a listing") and is_post
      @listing = Listing.new params[:listing]
      @listing.active = true
      @listing.user = @owner      
      if @listing.save
        params[:attachment_data] ||= []
        params[:attachment_data].each do |file|
          @listing.images.create({:uploaded_data => file, :user => @owner}) unless file == "" 
        end
        redirect_to :action => :see_listings
      else
        flash[:notice] = nil
        render :action => :add_listing
      end
    end
  end
  
  def see_listing_calendar
    if confirm_login("see a listings calendar")
      @unit = ListingUnit.find(params[:id])
      @year = (params[:year] && params[:year].to_i) || Date.today.year
      @month = (params[:month] && params[:month].to_i) || Date.today.month  
      td = Date.today
      today = VacationLinkTime.as_date_string(td.year,td.month,td.day)
      params[:cal_start_date] = params[:cal_start_date] || today
      params[:cal_stop_date] = params[:cal_stop_date] || today
      params[:period_type] = params[:period_type] || "AVAILABLE"
      @item = @unit.get_calendar_item(@year,@month);
      render :layout => false
    end
  end
  
  def add_calendar_item
    start_date = Date.parse(params[:cal_start_date])
    stop_date = Date.parse(params[:cal_stop_date])
    ListingCalendarItem.mark_days(params[:id].to_i,start_date,stop_date,params[:period_type])
    redirect_to :action=>:see_listing_calendar,:id => params[:id].to_i, :year=>start_date.year, :month=>start_date.month
  end
  
  def edit_unit
    @unit = ListingUnit.find(params[:id])
  end
  
  def save_unit_changes
    @unit = ListingUnit.find(params[:id])
    @unit.update_attributes(params[:unit])
    if @unit.save
      redirect_to :action=>:edit_listing,:id=>@unit.listing_id
    else
      render :action=>:edit_unit
    end
  end
  
  def add_unit
    listing = Listing.find(params[:id])
    @unit = ListingUnit.new(:listing_id=>listing.id)
  end
  
  def exec_add_unit
    @unit = ListingUnit.new(params[:unit])
    if @unit.save
      redirect_to :action=>:edit_listing,:id=>@unit.listing_id
    else
      render :action=>:add_unit
    end
  end
  
  
  def delete_unit
    @unit = ListingUnit.find(params[:id])
    @unit.destroy
    redirect_to :action=>:edit_listing,:id=>@unit.listing_id
  end
  
  def delete_listing_image
    if confirm_login("delete this image")
      img = @owner.images.find_by_id(params[:id])
      img.destroy if img
      render :update do |page|
        page.remove "image_#{params[:id]}"
      end
    end
  end
  
private
  def confirm_login(flash_message)
    current_owner = session[:user_id]
    if current_owner
      @owner = User.find(current_owner)
      true
    else
      flash[:notice] = "you must be logged in to " + flash_message
      redirect_to :action => :login
      false
    end     
  end  
  
  def is_post
    if !request.post?
      flash[:notice] = "Improper Action Taken."
      redirect_to :action => :login
      false
    else
      true
    end
  end
  
  def confirm_existance_and_ownership_of_listing(id,action_description,success_message=nil)
    begin
      listing = Listing.find(id)
      if !listing.belongs_to(@owner)
        flash[:notice] = "You cannot #{action_description} a listing that you do not own"
        false
      else        
        flash[:notice] = success_message
        yield listing
        true
      end
    rescue ActiveRecord::RecordNotFound
      flash[:notice] = "You must specify a listing to #{action_description}"
      false
    end
  end
  
  def save_listing_if_valid(render_if_invalid)
    if @listing.save
      respond_to do |wants|
        wants.html {redirect_to :action => :see_listings}
        wants.js {render ""}
      end      
    else
      flash[:notice] = nil
      render :action => render_if_invalid
    end
  end
  
  def save_owner_if_valid(render_if_invalid)
    if @owner.save      
      session[:user_id] = @owner.id
      flash[:notice] = "Changes Saved!"
      redirect_to :action => :account
    else
      render :action => render_if_invalid
    end
  end
end
