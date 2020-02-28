# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pxfusion/version'

Gem::Specification.new do |spec|
  spec.name          = "pxfusion"
  spec.version       = Pxfusion::VERSION
  spec.authors       = ["Aaron Lipinski"]
  spec.email         = ["kris.lipinski@gmail.com"]
  spec.summary       = %q{Client for the Payment Express PxFusion API}
  spec.description   = %q{Client for the Payment Express PxFusion API}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.1"
  spec.add_dependency "savon", "~> 2.0"
end
