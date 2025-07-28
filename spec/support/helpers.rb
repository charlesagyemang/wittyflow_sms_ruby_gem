# frozen_string_literal: true

module SpecHelpers
  def valid_app_id
    "test_app_id_123"
  end

  def valid_app_secret
    "test_app_secret_456"
  end

  def valid_phone_number
    "0241234567"
  end

  def formatted_phone_number
    "233241234567"
  end

  def sample_message
    "Hello, this is a test message from Wittyflow!"
  end

  def mock_successful_response(data = {})
    {
      status: "success",
      message: "Request processed successfully",
      data: data
    }
  end

  def mock_error_response(message = "An error occurred")
    {
      status: "error",
      message: message
    }
  end

  def configure_wittyflow(options = {})
    Wittyflow.configure do |config|
      config.app_id = options[:app_id] || valid_app_id
      config.app_secret = options[:app_secret] || valid_app_secret
      config.api_endpoint = options[:api_endpoint] || "https://api.wittyflow.com/v1"
      config.timeout = options[:timeout] || 30
      config.retries = options[:retries] || 3
      config.retry_delay = options[:retry_delay] || 1
      config.logger = options[:logger] || Logger.new(nil)
      config.default_country_code = options[:default_country_code] || "233"
    end
  end

  def stub_wittyflow_request(method, endpoint, response_body: {}, status: 200, headers: {})
    url = "https://api.wittyflow.com/v1#{endpoint}"
    
    default_headers = {
      "Content-Type" => "application/json"
    }.merge(headers)

    stub_request(method, url)
      .to_return(
        status: status,
        body: response_body.to_json,
        headers: default_headers
      )
  end
end

RSpec.configure do |config|
  config.include SpecHelpers
end