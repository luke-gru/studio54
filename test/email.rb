#!/usr/bin/env ruby
require_relative "environment"

module Studio54
  # test files
  Dir.glob(File.join(ROOTDIR, 'test', 'mail', '*')).each {|f| require f }
end

