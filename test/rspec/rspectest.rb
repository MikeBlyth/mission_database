#require File.expand_path('../boot', __FILE__)
require 'rails/all'
require "~/documents/SIMDB/SIM2/app/models/member.rb"
require "~/documents/SIMDB/SIM2/config/application.rb"
SIM::Application.initialize!

class Member
  # This is a bit tricky because member and family are related in two ways.
  # * A member BELONGS to a family through family_id (everyone belongs to a family)
  # * A family BELONGS to a member through :head_id  (a family belongs to the head of the family)
  # When creating a new member, the user should be able to assign him/her to an existing family.
  # If that is not done, then the new member should constitute his own family 
  # So the logic of what we're doing in before_ and after_save is:
  # 1) If the member does not have an existing one
  #    - save the new family record with a DUMMY head_id since we don't know the member's id yet
  #    - relate the member to the new family through self.family_id = my_own_family.id
  #    - make the member head of his/her own family
  def before_save
    if family_id.nil? ||  family.nil?
      my_own_family = Family.create(:head_id=>99999, :status_id => self.status_id)
      self.family_id = my_own_family.id
      self.family_head = true
    end
  end    

  # AFTER saving the member, we just need to be sure that the family record
  #   points to this member if the member is marked as head of family.
  #   (All members without a family are marked as head-of-family in before_save, above.)
  def after_save
    if family_head && family.head != self.id
      self.family.update_attributes(:head_id => self.id)
    end
      f = self.family
  end
end ########

describe "Member" do
  it "should make a new family for itself when saved without a family" do
    m = Member.new(:last_name=>"Bee", :first_name=>"O", :country_id=>4, :family_id=>nil, :family_head=>false)
p m.class
    m.save
    f = m.family
    f.should_not == nil
    m.destroy
  end
end 
  
