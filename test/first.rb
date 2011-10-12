require "test/unit"
require "rack/test"
require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'config/environment')
require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'dance')
require_relative 'helpers'
require 'test/rack/helpers'

class IndexPageTest < Test::Unit::TestCase
  include Rack::Test::Methods
  include ::Studio54

  def app
    Dancefloor.new
  end

  def test_response
    get '/'
    context = nil; body = nil
    app = Base.app_instance
    context = app.context
    app.instance_eval do
      body = erb :index, {}, context
    end
    assert body, last_response.body
    assert_equal true, last_response.ok?
    assert_equal true, last_response.html?
  end

end

