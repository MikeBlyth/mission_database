require 'spec_helper'

describe AppLog do
  it 'truncates messages to fit' do
    entry = AppLog.create(:code => "SMS.sent.#{@gateway_name}", :description=>'x'*300)
    entry.description.size.should < 256
  end
    
end
