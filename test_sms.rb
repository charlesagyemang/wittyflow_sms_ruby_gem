#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'lib/wittyflow'

# Configure with your test credentials
Wittyflow.configure do |config|
  config.app_id = '1f41908b-a9d7-4408-a0bf-4ee4665b3276'
  config.app_secret = 'CvAILbsSdfjGAVVZr6RG0zgBv5jHUioh88vCuHu914'
  config.timeout = 30
  config.retries = 3
end

# Create client and send test SMS
client = Wittyflow::Client.new

puts "🚀 Testing Wittyflow SMS gem..."
puts "Sending SMS to 0277119919..."

begin
  response = client.send_sms(
    from: "A.G.P.C",
    to: "0277119919",
    message: "Hello! This is a test message from the modernized Wittyflow Ruby gem v1.0.0. The upgrade was successful! 🎉"
  )
  
  puts "✅ SMS sent successfully!"
  puts "Response: #{response.inspect}"
  
  if response["data"] && response["data"]["message_id"]
    message_id = response["data"]["message_id"]
    puts "📱 Message ID: #{message_id}"
    
    # Wait a moment then check status
    puts "⏳ Waiting 3 seconds before checking status..."
    sleep(3)
    
    status_response = client.message_status(message_id)
    puts "📊 Message Status: #{status_response.inspect}"
  end
  
  # Check account balance
  puts "💰 Checking account balance..."
  balance_response = client.account_balance
  puts "Account Balance: #{balance_response.inspect}"
  
rescue Wittyflow::AuthenticationError => e
  puts "❌ Authentication failed: #{e.message}"
rescue Wittyflow::ValidationError => e
  puts "❌ Validation error: #{e.message}"
rescue Wittyflow::NetworkError => e
  puts "❌ Network error: #{e.message}"
rescue Wittyflow::APIError => e
  puts "❌ API error: #{e.message}"
rescue Wittyflow::Error => e
  puts "❌ Wittyflow error: #{e.message}"
rescue StandardError => e
  puts "❌ Unexpected error: #{e.message}"
  puts "Backtrace: #{e.backtrace.first(5).join("\n")}"
end

puts "\n✨ Test completed!"