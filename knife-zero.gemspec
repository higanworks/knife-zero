# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'knife-zero/version'

Gem::Specification.new do |spec|
  spec.name          = "knife-zero"
  spec.version       = Knife::Zero::VERSION
  spec.authors       = ["sawanoboly"]
  spec.email         = ["sawanoboriyu@higanworks.com"]
  spec.summary       = %q{Run chef-client at remote node with chef-zero(local-mode) via HTTP over SSH port fowarding.}
  spec.description   = %q{Run chef-client at remote node with chef-zero(local-mode) via HTTP over SSH port fowarding.}
  spec.homepage      = ""
  spec.license       = "Apache2"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"

  spec.add_runtime_dependency "chef"
end
