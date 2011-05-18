require 'spec_helper'

describe "EmploymentStatuses" do

  describe 'filters:' do
    before(:each) do
      @member = Factory(:employment_status, :org_member=>true, :umbrella=>false, :current_use=>true)
      @umbrella = Factory(:employment_status, :org_member=>false, :umbrella=>true, :current_use=>true)
      @associate = Factory(:employment_status, :org_member=>true, :umbrella=>false, :current_use=>true)
      @visitor = Factory(:employment_status, :org_member=>false, :umbrella=>true, :current_use=>true)
      @unused = Factory(:employment_status, :org_member=>true, :umbrella=>false, :current_use=>false)
    end
    
    it 'returns "member of organization" (org_member) statuses' do
      statuses = EmploymentStatus.org_statuses
      targets = [@member, @associate, @unused]
      statuses.length.should == targets.length
      targets.each {|e| statuses.should include(e.id)}
    end

    it 'returns "member of organization" (org_member) statuses' do
      statuses = EmploymentStatus.umbrella_statuses
      targets = [@umbrella, @visitor]
      statuses.length.should == targets.length
      targets.each {|e| statuses.should include(e.id)}
    end
  end     
end
