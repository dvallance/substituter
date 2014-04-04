# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'substituter/version'

Gem::Specification.new do |spec|
  spec.name          = "substituter"
  spec.version       = Substituter::VERSION
  spec.authors       = ["David Vallance"]
  spec.email         = ["davevallance@gmail.com"]
  spec.description   = %q{Substitute an existing method with a Proc. The Proc will have access to the replaced method and its parameters.}
  spec.summary       = %q{Substitute an existing method with a Proc.}
  spec.homepage      = "https://github.com/dvallance/substituter"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
