describe SiteSetting do
  include SimTestHelper
  
  it 'initializes from config file' do
    # Look for a value we know is defined in config/site_settings.yml
    # Could extend the test by actually writing something to the file first
    SiteSetting.birthday_prefix.should_not be_nil
  end
  
  it 'saves new value in database' do
    SiteSetting.create(:name=>'birthday_prefix', :value=>'new prefix')
    SiteSetting.birthday_prefix.should == 'new prefix'
  end
  
  it 'raises exception on reference to value not in config file' do
    expect {SiteSetting[:something_undefined]}.to raise_error(/not found/)
  end

end
    

