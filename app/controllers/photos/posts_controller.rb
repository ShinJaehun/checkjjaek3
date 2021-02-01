class Photos::PostsController < PostsController
  before_action :set_postable

  private

  def set_postable
    @postable = Photo.find(params[:photo_id])
  end
end
