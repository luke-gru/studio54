class LazyController < Studio54::Base

  class << self

    def app_class_eval(&block)
      self.app_class.class_eval &block
    end

    def app_instance_eval(&block)
      self.app_instance.instance_eval &block
    end

  end

  # included in Dancefloor
  module Routable
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
        Db.conn.close if Db.conn
      end
      result
    end

  end

end

