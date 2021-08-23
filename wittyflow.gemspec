# frozen_string_literal: true

require_relative "lib/wittyflow/version"

Gem::Specification.new do |spec|
  spec.name          = "wittyflow"
  spec.version       = Wittyflow::VERSION
  spec.authors       = ["charlesagyemang"]
  spec.email         = ["micnkru@gmail.com"]

  spec.summary       = "Send Sms To Any Number In Ghana Using Wittyflow"
  spec.description   = "Send Sms To Any Number In Ghana Using Wittyflow"
  spec.homepage      = "https://wittyflow.com"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.0.0"

  spec.metadata["allowed_push_host"] = "https://mygemserver.com"

  spec.metadata["homepage_uri"] = "https://wittyflow.com"
  spec.metadata["source_code_uri"] = "https://wittyflow.com"
  spec.metadata["changelog_uri"] = "https://wittyflow.com"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "httparty", "~> 0.17.3"

end
