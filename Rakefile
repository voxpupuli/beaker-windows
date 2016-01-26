require "bundler/gem_tasks"

require 'rspec/core/rake_task'

task :default do
  system 'rake --tasks'
end

desc "Run spec tests"
RSpec::Core::RakeTask.new(:test) do |t|
  t.rspec_opts = ['--color']
  t.pattern = 'spec/'
end
