# frozen_string_literal: true

RSpec.describe Wittyflow::Configuration do
  subject(:config) { described_class.new }

  describe "#initialize" do
    it "sets default values" do
      expect(config.api_endpoint).to eq("https://api.wittyflow.com/v1")
      expect(config.timeout).to eq(30)
      expect(config.retries).to eq(3)
      expect(config.retry_delay).to eq(1)
      expect(config.default_country_code).to eq("233")
      expect(config.logger).to be_a(Logger)
    end

    it "sets logger level to INFO by default" do
      expect(config.logger.level).to eq(Logger::INFO)
    end
  end

  describe "#valid?" do
    context "when app_id and app_secret are present" do
      before do
        config.app_id = "test_id"
        config.app_secret = "test_secret"
      end

      it "returns true" do
        expect(config.valid?).to be true
      end
    end

    context "when app_id is missing" do
      before do
        config.app_secret = "test_secret"
      end

      it "returns false" do
        expect(config.valid?).to be false
      end
    end

    context "when app_secret is missing" do
      before do
        config.app_id = "test_id"
      end

      it "returns false" do
        expect(config.valid?).to be false
      end
    end

    context "when app_id is empty" do
      before do
        config.app_id = ""
        config.app_secret = "test_secret"
      end

      it "returns false" do
        expect(config.valid?).to be false
      end
    end

    context "when app_secret is empty" do
      before do
        config.app_id = "test_id"
        config.app_secret = ""
      end

      it "returns false" do
        expect(config.valid?).to be false
      end
    end
  end

  describe "attr_accessors" do
    it "allows setting and getting all configuration attributes" do
      config.app_id = "new_id"
      config.app_secret = "new_secret"
      config.api_endpoint = "https://custom.api.com"
      config.timeout = 60
      config.retries = 5
      config.retry_delay = 2
      config.default_country_code = "234"

      expect(config.app_id).to eq("new_id")
      expect(config.app_secret).to eq("new_secret")
      expect(config.api_endpoint).to eq("https://custom.api.com")
      expect(config.timeout).to eq(60)
      expect(config.retries).to eq(5)
      expect(config.retry_delay).to eq(2)
      expect(config.default_country_code).to eq("234")
    end

    it "allows setting custom logger" do
      custom_logger = Logger.new(StringIO.new)
      config.logger = custom_logger

      expect(config.logger).to eq(custom_logger)
    end
  end
end