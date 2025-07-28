# frozen_string_literal: true

require "zeitwerk"
require "httparty"
require "logger"

loader = Zeitwerk::Loader.for_gem
loader.setup

module Wittyflow
  class Error < StandardError; end
  class ConfigurationError < Error; end
  class APIError < Error; end
  class NetworkError < Error; end
  class AuthenticationError < Error; end
  class ValidationError < Error; end

  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration) if block_given?
    configuration
  end

  def self.config
    configuration || configure
  end

  # For backward compatibility
  def self.new(app_id, app_secret, options = {})
    Client.new(app_id: app_id, app_secret: app_secret, **options)
  end
end
