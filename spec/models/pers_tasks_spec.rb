require 'spec_helper'

describe PersTask do
  before(:each) do
    @t1 = PersTask.create(:task=>'t1', :pipeline=>true)
    @t2 = PersTask.create(:task=>'t1', :pipeline=>true)
    @x1 = PersTask.create(:task=>'t1', :orientation=>true)
    @x2 = PersTask.create(:task=>'t1', :orientation=>true)
  end

  it 'returns list of task ids for given type' do
    PersTask.task_ids(:pipeline).sort.should == [@t1.id, @t2.id].sort
    PersTask.task_ids(:orientation).sort.should == [@x1.id, @x2.id].sort
  end    
  
  it 'returns an ordered array of all tasks by type' do
puts "**** PersTask.tasks_hash=#{PersTask.tasks_hash}"
    PersTask.tasks_hash[0][:type].should == :pipeline
    PersTask.tasks_hash[0][:ids].sort.should == [@t1.id, @t2.id].sort
  end
      

end
