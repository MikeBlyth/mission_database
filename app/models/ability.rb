class Ability
  include CanCan::Ability
  include AuthorizationHelper
  
  def initialize(user)
#    user ||= User.new # guest user (not logged in)
    if user.nil?
puts "No user!"
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
      return
    else
      can :read, :all
      can :update, [User, Message]
      can :create, Message
      can :manage, CalendarEvent
      cannot :manage, [HealthData, PersonnelData]  # Confidential fields
    end

# Here are the models, taken from authorization_helper for reference when editing the abilities
#MODELS = [:bloodtype, :city, :contact, :contact_type, :country, :education, :employment_status, :family, :field_term] + 
#         [:health_data, :location, :member, :ministry, :personnel_data, :pers_task, :role, :state, :status] +
#         [:travel, :user]

# Then some fine-tuning
    if user.personnel?
      can :manage, :all
      cannot :manage, [HealthData]
      # Not updating role means Personnel can add users to this database but they will only have the minimum
      # (or default) role. Only Admin can give users roles like Personnel, Travel, Health etc.
      cannot [:create, :update, :destroy], [Bloodtype, Role]
    end

    if user.asst_personnel? # Personnel assistant
      # Personnel assistant can't manage the lookup tables such as locations, statuses
      can :manage, [Family, Member, Contact, PersonnelData, FieldTerm]
    end
    
    if user.medical?
      can :manage, [Bloodtype, HealthData]
      can :update, Member
    end

    if user.travel?
      # This allows travel people to fully manage Family and Member so they can add members who aren't
      # already on the list. However, to be more strict, one could require that someone with 
      # personnel privileges add the family & member, and allow travel only to assign their travel trips.
      can :manage, [Travel, Family, Member]
    end    
    
  end  # initialize
end # class

