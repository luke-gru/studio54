require "rack/test"

# app
require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'dance')
# test helpers
require_relative 'helpers'
# rack test helpers
require 'test/rack/helpers'

# minitest is default
require 'minitest/autorun'
###
# require 'minitest/spec'
# require 'test/unit'
# require 'shoulda'
# require 'rspec'

module Studio54
  # require all model files
  Dir.glob(File.join(MODELSDIR, '*' )). each {|f|
    require f
  }
  # require all controller files
  Dir.glob(File.join(CONTROLLERSDIR, '*' )). each {|f|
    require f
  }
end

