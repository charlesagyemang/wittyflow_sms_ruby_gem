# frozen_string_literal: true

module Wittyflow
  # Backward compatibility wrapper for the old Sms class
  # @deprecated Use Wittyflow::Client instead
  class Sms
    def initialize(app_id, app_secret)
      warn "[DEPRECATION] Wittyflow::Sms is deprecated. Use Wittyflow::Client instead."
      @client = Client.new(app_id: app_id, app_secret: app_secret)
    end

    def send_sms(sender, receiver_phone_number, message_to_send)
      @client.send_sms(from: sender, to: receiver_phone_number, message: message_to_send)
    end

    def send_flash_sms(sender, receiver_phone_number, message_to_send)
      @client.send_flash_sms(from: sender, to: receiver_phone_number, message: message_to_send)
    end

    def check_sms_status(sms_id)
      @client.message_status(sms_id)
    end

    def account_balance
      @client.account_balance
    end

    private

    attr_reader :client
  end
end
