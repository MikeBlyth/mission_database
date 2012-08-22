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
    result[0][:type].should == 'pipeline'
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

end
