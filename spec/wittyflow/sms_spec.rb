# frozen_string_literal: true

RSpec.describe Wittyflow::Sms do
  let(:app_id) { valid_app_id }
  let(:app_secret) { valid_app_secret }
  
  subject(:sms) { described_class.new(app_id, app_secret) }

  describe "#initialize" do
    it "shows deprecation warning" do
      expect { described_class.new(app_id, app_secret) }
        .to output(/DEPRECATION.*Wittyflow::Sms is deprecated. Use Wittyflow::Client instead/).to_stderr
    end

    it "creates a client internally" do
      expect(sms.instance_variable_get(:@client)).to be_a(Wittyflow::Client)
    end
  end

  describe "#send_sms" do
    let(:sender) { "WittyFlow" }
    let(:receiver) { valid_phone_number }
    let(:message) { sample_message }
    let(:response) { mock_successful_response(message_id: "msg_123") }

    before do
      allow_any_instance_of(Wittyflow::Client).to receive(:send_sms).and_return(response)
    end

    it "delegates to client with correct parameters" do
      expect_any_instance_of(Wittyflow::Client)
        .to receive(:send_sms)
        .with(from: sender, to: receiver, message: message)
        .and_return(response)

      result = sms.send_sms(sender, receiver, message)
      expect(result).to eq(response)
    end
  end

  describe "#send_flash_sms" do
    let(:sender) { "WittyFlow" }
    let(:receiver) { valid_phone_number }
    let(:message) { sample_message }
    let(:response) { mock_successful_response(message_id: "msg_123") }

    before do
      allow_any_instance_of(Wittyflow::Client).to receive(:send_flash_sms).and_return(response)
    end

    it "delegates to client with correct parameters" do
      expect_any_instance_of(Wittyflow::Client)
        .to receive(:send_flash_sms)
        .with(from: sender, to: receiver, message: message)
        .and_return(response)

      result = sms.send_flash_sms(sender, receiver, message)
      expect(result).to eq(response)
    end
  end

  describe "#check_sms_status" do
    let(:sms_id) { "msg_123" }
    let(:response) { mock_successful_response(status: "delivered") }

    before do
      allow_any_instance_of(Wittyflow::Client).to receive(:message_status).and_return(response)
    end

    it "delegates to client with correct parameters" do
      expect_any_instance_of(Wittyflow::Client)
        .to receive(:message_status)
        .with(sms_id)
        .and_return(response)

      result = sms.check_sms_status(sms_id)
      expect(result).to eq(response)
    end
  end

  describe "#account_balance" do
    let(:response) { mock_successful_response(balance: 100.50, currency: "GHS") }

    before do
      allow_any_instance_of(Wittyflow::Client).to receive(:account_balance).and_return(response)
    end

    it "delegates to client" do
      expect_any_instance_of(Wittyflow::Client)
        .to receive(:account_balance)
        .and_return(response)

      result = sms.account_balance
      expect(result).to eq(response)
    end
  end
end