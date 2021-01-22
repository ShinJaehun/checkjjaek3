class UsersController < ApplicationController
    before_action :set_user

    load_and_authorize_resource

    def show
      # user show에서 해당 사용자에게 남긴 메시지를 확인할 수 있음.
      @receive_messages = Message.where(receiver_id: @user.id)
      @posts = @user.posts.where.not(postable_type: 'Message').or(Post.where(postable: @receive_messages)).order(created_at: :desc)

      # 다른 사용자에게 message 남기기
      @message = Message.new
      @message.posts.new
    end

    def follow
      @user.toggle_follow(current_user)
      redirect_back(fallback_location: root_path)
    end

    private

    def set_user
        @user = User.find(params[:id])
    end
end
