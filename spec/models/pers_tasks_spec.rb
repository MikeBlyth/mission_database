require 'spec_helper'

describe PersTask do
  before(:each) do
    @t1 = PersTask.create(:task=>'pipeline_1', :pipeline=>true)
    @t2 = PersTask.create(:task=>'pipeline_2', :pipeline=>true)
    @x1 = PersTask.create(:task=>'orientation_1', :orientation=>true)
    @x2 = PersTask.create(:task=>'orientation_2', :orientation=>true)
    @all_tasks = [@t1, @t2, @x1, @x2]
  end

  it 'task_ids returns list of task ids for given type' do
    result =  PersTask.tasks_with_type(@all_tasks, :pipeline)
puts "**** result=#{result}"
    result.should include @t1
    result.should include @t2
    result.should_not include @x1
    result.should_not include @x2
  end    
  
  it 'tasks_hash returns an ordered array of all tasks by type' do
    result =  PersTask.tasks_hash(@all_tasks)
# puts "**** result=#{result}"
    result[0][:type].should == :pipeline
    result[0][:tasks].should include @t1
    result[0][:tasks].should include @t2
  end
      
  it 'xx' do
  end

end
