#!/usr/bin/env ruby
require_relative 'environment'

module Studio54
  # test files (all but email sending)
  Dir.glob('**/*_test.rb').each {|f| require f unless f =~ /email/ }
end

