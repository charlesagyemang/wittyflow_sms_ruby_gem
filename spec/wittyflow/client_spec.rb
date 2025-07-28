# frozen_string_literal: true

RSpec.describe Wittyflow::Client do
  let(:app_id) { valid_app_id }
  let(:app_secret) { valid_app_secret }
  
  subject(:client) { described_class.new(app_id: app_id, app_secret: app_secret) }

  describe "#initialize" do
    context "with valid credentials" do
      it "initializes successfully" do
        expect(client.app_id).to eq(app_id)
        expect(client.app_secret).to eq(app_secret)
        expect(client.config).to be_a(Wittyflow::Configuration)
      end

      it "uses default configuration values" do
        expect(client.config.api_endpoint).to eq("https://api.wittyflow.com/v1")
        expect(client.config.timeout).to eq(30)
        expect(client.config.retries).to eq(3)
      end
    end

    context "with custom options" do
      let(:custom_options) do
        {
          timeout: 60,
          retries: 5,
          api_endpoint: "https://custom.api.com/v1"
        }
      end

      subject(:client) { described_class.new(app_id: app_id, app_secret: app_secret, **custom_options) }

      it "uses custom configuration values" do
        expect(client.config.timeout).to eq(60)
        expect(client.config.retries).to eq(5)
        expect(client.config.api_endpoint).to eq("https://custom.api.com/v1")
      end
    end

    context "with global configuration" do
      before do
        configure_wittyflow(app_id: "global_id", app_secret: "global_secret", timeout: 45)
      end

      it "uses global configuration when no credentials provided" do
        client = described_class.new
        expect(client.app_id).to eq("global_id")
        expect(client.app_secret).to eq("global_secret")
        expect(client.config.timeout).to eq(45)
      end

      it "overrides global configuration with instance credentials" do
        client = described_class.new(app_id: "instance_id", app_secret: "instance_secret")
        expect(client.app_id).to eq("instance_id")
        expect(client.app_secret).to eq("instance_secret")
      end
    end

    context "with missing credentials" do
      it "raises ConfigurationError when app_id is missing" do
        expect {
          described_class.new(app_secret: app_secret)
        }.to raise_error(Wittyflow::ConfigurationError, "app_id is required")
      end

      it "raises ConfigurationError when app_secret is missing" do
        expect {
          described_class.new(app_id: app_id)
        }.to raise_error(Wittyflow::ConfigurationError, "app_secret is required")
      end

      it "raises ConfigurationError when app_id is empty" do
        expect {
          described_class.new(app_id: "", app_secret: app_secret)
        }.to raise_error(Wittyflow::ConfigurationError, "app_id is required")
      end
    end
  end

  describe "#send_sms" do
    let(:from) { "WittyFlow" }
    let(:to) { valid_phone_number }
    let(:message) { sample_message }
    let(:response_body) { mock_successful_response(message_id: "msg_123") }

    before do
      stub_wittyflow_request(:post, "/messages/send", response_body: response_body)
    end

    it "sends SMS successfully" do
      result = client.send_sms(from: from, to: to, message: message)
      expect(result).to eq(response_body)
    end

    it "formats phone number correctly" do
      expect_any_instance_of(described_class).to receive(:format_phone_number).with(to).and_return(formatted_phone_number)
      client.send_sms(from: from, to: to, message: message)
    end

    it "includes correct parameters in request" do
      expected_body = {
        from: from,
        to: formatted_phone_number,
        message: message,
        type: 1,
        app_id: app_id,
        app_secret: app_secret
      }

      stub = stub_request(:post, "https://api.wittyflow.com/v1/messages/send")
        .with(body: expected_body)
        .to_return(status: 200, body: response_body.to_json)

      client.send_sms(from: from, to: to, message: message)
      expect(stub).to have_been_requested
    end

    context "with validation errors" do
      it "raises ValidationError when from is missing" do
        expect {
          client.send_sms(from: nil, to: to, message: message)
        }.to raise_error(Wittyflow::ValidationError, "from is required")
      end

      it "raises ValidationError when to is missing" do
        expect {
          client.send_sms(from: from, to: nil, message: message)
        }.to raise_error(Wittyflow::ValidationError, "to is required")
      end

      it "raises ValidationError when message is missing" do
        expect {
          client.send_sms(from: from, to: to, message: nil)
        }.to raise_error(Wittyflow::ValidationError, "message is required")
      end
    end
  end

  describe "#send_flash_sms" do
    let(:from) { "WittyFlow" }
    let(:to) { valid_phone_number }
    let(:message) { sample_message }
    let(:response_body) { mock_successful_response(message_id: "msg_123") }

    before do
      stub_wittyflow_request(:post, "/messages/send", response_body: response_body)
    end

    it "sends flash SMS successfully" do
      result = client.send_flash_sms(from: from, to: to, message: message)
      expect(result).to eq(response_body)
    end

    it "sets type to 0 for flash SMS" do
      expected_body = {
        from: from,
        to: formatted_phone_number,
        message: message,
        type: 0,
        app_id: app_id,
        app_secret: app_secret
      }

      stub = stub_request(:post, "https://api.wittyflow.com/v1/messages/send")
        .with(body: expected_body)
        .to_return(status: 200, body: response_body.to_json)

      client.send_flash_sms(from: from, to: to, message: message)
      expect(stub).to have_been_requested
    end
  end

  describe "#message_status" do
    let(:message_id) { "msg_123" }
    let(:response_body) { mock_successful_response(status: "delivered") }

    before do
      stub_wittyflow_request(:get, "/messages/#{message_id}/retrieve?app_id=#{app_id}&app_secret=#{app_secret}", response_body: response_body)
    end

    it "retrieves message status successfully" do
      result = client.message_status(message_id)
      expect(result).to eq(response_body)
    end

    it "raises ValidationError when message_id is missing" do
      expect {
        client.message_status(nil)
      }.to raise_error(Wittyflow::ValidationError, "message_id is required")
    end
  end

  describe "#account_balance" do
    let(:response_body) { mock_successful_response(balance: 100.50, currency: "GHS") }

    before do
      stub_wittyflow_request(:get, "/account/balance?app_id=#{app_id}&app_secret=#{app_secret}", response_body: response_body)
    end

    it "retrieves account balance successfully" do
      result = client.account_balance
      expect(result).to eq(response_body)
    end
  end

  describe "#send_bulk_sms" do
    let(:from) { "WittyFlow" }
    let(:recipients) { ["0241234567", "0241234568", "0241234569"] }
    let(:message) { sample_message }
    let(:response_body) { mock_successful_response(message_id: "msg_123") }

    before do
      stub_wittyflow_request(:post, "/messages/send", response_body: response_body)
    end

    it "sends bulk SMS to multiple recipients" do
      result = client.send_bulk_sms(from: from, to: recipients, message: message)
      expect(result).to be_an(Array)
      expect(result.length).to eq(3)
      expect(result.all? { |r| r == response_body }).to be true
    end

    it "works with single recipient" do
      result = client.send_bulk_sms(from: from, to: recipients.first, message: message)
      expect(result).to be_an(Array)
      expect(result.length).to eq(1)
    end
  end

  describe "#format_phone_number" do
    it "handles international format with +" do
      result = client.send(:format_phone_number, "+233241234567")
      expect(result).to eq("233241234567")
    end

    it "handles Ghana country code without +" do
      result = client.send(:format_phone_number, "233241234567")
      expect(result).to eq("233241234567")
    end

    it "handles local format with 0" do
      result = client.send(:format_phone_number, "0241234567")
      expect(result).to eq("233241234567")
    end

    it "handles local format without 0" do
      result = client.send(:format_phone_number, "241234567")
      expect(result).to eq("233241234567")
    end

    it "strips whitespace and non-digit characters" do
      result = client.send(:format_phone_number, " 024-123-4567 ")
      expect(result).to eq("233241234567")
    end
  end

  describe "error handling" do
    let(:from) { "WittyFlow" }
    let(:to) { valid_phone_number }
    let(:message) { sample_message }

    context "when API returns 401" do
      before do
        stub_wittyflow_request(:post, "/messages/send", status: 401)
      end

      it "raises AuthenticationError" do
        expect {
          client.send_sms(from: from, to: to, message: message)
        }.to raise_error(Wittyflow::AuthenticationError, "Invalid app_id or app_secret")
      end
    end

    context "when API returns 400" do
      let(:error_response) { { message: "Invalid phone number" } }

      before do
        stub_wittyflow_request(:post, "/messages/send", status: 400, response_body: error_response)
      end

      it "raises ValidationError with API message" do
        expect {
          client.send_sms(from: from, to: to, message: message)
        }.to raise_error(Wittyflow::ValidationError, "Invalid phone number")
      end
    end

    context "when API returns 429" do
      before do
        stub_wittyflow_request(:post, "/messages/send", status: 429)
      end

      it "raises APIError for rate limiting" do
        expect {
          client.send_sms(from: from, to: to, message: message)
        }.to raise_error(Wittyflow::APIError, "Rate limit exceeded")
      end
    end

    context "when API returns 500" do
      before do
        stub_wittyflow_request(:post, "/messages/send", status: 500)
      end

      it "raises APIError for server error" do
        expect {
          client.send_sms(from: from, to: to, message: message)
        }.to raise_error(Wittyflow::APIError, "Server error (500)")
      end
    end

    context "when network timeout occurs" do
      before do
        stub_request(:post, "https://api.wittyflow.com/v1/messages/send")
          .to_timeout
      end

      it "raises NetworkError" do
        expect {
          client.send_sms(from: from, to: to, message: message)
        }.to raise_error(Wittyflow::NetworkError, /Network timeout/)
      end
    end

    context "when network error with retries" do
      let(:client_with_retries) { described_class.new(app_id: app_id, app_secret: app_secret, retries: 2, retry_delay: 0) }

      before do
        stub_request(:post, "https://api.wittyflow.com/v1/messages/send")
          .to_raise(SocketError.new("Connection failed"))
          .times(2)
          .then
          .to_return(status: 200, body: mock_successful_response.to_json)
      end

      it "retries on network errors and eventually succeeds" do
        result = client_with_retries.send_sms(from: from, to: to, message: message)
        expect(result).to eq(mock_successful_response)
      end
    end
  end
end