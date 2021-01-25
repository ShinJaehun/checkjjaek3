class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_commentable
  before_action :set_comment, only: [ :reply, :edit, :update, :destroy ]

  load_and_authorize_resource

  def reply
    @reply = @commentable.comments.build(parent: @comment)
  end

  def create
    @comment = @commentable.comments.new(comment_params)
    @comment.user = current_user
    @comment.save

  end

  def edit
  end

  def update
   # @comment.update(comment_params)
    respond_to do |format|
      if @comment.update(comment_params)
        format.html { redirect_to @comment.commentable, notice: "Comment was successfully updated."}
        format.json { render json: @comment }
        format.js
      else
        format.html { redirect_to @comment.commentable, notice: "Comment was not updated." }
        format.json { render json: @comment.errors }
        format.js
      end
    end
  end

  def destroy
    @comment.destroy if @comment.errors.empty?
    respond_to do |format|
      format.html { redirect_to @commentable, notice: "Comments was successfully destroyed."}
      format.json { head :no_content }
      format.js
    end
  end

  private

  def set_commentable
    resource, id = request.path.split('/')[1,2]
#    puts("===================================")
#    puts("resource : " + resource)
#    puts("id : " + id.to_s)
#    puts("===================================")
    @commentable = resource.singularize.classify.constantize.find(id)
  end

  def set_comment
    begin
      @comment = @commentable.comments.find(params[:id])
    rescue => e
      logger.error "#{e.class.name} : #{e.message}"
      @comment = @commentable.comments.build
      @comment.error.add(:base, :recordnotfound, message: "That record doesn't exist. Maybe it is already destroyed.")
    end
  end

  def comment_params
    params.require(:comment).permit(:content, :parent_id)
  end

  def comments
    Comment.where(commentable: commentable, parent_id: id)
  end

end
