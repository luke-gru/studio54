class SerializeTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods
  include ::Studio54

  def app
    Dancefloor.new
  end

  def test_json_rendering
    @user = User.find(1)
    assert_equal  "{\"user\":{\"age\":\"22\",\"id\":\"1\",\"name\":\"luke\"}}", @user.to_json
  end

  def test_xml_rendering
    @user = User.find(1)
    assert_equal "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<user>\n  <id>1</id>\n  <name>luke</name>\n  <age>22</age>\n</user>\n", @user.to_xml
  end
end

