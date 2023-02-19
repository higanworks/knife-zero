lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'knife-zero/version'

Gem::Specification.new do |spec|
  spec.name          = 'knife-zero'
  spec.version       = Knife::Zero::VERSION
  spec.authors       = ['sawanoboly']
  spec.email         = ['sawanoboriyu@higanworks.com']
  spec.summary       = 'Run chef-client at remote node with chef-zero(local-mode) via HTTP over SSH port fowarding.'
  spec.description   = 'Run chef-client at remote node with chef-zero(local-mode) via HTTP over SSH port fowarding.'
  spec.homepage      = 'http://knife-zero.github.io'
  spec.license       = 'Apache-2.0'
  spec.required_ruby_version = '>= 2.5.0'

  spec.files         = Dir['README.md', 'CHANGELOG.md', 'knife-zero.gemspec', 'lib/**/*']
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '>= 1.6'
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-shell'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'simplecov-rcov'
  spec.add_development_dependency 'test-unit'
  spec.add_development_dependency 'test-unit-notify'
  spec.add_development_dependency 'test-unit-rr'

  spec.add_runtime_dependency 'chef', '>= 16.6'
  spec.add_runtime_dependency 'knife', '>= 17.0'
end
