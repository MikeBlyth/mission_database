describe 'Predefined date formats' do

  it 'formats dates to_s with these options' do
    date = Date.new(2011, 3, 9)
    date_specs = {
      :int_short => '9 Mar',
      :int_default => '9 Mar 11',
      :int_long => '9 March 2011',
      :short =>'9 Mar',
      :default => '9 Mar 11',
      :long =>'9 March 2011',
      :us_short => 'Mar 9',
      :us_default => 'Mar 9, 2011',
      :us_long => 'March 9, 2011',
      }
    date_specs.each {|spec, result| date.to_s(spec).should == result}
  end
  
  it 'formats times to_s with these options' do
    time = Time.new(2011, 3, 9, 10, 15)
    time_specs = {
      :date_long => '9 March 2011',
      :us_date_long => "March 9, 2011",
      :date => "9 March",
      :us_date => "March 9",
      :time => "10:15 AM",
      }
    time_specs.each {|spec, result| time.to_s(spec).should == result}
  end  
  
end
