def term_info
  return {:member=>@head,
          :employment_status=>Factory(:employment_status), 
          :ministry=>Factory(:ministry), 
          :primary_work_location=>Factory(:location)}
end  

describe FieldTerm do
  include SimTestHelper

  describe "New field term" do
  
    before(:each) do
      @head = Factory(:member)
      @info_1 = term_info
      @info_2 = term_info  # new information for second term
      @term_1 = Factory(:field_term, @info_1.merge({:start_date => Date.today-5.years, 
                        :end_date => Date.today - 3.years}))
      @term_2 = Factory(:field_term, @info_2.merge({:start_date => Date.today-2.years, 
                       :end_date => Date.today - 1.years}))
    end

    it "copies info from latest term into new record" do
      new_term = @head.field_terms.new
      new_term.should be_valid
      new_term.employment_status.should == @term_2.employment_status
      new_term.ministry.should == @term_2.ministry
      new_term.primary_work_location.should == @term_2.primary_work_location
    end

    it "does not copy from latest term into record retrieved from database" do
      @term_1.reload
      @term_1.employment_status.should == @info_1[:employment_status]
    end  
    
  end

  describe 'gives best_start_date as start_date or, if absent, est_start_date' do

    it 'uses start_date if est_start_date not present' do
     term = Factory.stub(:field_term, :start_date=>Date.today, :est_start_date=>nil)
     term.best_start_date.should == Date.today
    end

    it 'uses start_date if est_start_date is different' do
     term = Factory.stub(:field_term, :start_date=>Date.today, :est_start_date=>Date.tomorrow)
     term.best_start_date.should == Date.today
    end

    it 'uses est_start_date if start_date is not present' do
     term = Factory.stub(:field_term, :start_date=>nil, :est_start_date=>Date.tomorrow)
     term.best_start_date.should == Date.tomorrow
    end

    it 'is nil if neither start_date nor est_start_date is present' do
     term = Factory.stub(:field_term, :start_date=>nil, :est_start_date=>nil)
     term.best_start_date.should be_nil
    end
  end # gives best_start_date

  describe 'gives best_end_date as end_date or, if absent, est_end_date' do

    it 'uses end_date if est_end_date not present' do
     term = Factory.stub(:field_term, :end_date=>Date.today, :est_end_date=>nil)
     term.best_end_date.should == Date.today
    end

    it 'uses end_date if est_end_date is different' do
     term = Factory.stub(:field_term, :end_date=>Date.today, :est_end_date=>Date.tomorrow)
     term.best_end_date.should == Date.today
    end

    it 'uses est_end_date if end_date is not present' do
     term = Factory.stub(:field_term, :end_date=>nil, :est_end_date=>Date.tomorrow)
     term.best_end_date.should == Date.tomorrow
    end

    it 'is nil if neither end_date nor est_end_date is present' do
     term = Factory.stub(:field_term, :end_date=>nil, :est_end_date=>nil)
     term.best_end_date.should be_nil
    end
  end # gives best_end_date

  describe 'identifies current, past and future terms' do
    before(:each) do
      @future_1 = Factory.stub(:field_term, :start_date=>Date.today+2.days, :end_date=>nil)
      @future_2 = Factory.stub(:field_term, :start_date=>nil, :est_start_date=>Date.today+2.days, 
                               :end_date=>Date.tomorrow + 1.year)
      @current_1 = Factory.stub(:field_term, :start_date=>Date.today-2.days, :end_date=>nil)
      @current_2 = Factory.stub(:field_term, :start_date=>Date.today-2.days, :end_date=>Date.tomorrow + 1.year)
      @current_3 = Factory.stub(:field_term, :start_date=>nil, :end_date=>Date.tomorrow + 1.year)
      @past_1 = Factory.stub(:field_term, :start_date=>Date.yesterday-1.year, :end_date=>Date.today-2.days)
      @past_2 = Factory.stub(:field_term, :start_date=>nil, :end_date=>Date.today-2.days)
      @future = [@future_1, @future_2]
      @current = [@current_1, @current_2, @current_3]
      @past = [@past_1, @past_2]
    end

    it 'identifies current terms' do
      @current.each {|f| f.current?.should be_true}
      (@future+@past).each {|f| f.current?.should be_false}
    end

    it 'identifies future terms' do
      @future.each {|f| puts "#{f.best_start_date}-#{f.best_end_date}"; f.future?.should be_true}
      (@current+@past).each {|f| f.future?.should be_false}
    end

    it 'identifies past terms' do
      @past.each {|f| f.past?.should be_true}
      (@current+@future).each {|f| f.past?.should be_false}
    end

  end #identifies current, past and future terms

  # Field_term model has a comparison operator (<=>) that compares by whichever dates are available
  it "compares by date" do
    today = Date.today
    long_ago = Date.today - 1.year
    a = FieldTerm.new(:start_date => today)
    b = FieldTerm.new(:start_date => long_ago)
    (a <=> b).should == 1
    b.est_start_date = long_ago
    b.start_date = nil
    (a <=> b).should == 1
    b.end_date = long_ago
    b.est_start_date = nil
    (a <=> b).should == 1
    b.end_date = nil
    b.est_end_date = long_ago
    (a <=> b).should == 1
    a.start_date = nil
    a.end_date = today        
    (a <=> b).should == 1
    b.end_date = today
    (a <=> b).should == 0
    b.end_date = today + 1.day
    (a <=> b).should == -1
  end  

end
  

