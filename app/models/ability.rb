class Ability
  include CanCan::Ability

  def initialize(user)

    if not user.nil?
      if user.is_admin?
        can :manage, User
        can :manage, Batch
      else
        can :read, Batch
      end
    end

  end
end
