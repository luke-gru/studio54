module Studio54
  require_relative 'environment'
  include Config::Environment

  require File.join(LIBDIR, 'studio54')
end

