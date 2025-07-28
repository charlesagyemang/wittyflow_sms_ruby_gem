# frozen_string_literal: true

# config/initializers/wittyflow.rb
# 
# Wittyflow SMS Gem Configuration
# This initializer sets up the Wittyflow SMS service for your Rails application

Wittyflow.configure do |config|
  # Required: Your Wittyflow API credentials
  # Get these from your Wittyflow dashboard
  config.app_id = Rails.application.credentials.wittyflow_app_id || ENV["WITTYFLOW_APP_ID"]
  config.app_secret = Rails.application.credentials.wittyflow_app_secret || ENV["WITTYFLOW_APP_SECRET"]

  # Optional: API endpoint (default is production endpoint)
  # config.api_endpoint = "https://api.wittyflow.com/v1"

  # Optional: Request timeout in seconds (default: 30)
  config.timeout = 30

  # Optional: Number of retries for failed requests (default: 3)
  config.retries = 3

  # Optional: Delay between retries in seconds (default: 1)
  config.retry_delay = 1

  # Optional: Default country code for phone number formatting (default: "233" for Ghana)
  config.default_country_code = "233"

  # Optional: Custom logger (default: Logger to STDOUT)
  # Use Rails logger in Rails applications
  config.logger = Rails.logger

  # Optional: Set log level for Wittyflow-specific logs
  # config.logger.level = Logger::INFO
end

# Validate configuration in development and production
if Rails.env.development? || Rails.env.production?
  unless Wittyflow.config.valid?
    Rails.logger.warn "Wittyflow configuration is invalid. SMS functionality will not work."
    Rails.logger.warn "Please ensure WITTYFLOW_APP_ID and WITTYFLOW_APP_SECRET are set."
  end
end

# Example: Test the configuration in development
if Rails.env.development? && Wittyflow.config.valid?
  Rails.application.configure do
    config.after_initialize do
      begin
        client = Wittyflow::Client.new
        # You can uncomment the line below to test account balance on startup
        # balance = client.account_balance
        # Rails.logger.info "Wittyflow account balance: #{balance}"
        Rails.logger.info "Wittyflow SMS gem initialized successfully"
      rescue Wittyflow::Error => e
        Rails.logger.warn "Wittyflow initialization test failed: #{e.message}"
      end
    end
  end
end