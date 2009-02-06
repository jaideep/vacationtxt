# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include HoptoadNotifier::Catcher
  
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  
  layout proc{ |c| c.request.xhr? ? false : "application" }
  
protected

  def authorize
    if !session[:user_id]
      redirect_to :action => :login,:controller=>:owner
    else
      @user = User.find(session[:user_id])
    end
  end
  
end
