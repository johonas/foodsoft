# A sample Gemfile
source "https://rubygems.org"

gem "rails", '~> 4.2'

gem 'sass-rails'
gem 'uglifier', '>= 1.0.3'

gem 'jquery-rails'
gem 'select2-rails'
gem 'rails_tokeninput'
gem 'bootstrap-datepicker-rails'
gem 'date_time_attribute'
gem 'rails-assets-listjs', '0.2.0.beta.4' # remember to maintain list.*.js plugins and template engines on update
gem 'i18n-js', '~> 3.0.0.rc8'
gem 'rails-i18n'

gem 'mysql2', '~> 0.4.0' # for compatibility with rails 4
gem 'prawn'
gem 'prawn-table'
gem 'haml', '~> 4.0' # some breaking changes in version 5, remove this line again when fixed
gem 'haml-rails'
gem 'kaminari'
gem 'simple_form'
gem 'inherited_resources'
gem 'localize_input', git: "https://github.com/bennibu/localize_input.git"
gem 'daemons'
gem 'doorkeeper'
gem 'doorkeeper-i18n'
gem 'rack-cors', require: 'rack/cors'
gem 'active_model_serializers', '~> 0.10.0'
gem 'twitter-bootstrap-rails', '~> 2.2.8'
gem 'simple-navigation', '~> 3.14.0' # 3.x for simple_navigation_bootstrap
gem 'simple-navigation-bootstrap'
gem 'ransack'
gem 'acts_as_tree'
gem 'rails-settings-cached', '= 0.4.3' # caching breaks tests until Rails 5 https://github.com/huacnlee/rails-settings-cached/issues/73
gem 'resque'
gem 'thin'
gem 'whenever', require: false # For defining cronjobs, see config/schedule.rb
gem 'protected_attributes', '= 1.1.0' # 1.1.0 until tests work work with higher versions
gem 'ruby-units'
gem 'attribute_normalizer'
gem 'ice_cube'
gem 'recurring_select'
gem 'roo'
gem 'roo-xls'
gem 'spreadsheet'
gem 'exception_notification'
gem 'gaffe'
gem 'ruby-filemagic'
gem 'midi-smtp-server'
gem 'rubyzip'

gem 'caxlsx'
gem 'caxlsx_rails'

# we use the git version of acts_as_versioned, and need to include it in this Gemfile
gem 'acts_as_versioned', git: 'https://github.com/technoweenie/acts_as_versioned.git'
gem 'foodsoft_wiki', path: 'plugins/wiki'
gem 'foodsoft_messages', path: 'plugins/messages'
gem 'foodsoft_documents', path: 'plugins/documents'
gem 'foodsoft_discourse', path: 'plugins/discourse'

# plugins not enabled by default
#gem 'foodsoft_current_orders', path: 'plugins/current_orders'
#gem 'foodsoft_uservoice', path: 'plugins/uservoice'


group :development do
  gem 'mailcatcher'
  gem 'web-console', '~> 2.0'

  # allow to use `debugger` https://github.com/conradirwin/pry-rescue
  gem 'pry-rescue'
  gem 'pry-stack_explorer'

  # Better error output
  gem 'better_errors'
  gem 'binding_of_caller'
  # gem "rails-i18n-debug"
  # chrome debugging extension https://github.com/dejan/rails_panel
  gem 'meta_request'

  # Get infos when not using proper eager loading
  gem 'bullet'

  # Hide assets requests in log
  gem 'quiet_assets'
end

group :development, :test do
  gem 'ruby-prof', require: false
  gem 'byebug'
end

group :test do
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'connection_pool'
  # need to include rspec components before i18n-spec or rake fails in test environment
  gem 'rspec-core', '~> 3.2'
  gem 'i18n-spec'
  # code coverage
  gem 'simplecov', require: false
  gem 'coveralls', require: false
end

# belongs to group :test, but outside for heroku
gem 'rspec-rerun'
