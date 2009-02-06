# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def getCssClassForDay(date,item)
    status = item.day_status(date.day)
    if status
      ("AVAILABLE" == status) ? "openDay" : "bookedDay"
    else
      "normalDay"
    end
  end
  
  def picture_path(listing)
    if listing.images.empty?
      listing.thumbnail_url # for previously uploaded images
    else
      listing.images.first.public_filename(:thumb)
    end
  end
  
  def listing_images_gallery(listing)
      images = []
      listing.images.find(:all, :order=>"created_at DESC").each do |image|
        images << "<a href ='#{image.public_filename}' class='lightview' rel='gallery[#{listing.strong_name}_gallery]' 
          title='#{listing.strong_name} :: #{truncate(listing.description, 70)}'>#{image_tag(image.public_filename(:small), :border=>'nil')}</a>"
      end
      return images.join(" ")
  end
end
