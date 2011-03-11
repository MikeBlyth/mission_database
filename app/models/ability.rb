class Ability
  include CanCan::Ability

  def initialize(user)
# we have not guests so don't need this line
#    user ||= User.new # guest user (not logged in)
# First the basics
    if user.admin?
      can :manage, :all
# In production, may want to include something like
#      cannot :manage, [:medical, :personnel] 
#  if we don't want system admin to have access to these
    else
      can :read, :all
      cannot :read, [:medical, :personnel]  # Confidential fields
    end

    if user.personnel?
      can :manage, :all
      cannot :manage, [:bloodtype, :role, :medical]
      can :read, :bloodtype, :medical     # assuming this is ok
    end
    
    if user.medical?
      can :manage, [:medical, :bloodtype]
    end

    if user.travel?
      can :manage, :travel
    end    
    
  end  # initialize
end # class

