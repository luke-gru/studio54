class IndexPageTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods
  include ::Studio54

  def app
    Dancefloor.new
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
    app_class = Base.app_class
    app.instance_eval do
      flash :notice => 'hey this is a flash notice'
    end
    flash_msg = nil
    app_class.instance_eval do
      flash_msg = @flash
    end
    assert_equal({:notice => 'hey this is a flash notice'}, flash_msg)
  end

  def test_ActiveModel_callbacks_working

  end

end

