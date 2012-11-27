# Be sure to restart your server when you modify this file.

SIM::Application.config.session_store :cookie_store, 
    :key => '_missdb_sess',
    :secure => Rails.env.production?, # Only send cookie over SSL when in production mode
    :http_only => true, # Don't allow Javascript to access the cookie (mitigates cookie-based XSS exploits)
    :expire_after => Rails.env.production? ? 14400 : 86400 # 4 hours/24 hours
SIM::Application.config.secret_token = 'jklweoiuWMf;lk4760V302-098sqvngpo-5$YbN,uyQsxuwpp[n,s16v,sy/,/xs5-_'

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# SIM::Application.config.session_store :active_record_store
