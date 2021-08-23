# frozen_string_literal: true

require_relative "wittyflow/version"
require 'httparty'

module Wittyflow

  class Sms
    attr_accessor :app_id, :app_secret, :api_endpoint

    def initialize(app_id, app_secret)
      @app_id       = app_id
      @app_secret   = app_secret
      @api_endpoint = "https://api.wittyflow.com/v1"
    end

    def send_sms(sender, receiver_phone_number, message_to_send)
      send_general_sms(sender, receiver_phone_number, message_to_send)
    end

    def send_flash_sms(sender, receiver_phone_number, message_to_send)
      send_general_sms(sender, receiver_phone_number, message_to_send, is_flash=true)
    end

    def check_sms_status(sms_id)
      make_request(form_sms_status_check_url(sms_id), {}, "get")
    end

    def account_balance
      make_request(account_balance_url, {}, "get")
    end

    private

      def make_request(url, body, type="post")
        options = {
        	body: body
        }
        requ_hash = {
          "post" => -> (url, options) {HTTParty.post(url, options)},
          "get"  => -> (url, options) {HTTParty.get(url, {})},
        }
        results = requ_hash[type].call(url, options)
      rescue => e
        puts "ERROR: #{e}"
      end

      def form_send_sms_body(sender, receiver_phone_number, message_to_send, is_flash=false)
        res = {
          from: "#{sender}",
          to:  "233#{receiver_phone_number[1..-1]}",
          type: 1,
          message: "#{message_to_send}",
          app_id: "#{@app_id}",
          app_secret: "#{@app_secret}"
        }
        res[:type] = 0 if is_flash
        res
      end

      def send_general_sms(sender, receiver_phone_number, message_to_send, is_flash=false)
        body_to_send = form_send_sms_body(sender, receiver_phone_number, message_to_send, is_flash)
        send_sms_endpoint = "#{@api_endpoint}/messages/send"
        make_request(send_sms_endpoint, body_to_send)
      end

      def account_balance_url
        "#{@api_endpoint}/account/balance?app_id=#{@app_id}&app_secret=#{@app_secret}"
      end

      def form_sms_status_check_url(sms_id)
        "#{@api_endpoint}/messages/#{sms_id}/retrieve?app_id=#{@app_id}&app_secret=#{@app_secret}"
      end
  end

end
