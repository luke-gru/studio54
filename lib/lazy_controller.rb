class LazyController < Studio54::Base
    include ::Studio54::Config::Environment

  class << self
    # all models are not required by default
    def require_models(*models)
      models.each do |m|
        require File.join(MODELSDIR, m.to_s)
      end
    end
    alias_method :require_model, :require_models

    def require_all_models
      Dir.glob(MODELSDIR + '/.*').each do |m_file|
        require m_file
      end
    end

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

    def controller(c_name, c_action)
      require File.join(CONTROLLERSDIR, "#{c_name}_controller")
      require File.join(MODELSDIR, c_name[0...-1])
      begin
      controller = self.class.const_get("#{c_name.capitalize}Controller")
      controller_inst = controller.new
      controller_inst.__send__(c_action)
      {}.tap do |h|
        controller_inst.instance_variables.each do |ivar|
          controller_inst.instance_eval do
            # @user = _user in templates
            # strip the @ from the instance variable and add '_'
            h[("_" + ivar.to_s[1..-1]).intern] = instance_variable_get ivar
          end
        end
      end
      ensure
        Db.conn.close if Db.conn
      end
    end

  end

end

