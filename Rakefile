# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec)

RuboCop::RakeTask.new do |task|
  task.options = ['--parallel']
end

desc "Run Brakeman security scan"
task :brakeman do
  sh "bundle exec brakeman --force --quiet --format json --output brakeman-report.json"
  sh "bundle exec brakeman --force --quiet --format html --output brakeman-report.html"
end

task default: %i[rubocop spec]
