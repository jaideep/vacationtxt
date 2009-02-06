require 'ipipi'

class Sender
  include Ipipi::SmsSender
end
sender = Sender.new()
puts sender.send_sms('15732395840','Hello from testing 123')