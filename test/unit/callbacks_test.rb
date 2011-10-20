class CallbackTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods
  include ::Studio54

  def app
    Dancefloor.new
  end

  def test_single_simple_callback
    u = User.new
    quaff = u.drink
    assert_equal 21, u.age
    assert_equal "mmm", quaff
  end
end

