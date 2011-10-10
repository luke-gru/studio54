module Studio54
  class Dancefloor
    # wraps Dancefloor class scope (app) for convenience
    Base.app_class = self

    before do
      load 'config/db_connect.rb'
      # wraps Dancefloor instance (request) scope for convenience
      Base.app_instance = self

      # if using shotgun, create a custom log format
      !settings.shotgun || begin
        req = request
        logger.class_eval do
        cattr_accessor :format
        self.__send__ :format=, <<-HTML
#{Time.now}
#{req.request_method} #{req.fullpath}
Content-Length: #{req.content_length}
Params:#{req.params}
HTML
        end
        logger.info logger.format
      end

    end
  end
end

