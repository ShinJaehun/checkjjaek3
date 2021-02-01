class PhotosController < ApplicationController
  before_action :set_photo
  before_action :authenticate_user!
  load_and_authorize_resource

  def create
    @photo = Photo.create(images: photo_params[:images])
    post = @photo.posts.new(content: photo_params[:posts_attributes]['0'][:content])
    post.user_id = photo_params[:posts_attributes]['0'][:user_id]
    if post.save
      redirect_to root_path
    else
      redirect_back(fallback_location: new_photo_url)
    end
  end

  private

  def set_photo
  end

  def photo_params
    params.require(:photo).permit(posts_attributes: [:user_id, :content], images: [])
  end
end
