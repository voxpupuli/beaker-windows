# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'beaker-windows/version'

Gem::Specification.new do |spec|
  spec.name          = 'beaker-windows'
  spec.version       = BeakerWindows::Version::STRING
  spec.authors       = ['Puppet Labs']
  spec.email         = ['qa@puppetlabs.com']
  spec.summary       = 'Puppet Labs testing library for testing on Windows.'
  spec.description   = 'This Gem extends the Beaker DSL for the verify state on Windows nodes.'
  spec.homepage      = 'https://github.com/puppetlabs/beaker-windows'
  spec.license       = 'Apache-2.0'
  spec.files         = Dir['[A-Z]*[^~]'] + Dir['lib/**/*.rb'] + Dir['spec/*']
  spec.test_files    = Dir['spec/*']

  # Development dependencies
  spec.add_development_dependency 'bundler', '~> 2.2'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'simplecov', '~> 0.11'
  spec.add_development_dependency 'beaker', '~> 5.1'

  # Documentation dependencies
  spec.add_development_dependency 'yard', '>= 0.9.11'
  spec.add_development_dependency 'markdown', '~> 1'
end
