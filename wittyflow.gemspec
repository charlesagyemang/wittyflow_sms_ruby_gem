# frozen_string_literal: true

require_relative "lib/wittyflow/version"

Gem::Specification.new do |spec|
  spec.name          = "wittyflow"
  spec.version       = Wittyflow::VERSION
  spec.authors       = ["charlesagyemang"]
  spec.email         = ["micnkru@gmail.com"]

  spec.summary       = "A production-ready Ruby gem for sending SMS via Wittyflow API"
  spec.description   = "Wittyflow is a robust, well-tested Ruby gem for integrating with the Wittyflow SMS service. " \
                       "Features include SMS sending, delivery tracking, account balance checking, retry logic, " \
                       "and comprehensive error handling."
  spec.homepage      = "https://github.com/charlesagyemang/wittyflow_sms_ruby_gem"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = "https://github.com/charlesagyemang/wittyflow_sms_ruby_gem"
  spec.metadata["source_code_uri"] = "https://github.com/charlesagyemang/wittyflow_sms_ruby_gem"
  spec.metadata["changelog_uri"] = "https://github.com/charlesagyemang/wittyflow_sms_ruby_gem/blob/main/CHANGELOG.md"
  spec.metadata["bug_tracker_uri"] = "https://github.com/charlesagyemang/wittyflow_sms_ruby_gem/issues"
  spec.metadata["documentation_uri"] = "https://github.com/charlesagyemang/wittyflow_sms_ruby_gem/blob/main/README.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{\A(?:test|spec|features)/}) ||
        f.start_with?(".") ||
        f.match(/\A(Gemfile|Rakefile)/)
    end
  end

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Runtime dependencies (alphabetically ordered)
  spec.add_dependency "csv", "~> 3.2"
  spec.add_dependency "httparty", "~> 0.21.0"
  spec.add_dependency "zeitwerk", "~> 2.6"

  # Development dependencies
  spec.add_development_dependency "guard", "~> 2.18"
  spec.add_development_dependency "guard-rspec", "~> 4.7"
  spec.add_development_dependency "pry", "~> 0.14"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "rubocop", "~> 1.50"
  spec.add_development_dependency "rubocop-performance", "~> 1.16"
  spec.add_development_dependency "rubocop-rspec", "~> 2.20"
  spec.add_development_dependency "simplecov", "~> 0.22"
  spec.add_development_dependency "vcr", "~> 6.1"
  spec.add_development_dependency "webmock", "~> 3.18"
  spec.add_development_dependency "yard", "~> 0.9"
end
