require 'net/http'
require 'net/https'

module Ipipi
  module SmsSender
    SMS_TOKEN = '67d55043-c17b-4283-85d5-02465c957c95'
    SMS_SIGNATURE = 'gRxbawmwI7TNANBc7Rpaz1G6'
    SMS_ENCODING = 'Seven'
    
  public
    def send_sms(recipient,message)
      Net::HTTP.post_form(URI.parse('http://api.upsidewireless.com/soap/SMS.asmx/Send_Plain'),
                              {'token'=>SMS_TOKEN, 'signature'=>SMS_SIGNATURE, 'recipient' => recipient, 'message' => message, 'encoding'=>SMS_ENCODING})
    end
  end
end