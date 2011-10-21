class ValidationTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods
  include ::Studio54

  def app
    Dancefloor.new
  end

  def test_blank_user
    u = User.new
    u.name = ""
    assert_equal false, u.valid?
    assert_equal 5, u.errors.count
  end

  def test_young_user
    u = User.new
    # should be > 18
    u.age = 17
    u.name = "Katelin"
    u.humor = true
    assert_equal false, u.valid?
  end

  def test_short_named_user
    u = User.new
    u.age = 29
    u.name = "jon"
    u.humor = true
    assert_equal false, u.valid?
    assert_equal ["is too short"], u.errors[:name]
    assert_equal ["Name is too short"], u.errors.full_messages
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
    assert_equal ["can't be blank"] , u.errors[:humor]
    assert_equal ["Humor can't be blank"], u.errors.full_messages
  end

  def test_numericality_of_age
    u = User.new
    u.age = 100
    u.name = "Shania Twain"
    u.humor = true
    assert_equal false, u.valid?
    assert_equal 1, u.errors.count
    assert_equal ["must be less than 99"], u.errors[:age]
  end

  def test_format_email
    u = User.new
    u.age = 30
    u.name = "jack gonzo"
    u.humor = true
    u.email = "SPAM"
    assert_equal false, u.valid?
    assert_equal 1, u.errors.count
    assert_equal ["is invalid"], u.errors[:email]
  end
end

