class AdminController < ApplicationController
  
  before_filter :authorize, :except=>[:login,:exec_login]
  
  def main
    
  end
  
  def add_discount
    @discount = Discount.new
    @map_item_id = params[:id]
  end
  
  def all_discounts
    page = params[:page] || 1
    if params[:id] 
      @discounts = Discount.paginate :per_page => 15, :page => page,
                                     :conditions => { :map_item_id => params[:id] }
      @id = params[:id]
    else
      @discounts = Discount.paginate :per_page => 15, :page => page
    end
  end
  
  def exec_add_discount
    @discount = Discount.new params[:discount]
    if @discount.save
      flash[:notice] = "Item added!"
      redirect_to :action=>:main
    else
      render :action=>:add_discount
    end
  end
  
  def edit_discount
    @discount = Discount.find(params[:id])
  end
  
  def save_discount_changes
    @discount = Discount.find(params[:id])
    @discount.update_attributes params[:discount]
    if @discount.save
      flash[:notice] = "Changes Saved!"
      redirect_to :action=>:main
    else
      render :action=>:edit_discount
    end
  end
  
  def destroy_discount
    @discount = Discount.find(params[:id])
    @discount.destroy
    flash[:notice] = "Discount deleted!"
    redirect_to :action=>:main
  end
  
  def add_map_item
    @item = MapItem.new
  end
  
  def exec_add_map_item
    @item = MapItem.new params[:item]
    if @item.save
      flash[:notice] = "Item added!"
      redirect_to :action=>:main
    else
      render :action=>:add_map_item
    end
  end
  
  def all_map_items
    page = params[:page] || 1
    @items = MapItem.paginate :per_page => 15, :page => page
  end
  
  def edit_map_item
    @item = MapItem.find(params[:id])
  end
  
  def save_map_item_changes
    @item = MapItem.find(params[:id])
    @item.update_attributes params[:item]
    if @item.save
      flash[:notice] = "Changes Saved!"
      redirect_to :action=>:main
    else
      render :action=>:edit_map_item
    end
  end
  
  def login
    puts "LOGIN"
  end
  
  def exec_login
    puts "EXEC LOGIN"
    if params[:password] == "Vizitech"      
      session[:ADMIN_LOGIN] = "TRUE"
      redirect_to :action=>:main
    else 
      session[:ADMIN_LOGIN] = nil
      flash[:notice] = "NO!"
      render :action=>:login
    end
  end

private
  def authorize
    if !session[:ADMIN_LOGIN]
      redirect_to :action=>:login
    end
  end
end
