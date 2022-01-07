class GroupsController < ApplicationController
  before_action :set_group, only: %i[ show edit update destroy ]

  # GET /groups or /groups.json
  def index
    @groups = Group.all
  end

  # GET /groups/1 or /groups/1.json
  def show
    @posts = Post.find(@group.post_recipient_groups.pluck(:post_id))
    @message = Message.new
    @message.posts.new
  end

  # GET /groups/new
  def new
    @group = Group.new
  end

  # GET /groups/1/edit
  def edit
  end

  # POST /groups or /groups.json
  def create
    @group = Group.new(group_params)

    if Group.find_by(name: @group.name).present?
      flash.new[:danger] = "That group name has already been taken."
      render :new
    else
      if @group.save
        usergroup = UserGroup.new
        usergroup.user_id = current_user.id
        usergroup.group_id = @group.id
        #usergroup.state = "active"
        usergroup.save

        #current_user.add_role :group_manager, @group
        #current_user.add_role :group_menber, @group

        redirect_to @group, noitce: "Group was successfully created."

      else
        flash.new[:danger] = "Group creation failed."
        render :new
      end
    end
  end

  # PATCH/PUT /groups/1 or /groups/1.json
  def update
    respond_to do |format|
      if @group.update(group_params)
        format.html { redirect_to group_url(@group), notice: "Group was successfully updated." }
        format.json { render :show, status: :ok, location: @group }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /groups/1 or /groups/1.json
  def destroy
    @group.destroy

    respond_to do |format|
      format.html { redirect_to groups_url, notice: "Group was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def join_group
    if UserGroup.where(user_id: current_user.id, group_id: @group.id).count <= 0
      usergroup = UserGroup.new
      usergroup.user_id = current_user.id
      usergroup.group_id = @group.id
      usergroup.save

      #current_user.add_role :group_member, @group
      redirect_to @group, notice: "You've been added to #{@group.name}."
    else
      redirect_to groups_path, notice: "You're already a member of #{@group.name}."
    end
  end

  def leave_group
#    if !current_user.has_role? :group_manager, @group
#      if current_user.has_role? :group_member, @group
#        current_user.remove_role :group_member, @group
        usergroup = current_user.user_groups.find_by_group_id(@group.id)
        usergroup.destroy
        redirect_to groups_path, notice: "You're no longer a member of #{@group.name}."

#      end
#    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group
      @group = Group.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def group_params
      params.require(:group).permit(:name, :description)
    end
end
