  ActionMailer::Base.smtp_settings = {
    :address        => "smtp.sendgrid.net",
    :port           => "25",
    :authentication => :plain,
    :user_name      => 'SENDGRID_USERNAME',
    :password       => 'SENDGRID_PASSWORD',
    :domain         => 'SENDGRID_DOMAIN'
  }

vars = [ 
         %w(twilio_id LongRandomHex),
         %w(click_user DonaldDuck),
         %w(click_pwd click_pwd),
         %w(click_api 12345),
         %w(click_client_id XYZ992),
         %w(twilio_api_version 2010-04-01),
         %w(twilio_account_sid AcctSID),
         %w(twilio_account_token RandomString),
         %w(twilio_phone_number +15555555555),
         %w(sendgrid_username suchandso),
         %w(sendgrid_password sosecret),
         %w(sendgrid_domain heroku.com)
        ]
        
vars.each {|v| Configurable.create(:name=>v[0], :value=>v[1])}

