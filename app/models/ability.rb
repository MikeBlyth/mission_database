class Ability
  include CanCan::Ability
  include AuthorizationHelper
  
  def initialize(user)
#    user ||= User.new # guest user (not logged in)
    if user.nil?
      cannot :manage, :all
      return
    end

puts "****** Initialize user #{user.name}, admin=#{user.admin?}, travel=#{user.travel?}"      
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

# Then some fine-tuning
    if user.personnel?
      can :manage, :all
      cannot :manage, [:bloodtype, :role, :medical]
      can :read, :bloodtype, :medical     # assuming this is ok
    end
    
    if user.medical?
      can :manage, [:medical, :bloodtype]
    end

    if user.travel?
puts "This user can manage travel!"
      can :manage, [:bloodtype, :city, :contact, :country, :family, :field_term] 

    end    
    
  end  # initialize
end # class

