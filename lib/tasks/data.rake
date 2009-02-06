namespace :data do
  desc "import map items from CSV file"
  task :import_map_items => :environment do    
    unless ENV.include?("file")
      raise "usage: rake import_map_items file= # full path, please"
    end
    MapItem.delete_all
    f = File.open(ENV["file"])
    MapItem.csv_import(f)
  end
  
  task :clear_queue => :environment do
    unless ENV.include?("PHONE")
      raise "usage: rake data:clear_queue PHONE=[phone_number]"
    end
    user =  User.find_by_full_number(ENV["PHONE"])
    puts "user is #{user.name}"
    user.messages.each do |m|
      m.destroy
    end
    user.message_waiting_id = nil
    user.save!
  end
  
  task :flush_queues => :environment do
    User.all.each do |user|
      puts "flushing queue for #{user.name}"
      user.messages.each do |m|
        m.destroy
      end
      user.message_waiting_id = nil
      user.save
    end
  end
  
  task :delete_some_users => :environment do
    User.all.each do |user|
      if user.phone =~ /925/
        user.destroy 
        puts "destroyed #{user.name}..."
      else 
        puts "kept #{user.name}..."
      end
    end
  end
  
  task :fix_urls => :environment do
    MapItem.all.each do |mi|
      if mi.website_url == "http://"
        mi.website_url = nil
        mi.save
      end
    end
  end
end