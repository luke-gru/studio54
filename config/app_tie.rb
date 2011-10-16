require "sinatra/base"
require "rack/cache"
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

# environment file
require File.join(File.expand_path(File.dirname(__FILE__)), "..", "config/environment")
require 'lib/base'
# config/sinatra inherits from base, so must be after lib/base
require 'config/sinatra'
require 'lib/lazy_record'
require 'lib/lazy_controller'
require 'config/db'
require 'lib/before_filters'
require 'lib/after_filters'
require 'lib/helpers'

