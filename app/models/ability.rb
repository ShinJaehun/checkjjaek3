# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, :all

    if user.present?
      if user.has_role?(:admin)
        can :manage, :all
      end

      can :manage, Post, user_id: user.id
      can :like, Post

      can :update, User, id: user.id
      can :follow, User do |u|
        u != user
      end

      can :create, Comment
      can :reply, Comment
      can :destroy, Comment, user_id: user.id
      can :update, Comment, user_id: user.id

      can :book_search, Book
      can :manage, Book
      can :manage, Message
      can :manage, Photo

      can :manage, Group, id: Group.with_role(:group_manager, user).pluck(:id)
      #이렇게 하면 approve 가능....ㅠㅠ
      can :leave_group, Group, id: Group.with_role(:group_member, user).pluck(:id)

      can :manage, Post do |p|
        p.post_recipient_type == "Group" && user.has_role?(:group_manager, Group.find(p.post_recipient_group.recipient_group_id))
      end
      # 드디어 성공! 삭제 가능!

#      can :manage, Post do |p|
#        Group.with_role(:group_manager, user).pluck(:id).include?(p.post_recipient_group.recipient_group_id)
#        # post update는 되는데..
#        # post delete하면 post 아니면 post_recipient_group이 먼저 삭제되어서...
#        # nil의 recipient_group_id가 없다고....
#      end

#      if user.groups.pluck(:id) == Group.with_role(:group_manager, user).pluck(:id)
#        can :manage, Post
#      end
      #이렇게 하니까 approve 안되는디

#      if user.has_role?(:group_manager, Group)
#        can :manage, Group
#      else
#        if user.has_role?(:group_member, Group)
#          can :manage, Post, user_id: user.id
#        else
#          can :read, Post
#        end
#        can :read, Group
#      end

      #can :manage, Group, id: user.group_ids
      #can :manage, Group, id: Group.with_role(:group_manager, user).pluck(:id)

    end
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
  end
end
