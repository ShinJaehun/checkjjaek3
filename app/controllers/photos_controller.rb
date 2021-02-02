class PhotosController < ApplicationController
  before_action :set_photo
  before_action :authenticate_user!
  load_and_authorize_resource

  def create
    @photo = Photo.create(images: photo_params[:images])
    if @photo.valid?
      post = @photo.posts.new(content: photo_params[:posts_attributes]['0'][:content])
      post.user_id = photo_params[:posts_attributes]['0'][:user_id]
      if post.save
        flash[:success] = "post를 저장했습니당"
        redirect_to root_path
      else
        flash[:alert] = "post 저장 실패!!!!!"
        redirect_back(fallback_location: new_photo_url)
      end
    else
      flash[:alert] = "정상적인 이미지 파일이 아니네요!"
      redirect_to root_path
    end
  end

  private

  def set_photo
  end

  def photo_params
    params.require(:photo).permit(posts_attributes: [:user_id, :content], images: [])
  end
end
