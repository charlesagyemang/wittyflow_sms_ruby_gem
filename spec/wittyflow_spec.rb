# frozen_string_literal: true

RSpec.describe Wittyflow do
  it "has a version number" do
    expect(Wittyflow::VERSION).not_to be_nil
    expect(Wittyflow::VERSION).to match(/\A\d+\.\d+\.\d+\z/)
  end

  describe ".configure" do
    it "yields a configuration object" do
      expect { |block| described_class.configure(&block) }.to yield_with_args(Wittyflow::Configuration)
    end

    it "sets the configuration" do
      config = described_class.configure do |c|
        c.app_id = "test_id"
        c.app_secret = "test_secret"
      end

      expect(described_class.configuration).to eq(config)
      expect(described_class.configuration.app_id).to eq("test_id")
      expect(described_class.configuration.app_secret).to eq("test_secret")
    end

    it "returns existing configuration when called without block" do
      described_class.configure do |c|
        c.app_id = "test_id"
      end

      config = described_class.configure
      expect(config.app_id).to eq("test_id")
    end
  end

  describe ".config" do
    it "returns configuration" do
      described_class.configure do |c|
        c.app_id = "test_id"
      end

      expect(described_class.config.app_id).to eq("test_id")
    end

    it "creates new configuration if none exists" do
      expect(described_class.config).to be_a(Wittyflow::Configuration)
    end
  end

  describe ".new (backward compatibility)" do
    it "creates a new Client instance" do
      client = described_class.new("app_id", "app_secret")
      expect(client).to be_a(Wittyflow::Client)
    end

    it "passes options to the client" do
      client = described_class.new("app_id", "app_secret", timeout: 60)
      expect(client.config.timeout).to eq(60)
    end
  end

  describe "error classes" do
    it "defines custom error hierarchy" do
      expect(Wittyflow::Error).to be < StandardError
      expect(Wittyflow::ConfigurationError).to be < Wittyflow::Error
      expect(Wittyflow::APIError).to be < Wittyflow::Error
      expect(Wittyflow::NetworkError).to be < Wittyflow::Error
      expect(Wittyflow::AuthenticationError).to be < Wittyflow::Error
      expect(Wittyflow::ValidationError).to be < Wittyflow::Error
    end
  end
end
