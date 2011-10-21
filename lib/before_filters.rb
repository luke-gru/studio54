module Studio54
  class Dancefloor
    # wraps Dancefloor class scope (app) for convenience
    Base.app_class = self

    before do
      load 'config/db_connect.rb' if self.class.environment ==
        :development
      # wraps Dancefloor instance scope (request) for convenience
      Base.app_instance = self

      # flash stuff
      self.class.instance_eval do
        unless @flash.nil?
          @flash.each do |k,v|
            Base.app_instance.instance_eval do
              @flash = {}
              if k != :errors
                @flash[k] = "<div id=#{k}>#{v}</div>"
              else
                @flash[k] = v
              end
            end
          end
          @flash = nil
        end
      end

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

