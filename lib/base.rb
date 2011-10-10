module Studio54
  class Base
    # wrap Sinatra's scopes for convenience
    # within the controller and model
    cattr_accessor :app_class
    cattr_accessor :app_instance
  end
end

