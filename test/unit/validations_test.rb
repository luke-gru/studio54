class ValidationTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods
  include ::Studio54

  def app
    Dancefloor.new
  end

  def test_blank_user
    u = User.new
    assert_equal false, u.valid?
    assert_equal 3, u.errors[:user].count
  end

  def test_young_user
    u = User.new
    # should be > 18
    u.age = 17
    u.name = "Kate"
    u.humor = true
    assert_equal false, u.valid?
  end

  def test_valid_user
    u = User.new
    u.age = 19
    u.name = "Andrew Dice Clay"
    u.humor = true
    assert_equal true, u.valid?
  end

  def test_presence_validation
    u = User.new
    u.age = 25
    u.name = "Mel Brooks"
    assert_equal false, u.valid?
    assert_equal({:user => ["humor can't be blank"]}, u.errors)
  end
end

