class CustomerController < ApplicationController
  
  def register
    @customer = User.new
    render :layout => false
  end
  
  def view_listing
    @listing = Listing.find(params[:id])
    @user = User.find(session[:user_id]) if session[:user_id]
    @unit = @listing.get_selected_unit(params[:selected_unit])
    
    today = Date.today
    tomorrow = today + 1.day
    @start_time = DateTime.civil(today.year,today.month,today.day,18,0)
    @stop_time = DateTime.civil(tomorrow.year,tomorrow.month,tomorrow.day,11,0)
      
    render :layout=> false
  end
  
  def activate_registration
    if request.get?
      redirect_to :action => :login
    else    
      @customer = User.new params[:customer]
      if @customer.save        
        session[:user_id] = @customer.id
        UserMailer.deliver_welcome(@customer)
        redirect_to :action=>(session[:redirect_target] || :account)
      else
        render :action => :register
      end
    end
  end
  
  def login
    @update_element = params[:update_target] || "page_hoster_content"
    @complete_callback = params[:complete_callback] || ""
    render :layout => false
  end
  
  def activate_login
    if request.get?
      redirect_to :action => :login
    else      
      name = params[:username]
      passwd = params[:password]
      @customer = User.auth(name,passwd)
      if @customer
        session[:user_id] = @customer.id
        redirect_to :action => (session[:redirect_target] || :account),:controller => :customer
      else
        flash[:notice] = "Email Address or Password is Invalid!"
        render :action => :login
      end
    end
  end
  
  def account
    redirect_to :controller=>:owner,:action=>:account
  end
  
  def edit_account
    if confirm_login "edit account details"   
      render :layout => false
    end
  end
  
  def save_account_changes
    if confirm_login "edit account details" and is_post
      @customer.update_attributes(params[:customer])
      save_customer_if_valid(:edit_account)
    end
  end
  
  def preferences
    if confirm_login "edit preferences"
      render :layout => false
    end
  end
  
  def save_preferences
    if confirm_login "edit preferences" and is_post
      @customer.update_attributes(params[:customer])
      save_customer_if_valid(:preferences)
    end
  end
  
  def see_rentals
    
  end
  
  def logout
    session[:user_id] = nil
    redirect_to :action => :login,:complete_callback=>params[:complete_callback]
  end
  
  def forgot_password
  end
  
  def recover_password
    user = User.find(:first,:conditions=>["email = ?",params[:email]])
    InternalMailer.deliver_recovered_password(user)
  end

  def listing_calendar_previous_month
    @date = Date.civil(params[:year].to_i,params[:month].to_i,1) - 1.month
    @listing = Listing.find(params[:id])
    @listing_cal_item = @listing.get_calendar_item(@date.year,@date.month)
    render :template=>"customer/listing_calendar"
  end
  
  def listing_calendar_next_month
    @date = Date.civil(params[:year].to_i,params[:month].to_i,1) + 1.month
    @listing = Listing.find(params[:id])
    @listing_cal_item = @listing.get_calendar_item(@date.year,@date.month)
    render :template=>"customer/listing_calendar"
  end
private
  def confirm_login(flash_message,redirect_target = "account",update_target = "page_hoster_content",complete_callback = "")
    current_customer = session[:user_id]
    if current_customer
      @customer = User.find(current_customer)
      true
    else
      flash[:notice] = "you must be logged in to " + flash_message
      session[:redirect_target] = redirect_target
      params[:update_target] = update_target
      params[:complete_callback] = complete_callback
      redirect_to :action => :login
      false
    end     
  end  
  
  def save_customer_if_valid(render_if_invalid)
    if @customer.save      
      session[:user_id] = @customer.id
      flash[:notice] = "Changes Saved!"
      redirect_to :action => :account
    else
      render :action => render_if_invalid
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

end
