class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy, :like]

  before_action :authenticate_user!

  load_and_authorize_resource

  # GET /posts
  # GET /posts.json
  def index
    # follower 수를 기준으로 한 추천 사용자
    @suggested_friends_by_followers =  User.all.sort{|a,b| b.followers.count <=> a.followers.count}.first(10)
    # 최근 책짹
    @recent_posts = Post.where(postable_type: "Book").order(id: :desc).limit(10);
    # 가장 많은 좋아요를 받은 책짹
    @favorite_posts = Post.where(postable_type: "Book").sort{|a,b| b.like_users.count <=> a.like_users.count}.first(10)

    #@posts = Post.where(user_id: current_user.followees.ids.push(current_user.id)).order(created_at: :desc) #원래 이거였음(followees 피드 저장)
    #@posts = Post.where(user_id: current_user.followees.ids.push(current_user.id)).or(Post.where(postable_type: "Message")) #Message 유형의 post 추가
    #@posts = Post.where(postable_type: "Message") #Message만 보기
    
    #@messages = Message.where(receiver_id: current_user.id) #일단 이렇게 하면 정상적으로 메시지를 찾기는 함.... 여기서 메시지의 ID를 얻어내야 하는가?
    #@posts = Post.where(postable_type: "Message", postable_id: @messages.ids)
    # 중요한 테스트를 해봐야 하는데 만일 Message 모델에 추가한 receiver_id와sender_id 관련 내용을 삭제한다면 올바른 @messages를 찾아낼 수 있는 것인가? => 이거 필요 없음.....

    @receive_messages = Message.where(receiver_id: current_user.id)
    #@posts = Post.where(user_id: current_user.followees.ids.push(current_user.id)).or(Post.where(postable_type: "Message", postable_id: @receive_messages.ids)).order(created_at: :desc) # 일단 성공/followees 피드에 user_id에 해당하는 post가 저장되니까... 문제 발생
    #@posts = Post.where(user_id: current_user.followees.ids.push(current_user.id)).where.not(postable_type: "Message") # messages는 출력하지 않아요...
    #@posts = Post.where(user_id: current_user.followees.ids.push(current_user.id)).where(postabled: @receive_messages) # AND 조건이기 때문에 내가 나한테 남긴 글만 보임(postable_type이 book인 post는 아예 안 보임) 그리고 이건 준우님이 가르쳐주신 Post.where(postable: @messages) object 자체를 조건으로 사용하기...
    @posts = Post.where(user_id: current_user.followees.ids.push(current_user.id)).where.not(postable_type: 'Message').or(Post.where(postable: @receive_messages)).order(created_at: :desc)

    @message = Message.new
    @message.posts.new

    @photo = Photo.new
    @photo.posts.new
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
  end

  # GET /posts/1/edit
  def edit
    @posts = Post.where(postable_id: @post.postable.id).order(created_at: :desc)

    redirect_to root_path and return unless (current_user.has_role? :admin or @post.user == current_user)
  end

  # PATCH/PUT /posts/1
  # PATCH/PUT /posts/1.json
  def update
    respond_to do |format|
      if @post.update(post_params)
        # format.html { redirect_to @post, notice: 'Post was successfully updated.' }
        format.html { redirect_to root_path, notice: 'Post was successfully updated.' }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    if @post.postable_type == 'Photo'
      @post.postable.images.each do |image|
        # s3에서 해당 이미지 삭제하기...
        # image.purge_later # 이게 더 나은 방법이라고는 하는데 여러 이미지 파일이 있을 때는 transaction 문제
        image.purge
      end
    end
    @post.postable.destroy
    # @post 삭제할 때 postable 삭제하지 않으면 postable은 그대로 유지됨
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url, notice: 'Post was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # POST /posts/:id/like
  def like
    @post.toggle_like(current_user)
    redirect_back(fallback_location: root_path)
  end

  def hashtags
    @tag = Tag.find_by(name: params[:name])
    @posts = @tag.posts.order(created_at: :desc)
  end

  def search
    if params.has_key?(:keyword)
      @keyword = params[:keyword]

      if @keyword.present?
        @searched_users = User.where('name like ?', "%#{@keyword}%").order(created_at: :desc)
        @searched_books = Book.where('title like ?', "%#{@keyword}%").order(created_at: :desc)
        @searched_posts = Post.where('content like ?', "%#{@keyword}%").order(created_at: :desc)
      end

    end

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def post_params
      #params.require(:post).permit(:content)
      #params.require(:post).permit(:content, :book_id)
      params.require(:post).permit(:content)
    end
end
