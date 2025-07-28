# frozen_string_literal: true

require "simplecov"

if ENV["COVERAGE"]
  SimpleCov.start do
    add_filter "/spec/"
    add_filter "/vendor/"
    
    add_group "Library", "lib"
    
    minimum_coverage 90
    enable_coverage :branch
  end
end

require "wittyflow"
require "webmock/rspec"
require "vcr"

# Require all support files
Dir[File.expand_path("support/**/*.rb", __dir__)].each { |f| require f }

VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.default_cassette_options = {
    record: :once,
    match_requests_on: [:method, :uri, :body]
  }
  
  # Filter sensitive data
  config.filter_sensitive_data("<APP_ID>") { ENV["WITTYFLOW_APP_ID"] || "test_app_id" }
  config.filter_sensitive_data("<APP_SECRET>") { ENV["WITTYFLOW_APP_SECRET"] || "test_app_secret" }
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on Module and main
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Filter out bundler backtrace
  config.filter_gems_from_backtrace "bundler"

  # Run specs in random order to surface order dependencies
  config.order = :random
  Kernel.srand config.seed

  # Allow focusing on specific tests
  config.filter_run_when_matching :focus

  config.before(:each) do
    # Reset configuration before each test
    Wittyflow.configuration = nil
  end
end