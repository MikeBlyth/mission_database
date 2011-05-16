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
      @family = Factory(:family)
      @head = @family.head
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

  it 'identifies current, past and future terms' do
    pending
  end

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
  

