# frozen_string_literal: true

# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard :rspec, cmd: "bundle exec rspec" do
  require "guard/rspec/dsl"
  dsl = Guard::RSpec::Dsl.new(self)

  # Feel free to open issues for suggestions and improvements

  # RSpec files
  rspec = dsl.rspec
  watch(rspec.spec_helper) { rspec.spec_dir }
  watch(rspec.spec_support) { rspec.spec_dir }
  watch(rspec.spec_files)

  # Ruby files
  ruby = dsl.ruby
  dsl.watch_spec_files_for(ruby.lib_files)

  # Wittyflow specific files
  watch(%r{^lib/wittyflow/(.+)\.rb$}) { |m| "spec/wittyflow/#{m[1]}_spec.rb" }
  watch(%r{^lib/wittyflow\.rb$}) { "spec/wittyflow_spec.rb" }
end

guard :rubocop, all_on_start: false, cli: ["--format", "emacs"] do
  watch(/.+\.rb$/)
  watch(%r{(?:.+/)?\.rubocop(?:_todo)?\.yml$}) { |m| File.dirname(m[0]) }
end
