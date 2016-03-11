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
end
