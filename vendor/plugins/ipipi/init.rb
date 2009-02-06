require 'ipipi'

ActionController::Base.send(:include, Ipipi)
ActiveRecord::Base.send(:include, Ipipi)