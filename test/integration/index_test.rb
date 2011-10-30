class IndexPageTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods
  include Studio54

  def app
    Dancefloor.new
  end

  def test_callbacks_working
    get '/'
    var = nil
    Base.app_instance.instance_eval do
      var = @second_user
    end
    assert_equal 'me', var
  end

  def test_index_response
    get '/'
    app = Base.app_instance
    body = nil
    app.instance_eval do
      body = erb :index
    end
    assert_equal body, last_response.body
    assert_equal true, last_response.ok?
    assert_equal true, last_response.html?
  end

  def test_flash_is_set
    get '/'
    app = Base.app_instance
    flashy = nil
    app.instance_eval do
      flashy = flash[:notice]
    end
    assert_equal('hi', flashy)
  end

end

