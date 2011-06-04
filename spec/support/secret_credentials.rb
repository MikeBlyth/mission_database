  ActionMailer::Base.smtp_settings = {
    :address        => "smtp.sendgrid.net",
    :port           => "25",
    :authentication => :plain,
    :user_name      => 'SENDGRID_USERNAME',
    :password       => 'SENDGRID_PASSWORD',
    :domain         => 'SENDGRID_DOMAIN'
  }

vars = [ 
         %w(clickatell_user_name MikeBlyth),
         %w(clickatell_password eCKAH3qXG7lwnGjZ1y),
         %w(clickatell_api_id 3310717),
         %w(clickatell_client_id XYZ992),
         %w(twilio_api_version 2010-04-01),
         %w(twilio_account_sid AcctSID),
         %w(twilio_account_token RandomString),
         %w(twilio_phone_number +15555555555),
         %w(sendgrid_username suchandso),
         %w(sendgrid_password sosecret),
         %w(outgoing_sms clickatell),
         %w(sendgrid_domain heroku.com)
        ]
        
vars.each {|v| SiteSetting.create(:name=>v[0], :value=>v[1])}

puts "Secret Cred: SiteSetting[:clickatell_user_name] = #{SiteSetting[:clickatell_user_name]}"
