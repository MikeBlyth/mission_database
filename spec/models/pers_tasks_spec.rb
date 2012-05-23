require 'spec_helper'

describe PersTask do
  before(:each) do
    @t1 = PersTask.create(:task=>'pipeline_1', :pipeline=>true)
    @t2 = PersTask.create(:task=>'pipeline_2', :pipeline=>true)
    @x1 = PersTask.create(:task=>'orientation_1', :orientation=>true)
    @x2 = PersTask.create(:task=>'orientation_2', :orientation=>true)
#    @all_tasks = PersTaskArray[@t1, @t2, @x1, @x2]
    @finished_string = "#{@t1.id},#{@t2.id}"
  end

  it 'returns hash of tasks' do
    result = PersTask.tasks_w_finished_marked('')
    result[0][:type].should == :pipeline
    result_tasks = result[0][:tasks]
    result_tasks.should include @t1
    result_tasks.should include @t2
    result_tasks.should_not include @x1
    result_tasks.should_not include @x2
    result_tasks = result[1][:tasks]
    result_tasks.should include @x1
    result_tasks.should include @x2
    result_tasks.should_not include @t1
    result_tasks.should_not include @t2
    result[2][:tasks].should be_empty
  end

  it 'returns hash of tasks with finished flags correct' do
    result = PersTask.tasks_w_finished_marked(@finished_string)
    result_tasks = result[0][:tasks]
    result_tasks[0].finished.should be_true
    result_tasks[1].finished.should be_true
    result_tasks = result[1][:tasks]
    result_tasks[0].finished.should be_false
    result_tasks[1].finished.should be_false
  end
#  it 'task_ids returns list of task ids for given type' do
#    result =  @all_tasks.tasks_with_type(:pipeline)
#puts "**** result=#{result}"
#    result.should include @t1
#    result.should include @t2
#    result.should_not include @x1
#    result.should_not include @x2
#  end    
#  
#  it 'tasks_hash returns an ordered array of all tasks by type' do
#  # result[0] should be {:type=>:pipeline, :tasks=>[@t1, @t2]}
#  # result[1] should be {:type=>:orientation, :tasks=>[@x1, @x2]}
#  # result[2] should be {:type=>:start_of_term, :tasks=>[]}
#    result =  @all_tasks.tasks_hash
## puts "**** result=#{result}"
#    result[0][:type].should == :pipeline
#    result_tasks = result[0][:tasks]
#    result_tasks.should include @t1
#    result_tasks.should include @t2
#    result_tasks.should_not include @x1
#    result_tasks.should_not include @x2
#    result_tasks = result[1][:tasks]
#    result_tasks.should include @x1
#    result_tasks.should include @x2
#    result_tasks.should_not include @t1
#    result_tasks.should_not include @t2
#    result[2][:tasks].should be_empty
#  end
#      
#  it 'generates string w ids of finished tasks' do
#    @t1.finished = true
#    @x1.finished = true
#    result =  @all_tasks.finished_tasks_string
#    result.should == "#{@t1.id},#{@x1.id}"
#  end

end
