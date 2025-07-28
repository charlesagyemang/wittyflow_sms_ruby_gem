# frozen_string_literal: true

module Wittyflow
  class Configuration
    attr_accessor :app_id, :app_secret, :api_endpoint, :timeout, :retries, :retry_delay, :logger, :default_country_code

    def initialize
      @api_endpoint = "https://api.wittyflow.com/v1"
      @timeout = 30
      @retries = 3
      @retry_delay = 1
      @logger = Logger.new($stdout, level: Logger::INFO)
      @default_country_code = "233" # Ghana
    end

    def valid?
      !app_id.nil? && !app_secret.nil? && !app_id.empty? && !app_secret.empty?
    end
  end
end
