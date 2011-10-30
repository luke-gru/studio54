require_relative 'vendor'

module Studio54
  # require all studio54 library files along with the current
  # project's config files
  lib    = File.join(File.expand_path(File.dirname(__FILE__)), '..', 'lib')
  ['l/base', 'c/sinatra', 'l/lazy_record', 'l/lazy_controller', 'c/db',
  'c/db_connect', 'l/before_filters', 'l/after_filters',
  'l/helpers'].each do |f|
    require File.join(lib,    f[2..-1]) if f[0] == 'l'
    require File.join(CONFIGDIR, f[2..-1]) if f[0] == 'c'
    end
end

