# lib/middleware/force_ssl.rb
class ForceSSL
  def initialize(app)
    @app = app
  end
 
  def call(env)
    if env['HTTPS'] == 'on' || env['HTTP_X_FORWARDED_PROTO'] == 'https'
      @app.call(env)
    else
      req = Rack::Request.new(env)
      [301, { "Location" => req.url.gsub(/^http:/, "https:") }, []]
    end
  end
end
 
# config/application.rb
config.autoload_paths += %W( #{ config.root }/lib/middleware )
 
# config/environments/production.rb
config.middleware.use "ForceSSL"
