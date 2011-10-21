class IndexPageTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods
  include ::Studio54

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

  def test_flash_is_set_in_app_class
    get '/'
    app = Base.app_instance
    app_class = Base.app_class
    app.instance_eval do
      flash :notice => 'hey this is a flash notice'
    end
    flash = nil
    app_class.instance_eval do
      flash = @flash
    end
    assert_equal('hey this is a flash notice', flash[:notice])
  end

end

