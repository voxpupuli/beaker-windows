# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'beaker_windows/version'

Gem::Specification.new do |spec|
  spec.name          = 'beaker_windows'
  spec.version       = BeakerWindows::Version::STRING
  spec.authors       = ['Puppet Labs']
  spec.email         = ['qa@puppetlabs.com']
  spec.summary       = 'Puppet Labs testing library for testing on Windows.'
  spec.description   = 'This Gem extends the Beaker DSL for the verify state on Windows nodes.'
  spec.homepage      = 'https://github.com/puppetlabs/beaker_windows'
  spec.license       = 'Apache-2.0'
  spec.files         = Dir['[A-Z]*[^~]'] + Dir['lib/**/*.rb'] + Dir['spec/*']
  spec.test_files    = Dir['spec/*']

  # Development dependencies
  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'pry-byebug', '~> 3.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '>= 3.0.0'
  spec.add_development_dependency 'simplecov'

  # Documentation dependencies
  spec.add_development_dependency 'yard', '~> 0'
  spec.add_development_dependency 'markdown', '~> 0'
end
