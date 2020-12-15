class UsersController < ApplicationController
    before_action :set_user

    load_and_authorize_resource

    def show
        @posts = @user.posts.order(created_at: :desc)
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
