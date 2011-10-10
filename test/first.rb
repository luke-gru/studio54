require "test/unit"
require "rack/test"
require 'erb'
require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'config/environment')
require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'dance')

class IndexPageTest < Test::Unit::TestCase
  include Rack::Test::Methods
  include ::Studio54
  # include Studio54::Rack::Test::Helpers

  def app
    Dancefloor.new
  end

  def test_response
    get '/'
    context = nil; body = nil
    app_instance = Base.app_instance
    app_instance.instance_eval do
      context = instance_variable_get "@context"
      body = erb :index, {}, context
    end
    assert body, last_response.body
    assert last_response.ok?
  end

end

