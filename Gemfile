source 'https://rubygems.org'
ruby '1.9.3' #Keep this at 1.9.3 for Heroku San's sake until this issue is fixed: https://github.com/heroku/toolbelt/issues/63

gem 'rails', '3.2.14'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'pg'


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'

  gem 'bourbon'
  gem 'knockoutjs-rails'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'

  gem 'heroku_san'
end

gem 'jquery-rails'
gem 'foreigner'
gem 'classy_enum'

gem 'newrelic_rpm'

# Use unicorn as the app server
gem 'unicorn'
gem 'rack-timeout'
