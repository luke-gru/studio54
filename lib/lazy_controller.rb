class LazyController

  module Routable
    include ::Studio54::Config::Environment

    def controller(c_name, c_action)
      require File.join(CONTROLLERSDIR, "#{c_name}_controller")
      require File.join(MODELSDIR, c_name[0...-1])
      controller = self.class.const_get("#{c_name.capitalize}Controller")
      action = controller.instance_method c_action
      controller_inst = controller.new
      action.bind(controller_inst).call
      {}.tap do |h|
        controller_inst.instance_variables.each do |ivar|
          controller_inst.instance_eval do
            h[ivar.to_s[1..-1].intern] = instance_variable_get ivar
          end
        end
      end
    end

  end

end

