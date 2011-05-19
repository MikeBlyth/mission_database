describe StatusList do
  include SimTestHelper
  
  describe 'initializes' do
    
    it "with today's date" do
      status_list = StatusList.new
      status_list.date.should == Date.today
    end
    
    it 'as hash of all active members' do
      @inactive_status = Factory(:status_inactive)
      @member = Factory(:family_active).head
      @member2 = Factory(:member, :family=>@member.family)
      @member_inactive = Factory(:member, :family=>@member.family, :status=>@inactive_status)
      status_list = StatusList.new
      status_list[@member.id].should == @member
      status_list[@member2.id].should == @member2
      status_list.length.should == 2
    end
  end # "initializes"
  
      
  it 'counts members within a given set of statuses' do
    @status_1 = Factory(:status)
    @status_2 = Factory(:status)
    @member = Factory(:family_active, :status=>@status_1).head
    @member2 = Factory(:member, :family=>@member.family, :status=>@status_2)
    @member3 = Factory(:member, :family=>@member.family, :status=>@status_2)
    status_list = StatusList.new
    status_list.status_count([@status_1.id]).should == 1
    status_list.status_count([@status_2.id]).should == 2
    status_list.status_count([@status_1.id, @status_2.id]).should == 3
  end

  describe 'advancing to next day' do
    before(:each) do
      @status_home_assignment = Factory(:status_home_assignment)
      @status_field = Factory(:status, :on_field=>true)
      @member = Factory(:family_active, :status=>@status_home_assignment).head
      @status_list = StatusList.new
    end
  
    it 'changes the date to the next day' do
      @status_list.advance
      @status_list.date.should == Date.tomorrow
    end

    it 'changes status to "on field" on start of new term' do
      new_term = Factory(:field_term, :start_date=>Date.tomorrow, :member=>@member)
      @status_list[@member.id].status.should == @status_home_assignment
      @status_list.advance
      @status_list[@member.id].status.should == @status_field
    end

    it 'changes status to "on field" on estimated start of new term' do
      new_term = Factory(:field_term, :est_start_date=>Date.tomorrow,
                        :start_date => nil, :member=>@member)
      @status_list[@member.id].status.should == @status_home_assignment
      @status_list.advance
      @status_list[@member.id].status.should == @status_field
    end

    it 'does not change to "on field" based on est_start date if start_date is later' do
      new_term = Factory(:field_term, :est_start_date=>Date.tomorrow, :start_date=>Date.today+10.days, :member=>@member)
      @status_list[@member.id].status.should == @status_home_assignment
      @status_list.advance
      @status_list[@member.id].status.should == @status_home_assignment
    end

    # This would apply to overlapping (incorrect) field terms, or when est_start_date != start_date,
    # or if a travel record has already had the effect of changing the status to home assignment
    it 'leaves "home assignment" unchanged on end of term' do
      new_term = Factory(:field_term, :end_date=>Date.tomorrow, :member=>@member)
      @status_list[@member.id].status.should == @status_home_assignment
      @status_list.advance
      @status_list[@member.id].status.should == @status_home_assignment
    end

    it 'changes status to "home assignment" at end of term' do
      @member.update_attribute(:status, @status_field)  # start with member on the field
      @status_list = StatusList.new  # have to reset to get the new value installed
      new_term = Factory(:field_term, :end_date=>Date.tomorrow, :member=>@member)
      @status_list[@member.id].status.should == @status_field
      @status_list.advance
      @status_list[@member.id].status.should == @status_home_assignment
    end

    it 'changes status to "home assignment" at estimated end of term' do
      @member.update_attribute(:status, @status_field)  # start with member on the field
      @status_list = StatusList.new  # have to reset to get the new value installed
      new_term = Factory(:field_term, :end_date => nil, :est_end_date=>Date.tomorrow, :member=>@member)
      @status_list[@member.id].status.should == @status_field
      @status_list.advance
      @status_list[@member.id].status.should == @status_home_assignment
    end

    it 'leaves status "on field" unchanged at beginning of term' do
      @member.update_attribute(:status, @status_field)  # start with member on the field
      @status_list = StatusList.new  # have to reset to get the new value installed
      new_term = Factory(:field_term, :start_date=>Date.tomorrow, :member=>@member)
      @status_list[@member.id].status.should == @status_field
      @status_list.advance
      @status_list[@member.id].status.should == @status_field
    end

    it 'does not change status when there is no field_term for that day' do
      @status_list[@member.id].status.should == @status_home_assignment
      @status_list.advance
      @status_list[@member.id].status.should == @status_home_assignment
    end
  end #advancing to next day      
end

