source 'https://rubygems.org'
source 'https://rails-assets.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.1'
gem 'pg', '~> 0.18'
gem 'puma', '~> 3.0'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'jquery-rails'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

gem 'devise'
gem 'slim'
gem 'pg_search'
gem 'acts-as-taggable-on'

# frontend
gem 'bootstrap-sass'
gem 'bootstrap_helper', '~> 4.2.3'
gem 'rails-assets-bootstrap-flat'
gem 'bootstrap-select-rails'

gem 'will_paginate'
gem 'will_paginate-bootstrap'

group :development, :test do
  gem 'rspec-rails', '>= 3.1.0'
  # gem 'rspec-rails-mocha', '~> 0.3.1', require: false
  gem 'factory_girl_rails'
  gem 'database_cleaner'
  gem 'guard-rspec', '>= 4.3.1'
  gem 'faker'
  gem 'rubocop'
  gem 'rubocop-rspec'
  gem 'capybara', '~> 2.5'
  gem 'poltergeist', '~> 1.8'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'annotate'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
