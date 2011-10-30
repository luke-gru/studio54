class Studio54::Dancefloor
  helpers do
    include Rack::Utils
    # have to explicitly use h(...) to escape html
    alias_method :h, :escape_html
  end
end

module Sinatra
  class Response

    def set_content_length!
      self["Content-Length"] =
        self.body.inject(0) {|a, l| a += l.length}
    end

    def send(status=200)
      set_content_length!
      [status, self.headers, self.body]
    end

  end
end

