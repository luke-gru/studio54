$:.unshift 'lib'
$:.unshift 'rakelib'
$:.unshift 'test'

require 'rake/testtask'
require 'rake/clean'

task :default => :test
task :test => [:output_test_count]

desc 'Run all *_tests and *_specs (default)'
test = Rake::TestTask.new(:test) do |t|
  TEST_LIST  = FileList['test/unit/*_test.rb'].to_a +
    FileList['test/integration/*_test.rb'].to_a
  SPEC_LIST  = FileList['test/unit/*_spec.rb'].to_a +
    FileList['test/integration/*_spec.rb'].to_a
  t.test_files = TEST_LIST
  t.test_files + SPEC_LIST unless SPEC_LIST.empty?
end

task :output_test_count do
  STDOUT.puts(TEST_LIST.count + SPEC_LIST.count).to_s + " test files to run."
end

namespace :test do
  desc 'Run test suite (suite.rb)'
  Rake::TestTask.new(:suite) do |t|
    require 'suite'
  end

  desc 'Run unit tests (test/unit/*)'
  Rake::TestTask.new(:unit) do |t|
    t.test_files = FileList['test/unit/*'].to_a
  end

  desc 'Run integration tests (test/integration/*)'
  Rake::TestTask.new(:integration) do |t|
    t.test_files = FileList['test/integration/*'].to_a
  end
end

