# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = '--format documentation'
end

task :coverage do
  ENV['COVERAGE'] = 'true'
  Rake::Task[:spec].invoke
end

desc 'Run RSpec tests in parallel'
task :spec_parallel do
  sh 'bundle exec parallel_rspec spec/'
end

desc 'Run RSpec tests in parallel with coverage'
task :coverage_parallel do
  ENV['COVERAGE'] = 'true'
  sh 'bundle exec parallel_rspec spec/'
end

RuboCop::RakeTask.new do |task|
  task.options = ['--parallel']
end

desc 'Run Brakeman security scan'
task :brakeman do
  sh 'bundle exec brakeman --force --quiet --format json --output brakeman-report.json'
  sh 'bundle exec brakeman --force --quiet --format html --output brakeman-report.html'
end

task default: %i[rubocop spec]
