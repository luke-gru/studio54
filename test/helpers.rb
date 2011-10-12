module Studio54

  class Dancefloor

    def context(ivar_name="context")
      instance_variable_get "@#{ivar_name.to_s}"
    end

  end

end

