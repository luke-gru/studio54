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

namespace :gem do
  desc 'rebuild the studio54 gem'
  task :rebuild do
    if `gem list | grep studio54`
      system("gem uninstall studio54 --executables")
    end
    gemfile = Dir.glob 'studio54-*'
    rm gemfile
    gemspec = 'studio54.gemspec'
    system "gem build #{gemspec}"
    new_gemfile = Dir.glob 'studio54-*'
    system "gem install #{new_gemfile}"
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

