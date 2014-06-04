require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RuboCop::RakeTask.new

RSpec::Core::RakeTask.new

task default: :spec
task test: :spec

desc 'Run RSpec with code coverage'
task :coverage do
  ENV['SIMPLE_COVERAGE'] = 'true'
  Rake::Task['spec'].execute
end
