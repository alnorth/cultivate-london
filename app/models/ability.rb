class Ability
  include CanCan::Ability

  def initialize(user)

    if not user.nil?
      if user.is_admin?
        can :manage, User
      end
      can :manage, Batch
    end

  end
end
