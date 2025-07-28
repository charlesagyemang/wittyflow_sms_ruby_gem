# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-XX

### 🚀 Major Release - Complete Rewrite

This is a major release with breaking changes. The gem has been completely rewritten with modern Ruby patterns and production-ready features.

### Added

- **Modern Ruby Support**: Now requires Ruby 3.0+ for better performance and security
- **Zeitwerk Autoloading**: Automatic code loading for better performance
- **Comprehensive Error Handling**: Specific error classes for different failure scenarios
  - `Wittyflow::ConfigurationError` - Invalid configuration
  - `Wittyflow::ValidationError` - Invalid parameters
  - `Wittyflow::AuthenticationError` - Invalid credentials
  - `Wittyflow::NetworkError` - Network timeouts and connectivity issues
  - `Wittyflow::APIError` - API-specific errors
- **Retry Logic**: Automatic retry mechanism for network failures with configurable attempts and delays
- **Global Configuration**: Configure the gem globally for easier Rails integration
- **Bulk SMS Support**: Send SMS to multiple recipients with `send_bulk_sms` method
- **Enhanced Phone Number Formatting**: Intelligent handling of various phone number formats
- **Comprehensive Test Suite**: 90%+ test coverage with RSpec, WebMock, and VCR
- **Rails Integration Examples**: Detailed examples for Rails applications including:
  - Service classes
  - Background jobs with Sidekiq
  - Model integration
  - Controller usage
  - Database logging
- **Production Features**:
  - Request timeouts and retries
  - Proper logging support
  - User-Agent headers
  - HTTP connection pooling via HTTParty
- **Development Tools**:
  - RuboCop with modern rules
  - SimpleCov for coverage reporting
  - YARD for documentation
  - Guard for automated testing

### Changed

- **BREAKING**: Minimum Ruby version is now 3.0.0
- **BREAKING**: Main API has changed to use keyword arguments:
  ```ruby
  # Old (still works but deprecated)
  client.send_sms(sender, phone, message)
  
  # New
  client.send_sms(from: sender, to: phone, message: message)
  ```
- **BREAKING**: Error handling now uses specific exception classes instead of generic errors
- Updated HTTParty to latest version (0.21.x)
- Improved phone number validation and formatting
- Better response parsing and error messages

### Deprecated

- `Wittyflow::Sms` class is now deprecated in favor of `Wittyflow::Client`
- Old positional argument methods (still work but show deprecation warnings)

### Removed

- Ruby 2.x support (breaking change)
- Legacy error handling patterns

### Fixed

- Phone number formatting edge cases
- Memory leaks in HTTP connections
- Race conditions in concurrent usage
- Proper handling of network timeouts

### Security

- Updated all dependencies to latest secure versions
- Added proper input validation and sanitization
- Removed potential security vulnerabilities in error messages

## [0.1.0] - 2023-XX-XX

### Added
- Initial release
- Basic SMS sending functionality
- Flash SMS support
- Account balance checking
- Message status tracking
- Basic error handling

### Requirements
- Ruby 2.0+
- HTTParty 0.17.x

---

## Migration Guide

### From v0.1.x to v1.0.0

1. **Update Ruby Version**: Ensure you're using Ruby 3.0 or later
2. **Update Dependencies**: Run `bundle update`
3. **Update API Calls**: Change to keyword arguments:
   ```ruby
   # Before
   sms = Wittyflow::Sms.new(app_id, app_secret)
   sms.send_sms("Sender", "0241234567", "Message")
   
   # After
   client = Wittyflow::Client.new(app_id: app_id, app_secret: app_secret)
   client.send_sms(from: "Sender", to: "0241234567", message: "Message")
   ```
4. **Update Error Handling**: Use specific exception classes:
   ```ruby
   # Before
   begin
     sms.send_sms(...)
   rescue => e
     puts "Error: #{e.message}"
   end
   
   # After
   begin
     client.send_sms(...)
   rescue Wittyflow::AuthenticationError => e
     # Handle auth errors
   rescue Wittyflow::NetworkError => e
     # Handle network errors
   rescue Wittyflow::ValidationError => e
     # Handle validation errors
   end
   ```
5. **Add Configuration**: Set up global configuration in Rails initializer:
   ```ruby
   # config/initializers/wittyflow.rb
   Wittyflow.configure do |config|
     config.app_id = ENV['WITTYFLOW_APP_ID']
     config.app_secret = ENV['WITTYFLOW_APP_SECRET']
   end
   ```

### Breaking Changes Summary

- **Ruby 3.0+ Required**: The gem no longer supports Ruby 2.x
- **Keyword Arguments**: All methods now use keyword arguments instead of positional arguments
- **New Error Classes**: Generic errors have been replaced with specific error classes
- **Configuration Changes**: New configuration system with global and instance-level options
- **HTTParty Update**: Updated to latest version which may have its own breaking changes

### New Features You Can Use

- **Bulk SMS**: Send to multiple recipients at once
- **Retry Logic**: Automatic retries for failed requests
- **Better Formatting**: Improved phone number handling
- **Rails Integration**: Comprehensive examples for Rails apps
- **Testing Helpers**: Built-in test helpers for easier testing