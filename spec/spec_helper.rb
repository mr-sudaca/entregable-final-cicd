# frozen_string_literal: true

# --- Coverage must start before loading the app ---
require "simplecov"
require "simplecov_json_formatter"

SimpleCov.formatter = SimpleCov::Formatter::JSONFormatter
SimpleCov.root Dir.pwd
SimpleCov.formatter = SimpleCov::Formatter::JSONFormatter  # optional: creates coverage/coverage.json
SimpleCov.track_files "**/*.rb"
SimpleCov.start do
  add_filter(%r{(^|/)spec/spec_helper\.rb$}) # ignore only spec_helper.rb
end

# --- Bundler and gems ---
require "bundler/setup"
Bundler.require(:default, :test)

# --- Ensure reports dir exists (for the Sonar test-exec XML) ---
require "fileutils"
FileUtils.mkdir_p("reports")

# --- Test-only env vars (fake values) ---
ENV["RACK_ENV"] = "test"
ENV["SESSION_SECRET"] = "test-session-secret-key-for-testing-0123456789-ABCDEFGHIJKLMNOPQRSTUVWXYZ-abcdef"
ENV["CHATGPT_KEY"]    = "fake-api-key-for-testing"

# --- Load your app AFTER SimpleCov.start ---
require_relative "../app"
require_relative "../searcher"

# --- Capybara configuration for browser testing ---
require "capybara/rspec"
require "selenium-webdriver"

# Configure for remote testing if REMOTE_URL is set
if ENV['REMOTE_URL']
  Capybara.app_host = ENV['REMOTE_URL']
  Capybara.run_server = false
  puts "🌐 Running browser tests against remote URL: #{ENV['REMOTE_URL']}"
else
  Capybara.app = App
  Capybara.server = :puma, { Silent: true }
  puts "🏠 Running browser tests against local app"
end

Capybara.default_driver = :selenium_chrome_headless
Capybara.javascript_driver = :selenium_chrome_headless

# Configure Chrome options for headless testing
Capybara.register_driver :selenium_chrome_headless do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument("--headless")
  options.add_argument("--no-sandbox")
  options.add_argument("--disable-dev-shm-usage")
  options.add_argument("--disable-gpu")
  options.add_argument("--window-size=1280,720")
  
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

# Set default wait time for AJAX requests
Capybara.default_max_wait_time = 10

# --- RSpec configuration ---
RSpec.configure do |config|
  # Use the Sonar test-execution formatter (no explicit require needed)
  config.add_formatter "RspecSonarqubeFormatter", "reports/sonar-test-report.xml"

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = "spec/examples.txt"
  config.disable_monkey_patching!
  config.warnings = true
  config.default_formatter = "doc" if config.files_to_run.one?
  config.profile_examples = 10
  config.order = :random
  Kernel.srand config.seed
end

