class MessagesController < ApplicationController
  before_action :set_message
  before_action :authenticate_user!
  load_and_authorize_resource

#  별도로 message new view를 띄우지 않기로 했음!
#  def new
#    puts '#########################################################'
#    puts 'New ACTION'
#    @message = Message.new
#    @message.posts.new
#    puts '#########################################################'
#
#  end
  
  def create
#    puts '#########################################################'
#    puts 'CREATE ACTION'
#    # 얘는 message에 해당하는 sender_id와 receiver_id 밖에 없음...
#    puts message_params
#    puts message_params[:posts_attributes]
#    puts message_params[:posts_attributes]['0']
#    puts '#########################################################'

#    @message = Message.create(
#      sender_id: message_params[:sender_id],
#      receiver_id: message_params[:receiver_id])

    @message = Message.create()


#    puts '#########################################################'
#    puts params[:receiverrr_id]
#    puts '#########################################################'
    r_id = params[:receiverrr_id]
    post = @message.posts.new(content: message_params[:posts_attributes]['0'][:content])
    post.post_recipient_type = message_params[:posts_attributes]['0'][:post_recipient_type]
    #post.user_id = message_params[:posts_attributes]['0'][:user_id]
    post.user_id = current_user.id
    post.save

    if post.post_recipient_type == 'group'

      post_recipient_group = PostRecipientGroup.new
      post_recipient_group.post_id = post.id
      #post_recipient_group.recipient_group_id = message_params[:posts_attributes]['0'][:receiver_id]
      #post_recipient_group.recipient_group_id = params[:receiver_id]
#    puts '#########################################################'
#    puts r_id
#    puts '#########################################################'
      post_recipient_group.recipient_group_id = r_id
      post_recipient_group.save
      redirect_back(fallback_location: groups_path, flash: {notice: "그룹에 글을 작성했습니다."})

    elsif post.post_recipient_type =='user'
      post_recipient_user = PostRecipientUser.new
      #post_recipient_user.recipient_user_id = @message.receiver_id
      post_recipient_group.recipient_user_id = message_params[:posts_attributes]['0'][:receiver_id]
      post_recipient_user.post_id = post.id
      post_recipient_user.save

#    puts message_params[:sender_id]
#    puts message_params[:receiver_id]

      if message_params[:sender_id] != message_params[:receiver_id]
        # 다른 사용자에게 보낸 메시지라면 redirect 그 사용자에게...
        redirect_to user_path(message_params[:receiver_id])
      else
        rediredt_to root_path
      end

    else
      redirect_to root_path, flash: { alert: "그룹 또는 사용자에게 글 남기기 실패" }
    end

  end

  private

  def set_message
#    puts '#########################################################'
#    puts 'set_message'
#    puts '#########################################################'
  end

  def message_params
    #sender_id와 receiver_id 없어져야 함...
    #user_id도 current_id로 대처할꺼니까 여기서 strong으로 넘길 필요 없음...
    #params.require(:message).permit(:sender_id, :receiver_id, posts_attributes: [:user_id, :content])
    params.require(:message).permit(posts_attributes: [:content, :post_recipient_type])
  end
end
