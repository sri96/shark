# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'shark/version'

Gem::Specification.new do |spec|
  spec.name          = "Shark"
  spec.version       = Shark::VERSION
  spec.authors       = ["Adhithya Rajasekaran"]
  spec.email         = ["adhithyan15@gmail.com"]
  spec.description   = %q{Shark is a simple testing tool}
  spec.summary       = %q{Shark is a testing tool focused on testing file operations}
  spec.homepage      = "http://adhithyan15.github.io/shark"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
