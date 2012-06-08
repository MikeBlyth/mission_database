require 'spec_helper'

describe Group do
  
describe 'members_with_subgroups  ' do
    it 'members_with_subgroups finds members in group and subgroups' do
      # Make 3-level group tree from stubs. It ain't pretty but it's pretty fast!
      @top = Factory.build(:group, :group_name=>'top')
      @mid_1 = Factory.build(:group, :group_name=>'mid_1', :parent_group => @top)
      @mid_2 = Factory.build(:group, :group_name=>'mid_2', :parent_group => @top)
      @low_1a = Factory.build(:group, :group_name=>'low_1a', :parent_group => @mid_1)
      @low_1b = Factory.build(:group, :group_name=>'low_1b', :parent_group => @mid_1)
      @low_2a = Factory.build(:group, :group_name=>'low_2a', :parent_group => @mid_2)
      @low_2b = Factory.build(:group, :group_name=>'low_2b', :parent_group => @mid_2)
      @mid_1.subgroups = [@low_1a, @low_1b]
      @mid_2.subgroups = [@low_2a, @low_2b]
      @top.subgroups = [@mid_1, @mid_2]
      @mid_2.stub(:member_ids).and_return([8])
      @low_2a.stub(:member_ids).and_return([6])
      @low_2b.stub(:member_ids).and_return([2,4])
      @mid_1.stub(:member_ids).and_return([3])
      @low_1a.stub(:member_ids).and_return([5])
      @low_1b.stub(:member_ids).and_return([1,7])
      @top.stub(:member_ids).and_return([])

      @low_1a.members_with_subgroups.should == [5]
      @mid_1.members_with_subgroups.sort.should == [1,3,5,7]
      @mid_2.members_with_subgroups.sort.should == [2,4,6,8]
      @top.members_with_subgroups.sort.should == [1,2,3,4,5,6,7,8]
    end
  end # members_with_subgroups 
  
end
