source 'https://rubygems.org'

gem 'spree', github: 'spree/spree', branch: '2-4-stable'
# Provides basic authentication functionality for testing parts of your engine
gem 'spree_auth_devise', github: 'spree/spree_auth_devise', branch: '2-4-stable'
group :test do
  gem 'vcr'
  gem 'webmock'
end


group :test, :development do
  gem 'dotenv'
  gem 'pry'
end

gemspec
