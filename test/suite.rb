#!/usr/bin/env ruby
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

# test files
require_relative 'first'

