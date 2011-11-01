class LazyController < Studio54::Base

  class << self

    def inherited(base)
      base.extend  ActiveModel::Callbacks
    end

    def app_class_eval(&block)
      self.app_class.class_eval &block
    end

    def app_instance_eval(&block)
      self.app_instance.instance_eval &block
    end

    ["before_action", "after_action", "around_action"].each do |m|
      m =~ /\A(.*?)_/
      type = $1
      class_eval <<RUBY, __FILE__, __LINE__ + 1
      def #{m}(action, &block)
        define_callbacks ('old_' + action.to_s)
        set_callback ('old_' + action.to_s), :#{type}, &block
        define_singleton_method "method_added" do |action_name|
          matchstring = Regexp.new('^' + action.to_s + '$')
          if matchstring.match action_name
            alias_method ('old_' + action.to_s).intern, action
            remove_method action
            define_method ("proxy_" + action.to_s) do |*args, &block|
              run_callbacks ('old_' + action.to_s) do
                __send__ ('old_' + action.to_s).intern , *args, &block
              end
            end
            define_method "method_missing" do |method, *args, &block|
              if matchstring.match method
                __send__ ("proxy_" + method.to_s), *args, &block
              end
            end
          end
        end
      end
RUBY
    end
  end

  # included in Dancefloor
  module Routable
    def self.included(base)
      base.__send__ :use, Rack::Flash
      base.__send__ :helpers, Sinatra::Partials
    end

    # Db is a constant in Studio54 scope
    include ::Studio54
    include ::Studio54::Config::Environment

    def controller(c_name, c_action, params={})
      require File.join(CONTROLLERSDIR, "#{c_name}_controller")
      require File.join(MODELSDIR, c_name[0...-1])
      begin
        controller = self.class.const_get("#{c_name.capitalize}Controller")
        controller_inst = controller.new
        result = if params.blank?
          controller_inst.__send__(c_action)
        else
          controller_inst.__send__(c_action, params)
        end
        controller_inst.instance_variables.each do |ivar|
          # establish non block-local scope
          ivar_value = nil
          controller_inst.instance_eval do
            ivar_value = instance_variable_get ivar
          end
          # self here is the instance of the application
          instance_variable_set ivar, ivar_value
        end
      ensure
        Db.conn.disconnect if Db.conn.kind_of? DBI::DatabaseHandle and
        Db.conn.connected?
      end
      result
    end

  end

end

