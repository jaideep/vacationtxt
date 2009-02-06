# Be sure to restart your server when you modify this file.

ActionMailer::Base.delivery_method = :smtp

ActionMailer::Base.smtp_settings = {
  :domain => "vacationstxt.com",
  :perform_deliveries => true,
  :address => 'smtp.ey05.engineyard.com',
  :port => 25
}
