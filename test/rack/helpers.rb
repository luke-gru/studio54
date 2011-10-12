module Rack
  class MockResponse

    # these methods are defined by Sinatra, but just
    # in case...
    def content_length
      self["Content-Length"]
    end unless method_defined? :content_length

    def content_type
      self["Content-Type"]
    end unless method_defined? :content_type

    # Not a good method, but probably good enough...
    def html?
      body = Array.wrap(self.body)
      content_type =~ %r{text/html} and
      body.detect {|e| e =~ %r{<\w>} || e =~ %r{<br}}.present?
    end

  end
end

