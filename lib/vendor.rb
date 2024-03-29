require "sinatra/base"
require "rack/cache"
require "rack-flash"
require "active_support/core_ext/array"
require "active_support/core_ext/class"
require "active_support/core_ext/enumerable"
require "active_support/core_ext/hash"
require "active_support/core_ext/integer"
require "active_support/core_ext/kernel"
require "active_support/core_ext/module"
require "active_support/core_ext/object"
require "active_support/core_ext/proc"
require "active_support/core_ext/range"
require "active_support/core_ext/string/behavior"
require "active_support/core_ext/string/filters"
require "active_support/core_ext/string/inflections"
require "active_support/callbacks"

require "active_model"
require "dbi"

require_relative 'partials'

