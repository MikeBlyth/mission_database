class Ability
  include CanCan::Ability
  include AuthorizationHelper
  
  def initialize(user)
#    user ||= User.new # guest user (not logged in)
    if user.nil?
      cannot :manage, :all
      return
    end

# puts "****** Initialize user #{user.name}, admin=#{user.admin?}, travel=#{user.travel?}"      
    # First the basics
    if user.admin?
      can :manage, :all
    # In production, may want to include something like
    #      cannot :manage, [:medical, :personnel] 
    #  if we don't want system admin to have access to these
    else
      can :read, :all
      can :update, User
      cannot :read, [HealthData, PersonnelData]  # Confidential fields
    end

# Then some fine-tuning
    if user.personnel?
      can :manage, :all
      cannot [:create, :update, :destroy], [Bloodtype, Role]
    end

    if user.asst_personnel? # Personnel assistant
      can :manage, [Family, Member, Contact]
    end
    
    if user.medical?
      can :manage, [Member, Bloodtype, HealthData]
      cannot [:create, :destroy], [Member]
    end

    if user.travel?
      can :manage, Travel
    end    
    
  end  # initialize
end # class

