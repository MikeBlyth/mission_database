include SimTestHelper

describe Travel do

before(:each) {@t = Travel.new}

  it 'parses correctly' do
    @t.parse_name('John Q. Adams').should == ['John', 'Q.', 'Adams']
    @t.parse_name('Adams, John').should == ['John', nil, 'Adams']
    @t.parse_name('Adams, John Q. ').should == ['John', 'Q.', 'Adams']
    @t.parse_name('John Adams').should == ['John', nil, 'Adams']
    @t.parse_name('John & Mary Adams').should == ['John & Mary', nil, 'Adams']
    @t.parse_name('John and Mary Adams').should == ['John & Mary', nil, 'Adams']
  end

end

