class AdvertiserController < ApplicationController
  def exec_request_brochure
    InternalMailer.deliver_brochure_request(params)
  end
  
  def exec_add_business
    InternalMailer.deliver_add_business(params)
  end

  def exec_contact_us
	if(params[:request] == 'Add Business')
		exec_add_business
	else 
		exec_request_brochure
	end
  end
end
