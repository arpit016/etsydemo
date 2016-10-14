class Listing < ActiveRecord::Base
  if Rails.env.production?
    has_attached_file :image, styles: { medium: "200x", thumb: "100x100>" }, default_url: "missing.jpg"
    validates_attachment_content_type :image, content_type: /\Aimage\/.*\z/
  else
    has_attached_file :image, styles: { medium: "200x", thumb: "100x100>" }, default_url: "missing.jpg"
    validates_attachment_content_type :image, content_type: /\Aimage\/.*\z/
  end
end
