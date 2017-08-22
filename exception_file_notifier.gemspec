# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'exception_notifier/exception_file_notifier/version'

Gem::Specification.new do |spec|
  spec.name          = "exception_file_notifier"
  spec.version       = ::ExceptionNotifier::ExceptionFileNotifier::VERSION
  spec.authors       = ["Koji Onishi"]
  spec.email         = ["fursich0@gmail.com"]

  spec.summary       = %q{ A custom notifier for ExceptionNotification that generates exception log files in JSON format. }
  spec.description   = %q{ Exception File Notifier records exception logs in JSON format, helping you track errors in the production environment. }
  spec.homepage      = "https://github.com/fursich/exception_file_notifier"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'http://mygemserver.com'
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version     = '>= 2.1'
  spec.required_rubygems_version = '>= 1.8.11'
  # spec.add_dependency("activesupport", ">= 4.0", "< 6")

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rails", ">= 4.0", "< 6"
  spec.add_development_dependency "pry"
  spec.add_dependency "exception_notification", ">= 4.0"
end
