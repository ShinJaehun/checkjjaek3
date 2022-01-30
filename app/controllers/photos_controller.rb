class PhotosController < ApplicationController
  before_action :set_photo
  before_action :authenticate_user!
  load_and_authorize_resource

  def create
    @photo = Photo.create(images: photo_params[:images])

    r_id = params[:receiverrr_id].to_i

    if @photo.valid?
      post = @photo.posts.new(content: photo_params[:posts_attributes]['0'][:content])
      #post.user_id = photo_params[:posts_attributes]['0'][:user_id]
      post.post_recipient_type = photo_params[:posts_attributes]['0'][:post_recipient_type]
      post.user_id = current_user.id
      post.save

      if post.post_recipient_type == "Group"
        if current_user.has_role? :group_member, Group.find(r_id)
          post_recipient_group = PostRecipientGroup.new
          post_recipient_group.post_id = post.id
          post_recipient_group.recipient_group_id = r_id
          post_recipient_group.save
          redirect_to group_path(r_id), flash: {notice: "그룹에 photo를 작성했습니다."}
        else
          post.postable.destroy
          #이게 없으면 post 작성 실패할 때 message는 생성된 채로 남아 있음
          redirect_back(fallback_location: groups_path, flash: {alert: "group_member가 아니라서 그룹에 photo를 작성할 권한 없음"})
        end
      elsif post.post_recipient_type == "User"
        post_recipient_user = PostRecipientUser.new
        post_recipient_user.post_id = post.id
        post_recipient_user.recipient_user_id = r_id
        post_recipient_user.save

        if current_user.id == r_id
          redirect_to root_path, flash: {notice: "나에게 photo를 작성했습니다."}
        else
          redirect_to user_path(r_id), flash: {notice: "다른 사용자에게 photo를 작성했습니다."}
        end

      else
        redirect_to root_path, flash: { alert: "그룹 또는 사용자에게 message 남기기 실패" }
      end

#      if post.save
#        flash[:success] = "post를 저장했습니당"
#        redirect_to root_path
#      else
#        flash[:alert] = "post 저장 실패!!!!!"
#        redirect_back(fallback_location: new_photo_url)
#      end
    else
      redirect_to root_path, flash: { alert: "정상적인 이미지 파일이 아니네요!" }
    end
  end

  private

  def set_photo
  end

  def photo_params
    params.require(:photo).permit(posts_attributes: [:content, :post_recipient_type], images: [])
  end
end
