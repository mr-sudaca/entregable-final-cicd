# frozen_string_literal: true

# --- Coverage must start before loading the app ---
require "simplecov"
require "simplecov_json_formatter"

SimpleCov.formatter = SimpleCov::Formatter::JSONFormatter
SimpleCov.start do
  add_filter "spec"
end

# --- Bundler and gems ---
require "bundler/setup"
Bundler.require(:default, :test)

# --- Ensure reports dir exists (for the Sonar test-exec XML) ---
require "fileutils"
FileUtils.mkdir_p("reports")

# --- Test-only env vars (fake values) ---
ENV["SESSION_SECRET"] = "test-session-secret-key-for-testing"
ENV["CHATGPT_KEY"]    = "fake-api-key-for-testing"

# --- Load your app AFTER SimpleCov.start ---
require_relative "../app"
require_relative "../searcher"

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
