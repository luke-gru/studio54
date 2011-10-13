module Studio54
  class Base
    include Config::Environment
    # wrap Sinatra's scopes for convenience
    # within the controller and model
    cattr_accessor :app_class
    cattr_accessor :app_instance

    # All models are not required by default. These are helper
    # methods to aid doing it manually
    def self.require_models(*models)
      models.each do |m|
        require File.join(MODELSDIR, m.to_s)
      end
    end

    class << self
      alias_method :require_model, :require_models
    end

    def self.require_all_models
      Dir.glob(MODELSDIR + '/.*').each do |m_file|
        require m_file
      end
    end

  end
end

