class Photo < ApplicationRecord
  has_many :posts, as: :postable
  accepts_nested_attributes_for :posts
  validate :image_type

  has_many_attached :images

  private

  def image_type
    if images.attached? == false
      errors.add(:images, "are missing!")
    end
    images.each do |image|
      if !image.content_type.in?(%('image/jpeg image/jpg image/png'))
        errors.add(:images, "need to be jpeg/jpg/png")
      end
    end
  end
end
