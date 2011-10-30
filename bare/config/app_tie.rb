module Studio54
  require_relative 'environment'
  require 'config/studio54_tie'
  require 'config/sinatra'
  require 'config/db'

  include Config::Environment
  require File.join(LIBDIR, 'before_filters')
  require File.join(LIBDIR, 'after_filters')
  require File.join(LIBDIR, 'helpers')
end

