# frozen_string_literal: true

require "net/http"
require "timeout"

module Wittyflow
  class Client
    include HTTParty

    attr_reader :app_id, :app_secret, :config

    def initialize(app_id: nil, app_secret: nil, **options)
      @app_id = app_id || Wittyflow.config.app_id
      @app_secret = app_secret || Wittyflow.config.app_secret
      @config = build_config(options)

      validate_credentials!
      setup_httparty
    end

    # Send regular SMS
    def send_sms(from:, to:, message:)
      send_message(from: from, to: to, message: message, type: :regular)
    end

    # Send flash SMS (appears directly on screen)
    def send_flash_sms(from:, to:, message:)
      send_message(from: from, to: to, message: message, type: :flash)
    end

    # Check SMS delivery status
    def message_status(message_id)
      validate_presence!(:message_id, message_id)

      url = "#{config.api_endpoint}/messages/#{message_id}/retrieve"
      params = auth_params

      with_error_handling do
        response = self.class.get(url, query: params, timeout: config.timeout)
        parse_response(response)
      end
    end

    # Get account balance
    def account_balance
      url = "#{config.api_endpoint}/account/balance"
      params = auth_params

      with_error_handling do
        response = self.class.get(url, query: params, timeout: config.timeout)
        parse_response(response)
      end
    end

    # Send bulk SMS to multiple recipients
    def send_bulk_sms(from:, to:, message:, type: :regular)
      validate_presence!(:from, from)
      validate_presence!(:to, to)
      validate_presence!(:message, message)

      recipients = Array(to).map { |phone| format_phone_number(phone) }

      recipients.map do |recipient|
        send_message(from: from, to: recipient, message: message, type: type)
      end
    end

    private

    def build_config(options)
      config = Configuration.new
      config.api_endpoint = options[:api_endpoint] || Wittyflow.config.api_endpoint
      config.timeout = options[:timeout] || Wittyflow.config.timeout
      config.retries = options[:retries] || Wittyflow.config.retries
      config.retry_delay = options[:retry_delay] || Wittyflow.config.retry_delay
      config.logger = options[:logger] || Wittyflow.config.logger
      config.default_country_code = options[:default_country_code] || Wittyflow.config.default_country_code
      config
    end

    def setup_httparty
      self.class.base_uri config.api_endpoint
      self.class.headers({
                           "Content-Type" => "application/x-www-form-urlencoded",
                           "Accept" => "application/json",
                           "User-Agent" => "Wittyflow Ruby Gem #{Wittyflow::VERSION}"
                         })
    end

    def validate_credentials!
      raise ConfigurationError, "app_id is required" if app_id.nil? || app_id.empty?
      raise ConfigurationError, "app_secret is required" if app_secret.nil? || app_secret.empty?
    end

    def validate_presence!(field, value)
      raise ValidationError, "#{field} is required" if value.nil? || value.to_s.empty?
    end

    def send_message(from:, to:, message:, type:)
      validate_presence!(:from, from)
      validate_presence!(:to, to)
      validate_presence!(:message, message)

      formatted_to = format_phone_number(to)

      body = {
        from: from.to_s,
        to: formatted_to,
        message: message.to_s,
        type: type == :flash ? 0 : 1,
        app_id: app_id,
        app_secret: app_secret
      }

      url = "#{config.api_endpoint}/messages/send"

      with_error_handling do
        response = self.class.post(url, body: body, timeout: config.timeout)
        parse_response(response)
      end
    end

    def format_phone_number(phone)
      phone_str = phone.to_s.strip

      # Remove any non-digit characters except +
      phone_str = phone_str.gsub(/[^\d+]/, "")

      # Handle different phone number formats
      case phone_str
      when /^\+233/ # International format for Ghana
        phone_str.sub(/^\+/, "")
      when /^233/ # Ghana country code without +
        phone_str
      when /^0/ # Local format starting with 0
        "#{config.default_country_code}#{phone_str[1..]}"
      else # Assume it's a local number without leading 0
        "#{config.default_country_code}#{phone_str}"
      end
    end

    def auth_params
      {
        app_id: app_id,
        app_secret: app_secret
      }
    end

    def with_error_handling
      attempts = 0
      begin
        attempts += 1
        yield
      rescue Net::OpenTimeout, Net::ReadTimeout, Net::WriteTimeout, Timeout::Error => e
        raise NetworkError, "Network timeout: #{e.message}"
      rescue HTTParty::Error, SocketError => e
        unless attempts < config.retries
          raise NetworkError, "Network error after #{config.retries} attempts: #{e.message}"
        end

        config.logger&.warn(
          "Request failed (attempt #{attempts}/#{config.retries}), " \
          "retrying in #{config.retry_delay}s: #{e.message}"
        )
        sleep(config.retry_delay)
        retry
      rescue Wittyflow::Error => e
        # Re-raise our custom errors without modification
        raise e
      rescue StandardError => e
        raise APIError, "Unexpected error: #{e.message}"
      end
    end

    def parse_response(response)
      case response.code
      when 200..299
        response.parsed_response
      when 401
        raise AuthenticationError, "Invalid app_id or app_secret"
      when 400
        error_message = response.parsed_response&.dig("message") || "Bad request"
        raise ValidationError, error_message
      when 429
        raise APIError, "Rate limit exceeded"
      when 500..599
        raise APIError, "Server error (#{response.code})"
      else
        raise APIError, "Unexpected response (#{response.code}): #{response.body}"
      end
    end
  end
end
