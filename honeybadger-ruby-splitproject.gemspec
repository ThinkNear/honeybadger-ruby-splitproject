# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'honeybadger/splitproject/version'

Gem::Specification.new do |spec|
  spec.name          = "honeybadger-ruby-splitproject"
  spec.version       = Honeybadger::Splitproject::VERSION
  spec.authors       = ["Thinknear"]
  spec.email         = ["services@thinknear.com"]
  spec.summary       = %q{Split project into multiple Honeybadger projects.}
  spec.description   = %q{Allows alerting to multiple Honeybadger projects from a single Rails project.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_dependency 'honeybadger', '>= 2.6.0'
end
