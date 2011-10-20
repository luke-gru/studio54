class IndexPageTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods
  include ::Studio54

  ::NewKlass = Class.new(LazyRecord)

  def app
    Dancefloor.new
  end

  def test_has_many_without_reciprocation
    Post.tap do |p|
      assert_raises(LazyRecord::AssociationNotFound) do
        p.class_eval do
          has_many :users
        end
      end
    end
  end

  def test_reciprocal_association
    Post.tap do |p|
      p.class_eval { belongs_to :users, :new_klass }
      assert_equal [:users, :new_klass], p.belongs_to_attributes
    end
    User.tap do |u|
      u.class_eval { has_many :posts   }
      assert_equal [:posts], u.nested_attributes
    end
  end

end

