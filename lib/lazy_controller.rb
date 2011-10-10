class LazyController < Studio54::Base

  module Routable
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

