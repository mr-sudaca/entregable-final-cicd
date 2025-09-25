# frozen_string_literal: true

source 'https://rubygems.org'

gem 'newrelic_rpm'
gem 'puma'
gem 'rackup'
gem 'rubocop'
gem 'rubocop-rake', require: false
gem 'ruby-openai'
gem 'sinatra'

group :test do
  gem 'rack-test'
  gem 'rspec'
  gem 'simplecov', '~> 0.21.2'
  gem 'simplecov_json_formatter', '~> 0.1.4'  # ✅ correct formatter
  # Generates Sonar's Generic Test Execution XML (counts, durations)
  gem 'rspec-sonarqube-formatter', '~> 1.6'
  # Browser testing gems
  gem 'capybara'
  gem 'selenium-webdriver'
end
