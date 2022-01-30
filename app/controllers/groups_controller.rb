class GroupsController < ApplicationController
  #before_action :set_group, only: %i[ show edit update destroy ]
  before_action :set_group, except: %i[ index new create ]
  before_action :authenticate_user!
  #devise 로그인 사용자만 메서드 사용 가능
  load_and_authorize_resource except: %i[ new create join_group apply_group cancel_apply_group approve_group ]
  #cancancan
  #new create join leave를 제외하고 허가된 사용자만 메서드를 사용할 수 있음
  #근데 왜 index는 except하지 않아도 모든 그룹을 다 볼 수 있는거지?

  # GET /groups or /groups.json
  def index
    #@groups = Group.find(current_user.user_groups.where.not(state: 'pending').pluck(:group_id))
    #@groups = Group.where(id: current_user.user_groups.where.not(state: 'pending').pluck(:group_id), group_state: 'active')
    @groups = Group.where(id: current_user.user_groups.where(state: 'active').pluck(:group_id), group_state: 'active')

    if current_user.has_role? :admin
      @pending_groups = Group.where(group_state: 'pending')
#    puts '#########################################################'
#    puts @pending_groups
#    puts '#########################################################'
    else
      @pending_groups = Group.where(id: current_user.user_groups.pluck(:group_id), group_state: 'pending')
    end

    @suggested_groups = Group.where(group_state: 'active').order(created_at: :desc).first(10)

    #.where(id: PostRecipientGroup.where(recipient_group_id: current_user.groups.ids).pluck(:post_id))
    # pending 그룹은 제외해야하기 때문에...
    @posts = Post
      .where(id: PostRecipientGroup.where(recipient_group_id: current_user.user_groups.where.not(state: 'pending').pluck(:group_id)).pluck(:post_id))
      .where.not(id: PostRecipientGroup.where(recipient_group_id: current_user.groups.where(group_state: 'pending').pluck(:group_id)).pluck(:post_id))
      .order(created_at: :desc)
 #     .where(id: PostRecipientGroup.where(recipient_group_id: current_user.groups.where(group_state: 'active').pluck(:group_id)).pluck(:post_id))
 #     두번째 줄 대신 이렇게 작성하는 건 어떤가?
  end

  # GET /groups/1 or /groups/1.json
  def show
    if @group.group_state == "pending"
      redirect_to groups_url, alert: "#{@group.name} 동아리는 승인 대기 상태입니다."
    else
      #@posts = Post.find(@group.post_recipient_groups.pluck(:post_id))
      @posts = Post.where(id: @group.post_recipient_groups.pluck(:post_id))
        .order(created_at: :desc)

      #@pending_users = User.includes(:user_groups).where("user_groups.state": "pending")
      #이렇게 하면 사용자가 다른 그룹에서 pending하고 있어도 몽땅 pending_users에 포함됨
      #@pending_users = User.find(@group.user_groups.where(state: "pending").pluck(:user_id))
      #구현할 수 있는 다양한 방법을 알아두는게 필요하긴 한데
      #뭐가 더 나은 방법인가?

      if current_user.has_role? :group_manager, @group
        @users = @group.users
      else
        @users = User.find(@group.user_groups.where(state: "active").pluck(:user_id))
      end

      @message = Message.new
      @message.posts.new

      @photo = Photo.new
      @photo.posts.new
    end
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

    if current_user.has_role? :admin
      @group.group_state = "active"
    else
      @group.group_state = "pending"
    end

    if Group.find_by(name: @group.name).present?
      flash.new[:danger] = "That group name has already been taken."
      render :new
    else
      if @group.save
        usergroup = UserGroup.new
        usergroup.user_id = current_user.id
        usergroup.group_id = @group.id
        usergroup.state = "active"
        usergroup.save

        current_user.add_role :group_manager, @group
        current_user.add_role :group_member, @group

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
    if current_user.has_role? :group_manager, @group
      if User.find(@group.user_groups.where(state: "active").pluck(:user_id)).count == 1 and 
          @group.user_groups.where(state: "active").pluck(:user_id).first == current_user.id
        # group_member가 단 한명이고 그게 나라면 삭제 가능

        # group/user_groups/post_recipient_groups 모두 삭제
        # post_recipient_groups와 연결된 posts는 그대로 남아 있음...
        # 삭제할 그룹의 포스트 먼저 모두 삭제하고 group 삭제
        # 언젠가 혹시 모를 일에 대비하기 위해 posts는 그대로 놔둬야 하는가?
        posts = Post.find(@group.post_recipient_groups.pluck(:post_id))
        unless posts.blank?
          posts.each do |p|
            p.destroy
          end
        end

        @group.destroy
        redirect_to groups_url, notice: "Group was successfully destroyed."
      else
        redirect_to group_url(@group), alert: "group_manager를 제외하고 group_member가 존재하면 그룹 삭제 불가"
      end

    else
      redirect_to group_url(@group), alert: "group_manager가 아님"
    end
  end

  def apply_group
    if UserGroup.where(user_id: current_user.id, group_id: @group.id).count <= 0
      usergroup = UserGroup.new
      usergroup.user_id = current_user.id
      usergroup.group_id = @group.id
      usergroup.state = "pending"
      usergroup.save

      redirect_to @group, notice: "You've been applied for #{@group.name}."
    else
      redirect_to groups_path, alert: "You're already a member of #{@group.name}."
    end
  end

  def cancel_apply_group
    apply_user = User.find(params[:apply_user_id])

    usergroup = apply_user.user_groups.find_by_group_id(@group.id)
    if usergroup.state == "pending" && usergroup.user_id == apply_user.id && usergroup.group_id == @group.id
      usergroup.destroy
      redirect_to group_path, notice: "Applying has been canceled."
    else
      redirect_to @group, alert: "user/group 오류 또는 active 상태가 아님"
    end
  end

  def approve_user
    approve_user = User.find(params[:approve_user_id])

    if current_user.has_role? :group_manager, @group
      usergroup = approve_user.user_groups.find_by_group_id(@group.id)

      if usergroup.state == "pending" && usergroup.user_id == approve_user.id && usergroup.group_id == @group.id
        usergroup.state = "active"
        usergroup.save
        approve_user.add_role :group_member, @group
        redirect_to @group, notice: "#{approve_user.name}'s been approved."
      else
        redirect_to @group, alert: "user/group 오류 또는 pending 상태가 아님"
      end
    else
      redirect_to @group, alert: "group_manager가 아님"
    end
  end

  def resume_user
    resume_user = User.find(params[:resume_user_id])

    if current_user.has_role? :group_manager, @group
      usergroup = resume_user.user_groups.find_by_group_id(@group.id)

      if usergroup.state == "suspend" && usergroup.user_id == resume_user.id && usergroup.group_id == @group.id
        usergroup.state = "active"
        usergroup.save
        resume_user.add_role :group_member, @group
        redirect_to @group, notice: "#{resume_user.name}'s been resumed."
      else
        redirect_to @group, alert: "user/group 오류 또는 pending 상태가 아님"
      end
    else
      redirect_to @group, alert: "group_manager가 아님"
    end
  end

  def suspend_user
    suspend_user = User.find(params[:suspend_user_id])

    if current_user.has_role? :group_manager, @group
      usergroup = suspend_user.user_groups.find_by_group_id(@group.id)

      if usergroup.state == "active" && usergroup.user_id == suspend_user.id && usergroup.group_id == @group.id
        usergroup.state = "suspend"
        usergroup.save
        suspend_user.remove_role :group_member, @group
        redirect_to @group, notice: "#{suspend_user.name}'s been suspended."
      else
        redirect_to @group, alert: "user/group 오류 또는 active 상태가 아님"
      end
    else
      redirect_to @group, alert: "group_manager가 아님"
    end
  end

  def join_group
    if UserGroup.where(user_id: current_user.id, group_id: @group.id).count <= 0
      usergroup = UserGroup.new
      usergroup.user_id = current_user.id
      usergroup.group_id = @group.id
      usergroup.state = "active"
      usergroup.save

      current_user.add_role :group_member, @group
      redirect_to @group, notice: "You've been added to #{@group.name}."
    else
      redirect_to groups_path, notice: "You're already a member of #{@group.name}."
    end
  end

  def leave_group
    unless current_user.has_role? :group_manager, @group
      if current_user.has_role? :group_member, @group
        current_user.remove_role :group_member, @group
        usergroup = current_user.user_groups.find_by_group_id(@group.id)
        if usergroup.state == "active" && usergroup.user_id == current_user.id && usergroup.group_id == @group.id
          usergroup.destroy
          redirect_to groups_path, notice: "You're no longer a member of #{@group.name}."
        else
          redirect_to @group, alert: "user/group 오류 또는 pending 상태가 아님"
        end
      else
        redirect_to @group, alert: "group_member가 아님!"
      end
    else
      redirect_to @group, alert: "group_manager는 탈퇴 불가!"
    end
  end

  def approve_group
    if current_user.has_role? :admin
      if @group.group_state == "pending"
        @group.group_state = "active"
        @group.save
        redirect_to groups_path, notice: "#{@group.name}'s been approved."
      else
        redirect_to groups_path, alert: "group 오류 또는 pending 상태가 아님"
      end
    else
      redirect_to groups_path, alert: "admin이 아님"
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group
      @group = Group.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def group_params
      params.require(:group).permit(:name, :description, :cover_image)
    end
end
