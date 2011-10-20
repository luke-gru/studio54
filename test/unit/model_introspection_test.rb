class ModelIntrospectionTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods
  include ::Studio54

  def app
    Dancefloor.new
  end

  def test_tbl_attribute_introspection
    assert_equal :id, User.primary_key
    assert_equal [:name, :age], User.attributes
    assert_equal [:id, :name, :age], User.all_attributes
  end

  def test_default_tbl_name
    assert_equal 'posts', Post.table_name
  end

  def test_custom_tbl_name
    User.class_eval do
      self.assoc_table_name = 'special_users'
    end
    assert_equal 'special_users', User.table_name
    # and change back so unordered tests don't break
    User.class_eval do
      self.assoc_table_name = 'users'
    end
    assert_equal 'users', User.table_name
  end

  def test_composite_primary_key
    Post.class_eval do
      attr_primary :id, :user_id
    end
    assert_equal [:id, :user_id], Post.primary_key
    # and change back so unordered tests don't break
    Post.class_eval do
      attr_primary nil
    end
    assert_equal nil, Post.primary_key
  end

end

