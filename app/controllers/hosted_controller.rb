class HostedController < ApplicationController
  def destination_menu
  end
  
  def view_merchant
    @item = MapItem.find(params[:id])
    render :layout=> false
  end
end
