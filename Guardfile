ignore %r{^(node_modules|public|log/|doc/|db/|config/|.gems/|.bundle/)}

guard :rspec, cmd: "bundle exec rspec", all_on_start: false do
  directories %w(app config lib spec)

  require "guard/rspec/dsl"

  dsl = Guard::RSpec::Dsl.new(self)

  # RSpec files
  rspec = dsl.rspec
  watch(rspec.spec_helper) { rspec.spec_dir }
  watch(rspec.spec_support) { rspec.spec_dir }
  watch(rspec.spec_files)

  # Ruby files
  ruby = dsl.ruby
  dsl.watch_spec_files_for(ruby.lib_files)
end

guard :yard do
  watch(%r{^lib/(.+)\.rb$})
  watch(%r{^app/(.+)\.rb$})
end
