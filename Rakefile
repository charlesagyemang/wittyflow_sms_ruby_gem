# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rubocop/rake_task"

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new

begin
  require "yard"
  YARD::Rake::YardocTask.new(:doc) do |t|
    t.files = ["lib/**/*.rb"]
    t.options = ["--markup-provider=redcarpet", "--markup=markdown"]
  end
rescue LoadError
  # YARD not available
end

desc "Run all quality checks"
task quality: [:rubocop, :spec]

desc "Generate test coverage report"
task :coverage do
  ENV["COVERAGE"] = "true"
  Rake::Task[:spec].invoke
end

desc "Interactive console with gem loaded"
task :console do
  exec "bin/console"
end

task default: :quality
