# Be sure to restart your server when you modify this file.

SIM::Application.config.session_store :cookie_store, 
    :key => '_SIM_session',
    :secure => Rails.env.production?, # Only send cookie over SSL when in production mode
    :http_only => true # Don't allow Javascript to access the cookie (mitigates cookie-based XSS exploits)

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# SIM::Application.config.session_store :active_record_store
