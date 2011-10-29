module Studio54
  require_relative 'environment'
  require_relative 'studio54_tie'
  require_relative 'config/sinatra'
  require_relative 'config/db'

  include Config::Environment
  require File.join(LIBDIR, 'before_filters')
  require File.join(LIBDIR, 'after_filters')
  require File.join(LIBDIR, 'helpers')
end

