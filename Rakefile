$:.unshift 'lib'
$:.unshift 'rakelib'
$:.unshift 'test'

require 'rake/testtask'
require 'rake/clean'
require 'fileutils'
include FileUtils

task :default => [:output_test_count]

task :output_test_count do
  files = FileList['test/**/*'].to_a
  puts "#{files.count} test files to run."
end

namespace :bare do
  desc 'Repopulate bare directory (new app directory)'
  task :repopulate do
    root = File.expand_path(File.dirname(__FILE__))
    rm_r 'bare';  mkdir_p 'bare/app/models'
    mkdir   'bare/app/controllers'
    mkdir_p 'bare/db/versions'
    mkdir 'bare/lib';  mkdir 'bare/public'
    mkdir 'bare/rack'; mkdir 'bare/rakelib'
    mkdir 'bare/test'; mkdir 'bare/static'
    cp_r  File.join(root, 'lib') + '/.',
          File.join(root, 'bare/lib')
    cp_r  File.join(root, 'config') + '/.',
          File.join(root, 'bare/config')
  end
end

namespace :test do
  desc 'Run test suite (suite.rb)'
  Rake::TestTask.new(:suite) do |t|
    t.test_files = FileList['test/suite*'].to_a
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

