source 'https://rubygems.org'
#this will probably not be available on rubygems, at least initially
#will probably be only available at https://rubygems.delivery.puppetlabs.net
#TODO: Change this line when it is actually available internally

# Shared
gem 'bundler', '~> 1.6'
gem 'rake', '~> 10.0'
gem 'beaker', '~> 2.32'

group :build do
  gem 'yard', '~> 0'
  gem 'markdown', '~> 0'
end

group :development do
  gem 'pry-byebug', '~> 3.3'
end

group :test do
  gem 'rspec', '~> 3.0',      :require => false
  gem 'simplecov', '~> 0.11', :require => false
end

# Load the beaker-windows.gemspec
gemspec
