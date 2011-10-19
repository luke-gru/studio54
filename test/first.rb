class IndexPageTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods
  include ::Studio54

  def app
    Dancefloor.new
  end

  def test_response
    get '/'
    app = Base.app_instance
    body = nil
    app.instance_eval do
      body = erb :index
    end
    assert body, last_response.body
    assert_equal true, last_response.ok?
    assert_equal true, last_response.html?
  end

end

