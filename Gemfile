source 'http://rubygems.org'

gem 'rails', '~> 3.2'
#gem "active_scaffold_vho"
#gem 'active_scaffold_config_list_vho'
gem 'active_scaffold', :git => 'git://github.com/activescaffold/active_scaffold.git'


gem 'pg'
#gem 'pdf-inspector', :git => "git://github.com/sandal/pdf-inspector.git"
gem 'prawn', "0.11.1"# , :git => "git://github.com/sandal/prawn" #, :submodules => true
gem 'haml' 
#gem 'jquery-rails'
#gem 'render_component_vho'
#gem 'active_scaffold_vho'
#gem 'jrails'
gem 'cancan'
#gem "meta_where"  # Last officially released gem
gem 'chronic'
gem 'rack-ssl-enforcer'
gem 'settingslogic', "2.0.8"
gem 'sass'
gem 'bourbon'
gem 'twiliolib'
gem 'httparty'
#gem 'jammit'
gem 'rake'
gem 'thin', :platforms => :ruby
#gem "progstr-filer", :require => "progstr-filer"  # File attachment & storage -- experimental
gem "escape_utils" # I think this is a temp fix. See http://crimpycode.brennonbortz.com/?p=42

group :assets do
  gem 'sass-rails'#,   "~> 3.1.5"
  gem 'coffee-rails'#, "~> 3.1.1"
  gem 'uglifier'#,     ">= 1.0.3"
end

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :development, :test do
  gem 'annotate'
#  gem "rcov"
  # To use debugger
#  gem 'debugger'
  gem 'pry'
  gem 'pry-debugger'
end

group :test do
  gem "spork"
#  gem 'cover_me'
#  gem "shoulda-matchers"

  gem "selenium-client", ">= 1.2.18"
  gem "database_cleaner", ">= 0.5.2"
  gem "launchy"
  gem "factory_girl", "2.0.0.beta1"
  gem "factory_girl_rails", "1.1.beta1"
  gem "rspec-rails"
  gem 'xpath' # Should not be needed but for now capybara chokes without it.
  gem "capybara"
  gem "cucumber-rails", ">=1.1.1"
  gem "autotest"
  gem "redgreen"
  gem "test-unit"#, "1.2.3"
  gem "guard-rspec"
  gem "ruby_gntp"
  gem 'guard-livereload'  # https://github.com/guard/guard-livereload
  gem 'guard-spork' 
end

# gem "unobtrusive_date_picker", :git => "git://github.com/scambra/unobtrusive_date_picker.git"


