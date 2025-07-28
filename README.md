# Wittyflow Ruby Gem

[![Gem Version](https://badge.fury.io/rb/wittyflow.svg)](https://badge.fury.io/rb/wittyflow)
[![Ruby](https://github.com/charlesagyemang/wittyflow_sms_ruby_gem/actions/workflows/ruby.yml/badge.svg)](https://github.com/charlesagyemang/wittyflow_sms_ruby_gem/actions/workflows/ruby.yml)

A production-ready Ruby gem for integrating with the [Wittyflow SMS API](https://wittyflow.com/). Send SMS messages, check delivery status, and manage your account with a clean, modern Ruby interface.

## Features

- 🚀 **Modern Ruby**: Requires Ruby 3.0+ with Zeitwerk autoloading
- 📱 **Full SMS API**: Send regular SMS, flash SMS, and bulk messaging
- 🔄 **Retry Logic**: Built-in retry mechanism for network failures
- 🛡️ **Error Handling**: Comprehensive error types with detailed messages
- 📊 **Account Management**: Check balance and message delivery status
- 🌍 **Phone Formatting**: Intelligent phone number formatting for Ghana
- 🧪 **Well Tested**: 90%+ test coverage with RSpec
- 📖 **Rails Ready**: Easy integration with Rails applications
- 🔧 **Configurable**: Global and per-instance configuration options

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'wittyflow'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install wittyflow
```

## Configuration

### Global Configuration (Recommended for Rails)

```ruby
# config/initializers/wittyflow.rb
Wittyflow.configure do |config|
  config.app_id = ENV['WITTYFLOW_APP_ID']
  config.app_secret = ENV['WITTYFLOW_APP_SECRET']
  config.timeout = 30
  config.retries = 3
  config.retry_delay = 1
  config.default_country_code = "233" # Ghana
end
```

### Environment Variables

Create a `.env` file or set environment variables:

```bash
WITTYFLOW_APP_ID=your_app_id_here
WITTYFLOW_APP_SECRET=your_app_secret_here
```

## Usage

### Basic SMS Sending

```ruby
# Using global configuration
client = Wittyflow::Client.new

# Send regular SMS
response = client.send_sms(
  from: "YourApp",
  to: "0241234567",
  message: "Hello from Wittyflow!"
)

# Send flash SMS (appears directly on screen)
response = client.send_flash_sms(
  from: "YourApp", 
  to: "0241234567",
  message: "Urgent: Your verification code is 123456"
)
```

### Instance Configuration

```ruby
# Per-instance configuration
client = Wittyflow::Client.new(
  app_id: "your_app_id",
  app_secret: "your_app_secret",
  timeout: 60,
  retries: 5
)

response = client.send_sms(
  from: "YourApp",
  to: "+233241234567",
  message: "Hello World!"
)
```

### Bulk SMS

```ruby
# Send to multiple recipients
recipients = ["0241234567", "0241234568", "0241234569"]

results = client.send_bulk_sms(
  from: "YourApp",
  to: recipients,
  message: "Bulk message to all recipients"
)

# Results is an array with response for each recipient
results.each_with_index do |result, index|
  puts "Message to #{recipients[index]}: #{result['status']}"
end
```

### Message Status Tracking

```ruby
# Check delivery status
status_response = client.message_status("message_id_from_send_response")
puts "Message status: #{status_response['data']['status']}"
```

### Account Balance

```ruby
# Check account balance
balance_response = client.account_balance
puts "Balance: #{balance_response['data']['balance']} #{balance_response['data']['currency']}"
```

## Rails Integration

### 1. SMS Service Class

```ruby
# app/services/sms_service.rb
class SmsService
  include ActiveModel::Model
  
  attr_accessor :to, :message, :from
  
  validates :to, :message, presence: true
  validates :from, presence: true, length: { maximum: 11 }
  
  def initialize(attributes = {})
    super
    @from ||= Rails.application.credentials.sms_sender_id || "YourApp"
  end
  
  def send_sms
    return false unless valid?
    
    begin
      response = wittyflow_client.send_sms(
        from: from,
        to: to,
        message: message
      )
      
      # Log the response
      Rails.logger.info "SMS sent successfully: #{response}"
      
      # Store in database if needed
      SmsLog.create!(
        recipient: to,
        message: message,
        sender: from,
        external_id: response.dig('data', 'message_id'),
        status: 'sent',
        response: response
      )
      
      true
    rescue Wittyflow::Error => e
      Rails.logger.error "SMS sending failed: #{e.message}"
      errors.add(:base, "Failed to send SMS: #{e.message}")
      false
    end
  end
  
  private
  
  def wittyflow_client
    @wittyflow_client ||= Wittyflow::Client.new
  end
end
```

### 2. Controller Integration

```ruby
# app/controllers/notifications_controller.rb
class NotificationsController < ApplicationController
  before_action :authenticate_user!
  
  def send_sms
    @sms_service = SmsService.new(sms_params)
    
    if @sms_service.send_sms
      flash[:notice] = 'SMS sent successfully!'
      redirect_to notifications_path
    else
      flash[:alert] = @sms_service.errors.full_messages.join(', ')
      render :new
    end
  end
  
  private
  
  def sms_params
    params.require(:sms_service).permit(:to, :message, :from)
  end
end
```

### 3. Background Jobs with Sidekiq

```ruby
# app/jobs/send_sms_job.rb
class SendSmsJob < ApplicationJob
  queue_as :default
  
  retry_on Wittyflow::NetworkError, wait: :exponentially_longer, attempts: 3
  retry_on Wittyflow::APIError, wait: 30.seconds, attempts: 2
  
  def perform(recipient, message, sender = nil)
    client = Wittyflow::Client.new
    
    response = client.send_sms(
      from: sender || Rails.application.credentials.sms_sender_id,
      to: recipient,
      message: message
    )
    
    # Update database record if needed
    SmsLog.find_by(recipient: recipient, message: message)
           &.update!(external_id: response.dig('data', 'message_id'))
  end
end

# Usage in controllers or models
SendSmsJob.perform_later(user.phone, "Welcome to our service!", "YourApp")
```

### 4. Model Integration

```ruby
# app/models/user.rb
class User < ApplicationRecord
  after_create :send_welcome_sms
  
  def send_sms(message, sender = nil)
    return false unless phone.present?
    
    SmsService.new(
      to: phone,
      message: message,
      from: sender
    ).send_sms
  end
  
  def send_verification_code
    code = generate_verification_code
    update(verification_code: code)
    
    send_sms("Your verification code is: #{code}")
  end
  
  private
  
  def send_welcome_sms
    SendSmsJob.perform_later(
      phone,
      "Welcome to #{Rails.application.class.module_parent_name}! Thanks for joining us.",
      "YourApp"
    )
  end
  
  def generate_verification_code
    SecureRandom.random_number(999999).to_s.rjust(6, '0')
  end
end
```

### 5. Database Logging

```ruby
# db/migrate/xxx_create_sms_logs.rb
class CreateSmsLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :sms_logs do |t|
      t.string :recipient, null: false
      t.text :message, null: false
      t.string :sender
      t.string :external_id
      t.string :status, default: 'pending'
      t.json :response
      t.timestamps
    end
    
    add_index :sms_logs, :recipient
    add_index :sms_logs, :external_id
    add_index :sms_logs, :status
  end
end

# app/models/sms_log.rb
class SmsLog < ApplicationRecord
  validates :recipient, :message, presence: true
  
  enum status: {
    pending: 'pending',
    sent: 'sent',
    delivered: 'delivered',
    failed: 'failed'
  }
  
  scope :recent, -> { order(created_at: :desc) }
  scope :for_recipient, ->(phone) { where(recipient: phone) }
end
```

## Phone Number Formats

The gem automatically handles various phone number formats for Ghana:

```ruby
# All of these formats work:
client.send_sms(from: "App", to: "0241234567", message: "Hello")      # Local with 0
client.send_sms(from: "App", to: "241234567", message: "Hello")       # Local without 0  
client.send_sms(from: "App", to: "+233241234567", message: "Hello")   # International
client.send_sms(from: "App", to: "233241234567", message: "Hello")    # Country code only

# They all get formatted to: "233241234567"
```

## Error Handling

The gem provides specific error types for different scenarios:

```ruby
begin
  client.send_sms(from: "App", to: "0241234567", message: "Hello")
rescue Wittyflow::AuthenticationError => e
  # Invalid app_id or app_secret
  puts "Authentication failed: #{e.message}"
rescue Wittyflow::ValidationError => e
  # Invalid parameters (missing required fields, etc.)
  puts "Validation error: #{e.message}"
rescue Wittyflow::NetworkError => e
  # Network timeout or connection issues
  puts "Network error: #{e.message}"
rescue Wittyflow::APIError => e
  # API-specific errors (rate limiting, server errors)
  puts "API error: #{e.message}"
rescue Wittyflow::Error => e
  # Any other Wittyflow-related error
  puts "Wittyflow error: #{e.message}"
end
```

## Testing

### With RSpec

```ruby
# spec/support/wittyflow_helpers.rb
module WittyflowHelpers
  def stub_wittyflow_success(response_data = {})
    allow_any_instance_of(Wittyflow::Client)
      .to receive(:send_sms)
      .and_return({
        'status' => 'success',
        'data' => { 'message_id' => 'msg_123' }.merge(response_data)
      })
  end
  
  def stub_wittyflow_error(error_class = Wittyflow::APIError, message = "API Error")
    allow_any_instance_of(Wittyflow::Client)
      .to receive(:send_sms)
      .and_raise(error_class, message)
  end
end

# In your specs
RSpec.configure do |config|
  config.include WittyflowHelpers
end

# spec/services/sms_service_spec.rb
RSpec.describe SmsService do
  describe '#send_sms' do
    let(:service) { described_class.new(to: '0241234567', message: 'Test') }
    
    context 'when API call succeeds' do
      before { stub_wittyflow_success }
      
      it 'returns true' do
        expect(service.send_sms).to be true
      end
    end
    
    context 'when API call fails' do
      before { stub_wittyflow_error(Wittyflow::NetworkError, 'Network timeout') }
      
      it 'returns false and adds error' do
        expect(service.send_sms).to be false
        expect(service.errors[:base]).to include('Failed to send SMS: Network timeout')
      end
    end
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt.

### Available Rake Tasks

```bash
rake spec          # Run all tests
rake rubocop       # Run RuboCop linter
rake quality       # Run all quality checks (tests + linting)
rake coverage      # Generate test coverage report
rake doc           # Generate YARD documentation
```

### Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Write tests for your changes
4. Ensure all tests pass (`rake quality`)
5. Commit your changes (`git commit -am 'Add some feature'`)
6. Push to the branch (`git push origin my-new-feature`)
7. Create a Pull Request

## Changelog

### v1.0.0 (Latest)

- **Breaking Changes**: Requires Ruby 3.0+
- Complete rewrite with modern Ruby patterns
- Added comprehensive error handling with specific error types
- Added retry logic for network failures
- Added bulk SMS support
- Added extensive test suite (90%+ coverage)
- Added Rails integration examples
- Added global configuration support
- Improved phone number formatting
- Added Zeitwerk autoloading

### v0.1.0 (Legacy)

- Basic SMS sending functionality
- Minimal error handling
- Ruby 2.0+ support

## Migration from v0.x

If you're upgrading from v0.x, here are the key changes:

```ruby
# Old way (still works but deprecated)
sms = Wittyflow::Sms.new(app_id, app_secret)
sms.send_sms(sender, phone, message)

# New way
client = Wittyflow::Client.new(app_id: app_id, app_secret: app_secret)
client.send_sms(from: sender, to: phone, message: message)
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Support

- 📧 Email: micnkru@gmail.com
- 🐛 [Report Issues](https://github.com/charlesagyemang/wittyflow_sms_ruby_gem/issues)
- 📖 [Documentation](https://github.com/charlesagyemang/wittyflow_sms_ruby_gem)

## Code of Conduct

Everyone interacting in the Wittyflow project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/charlesagyemang/wittyflow_sms_ruby_gem/blob/main/CODE_OF_CONDUCT.md).
