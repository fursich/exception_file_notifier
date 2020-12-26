require "bundler/setup"
require "exception_file_notifier"
require 'exception_notification'

if RUBY_VERSION >= '2.7.2'
  # NOTE: https://bugs.ruby-lang.org/issues/17000
  # this will keep us informed of deprecation warnings after Ruby 2.7.2
  Warning[:deprecated] = true
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

# ENV["RAILS_ENV"] = "test"
