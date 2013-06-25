source 'https://rubygems.org'
ruby '1.9.3'

platforms :ruby do
  gem 'pry', :group => :development
  gem 'yard', :group => :development
  gem 'redcarpet', :group => :development
end

group :production do
  gem 'thin'
end

group :test do
  gem 'rspec'
  gem 'rack-test'
  gem 'sqlite3'
end

gem 'pg'
gem 'sinatra'
gem 'sinatra-activerecord'

# Specify your gem's dependencies in puppet_community_data.gemspec
gemspec
