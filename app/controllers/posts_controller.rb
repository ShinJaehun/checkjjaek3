class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy, :like]

  before_action :authenticate_user!

  load_and_authorize_resource

  # GET /posts
  # GET /posts.json
  def index
    #@posts = Post.all
    @posts = Post.where(user_id: current_user.followees.ids.push(current_user.id))
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
  end

  # # GET /posts/new
  # def new
  #   @post = Post.new
  # end

  # GET /posts/1/edit
  def edit
  end

  # # POST /posts
  # # POST /posts.json
  # def create
  #   # @post = Post.new(post_params)
  #   @post = current_user.posts.new(post_params)
  #   respond_to do |format|
  #     if @post.save
  #       format.html { redirect_to @post, notice: 'Post was successfully created.' }
  #       format.json { render :show, status: :created, location: @post }
  #     else
  #       format.html { render :new }
  #       format.json { render json: @post.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # PATCH/PUT /posts/1
  # PATCH/PUT /posts/1.json
  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to @post, notice: 'Post was successfully updated.' }
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def post_params
      #params.require(:post).permit(:content)
      params.require(:post).permit(:content, :book_id)
    end
end
