class DatabaseTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods
  include ::Studio54

  def app
    Dancefloor.new
  end

  def test_empty_resultset
    empty_results = []
    assert_raises(LazyRecord::RecordNotFound) do
      User.class_eval do
        test_resultset empty_results
      end
    end
  end

  def test_non_empty_results
    non_empty_results = [1,2,3]
    ret = nil
    User.class_eval do
      ret = test_resultset non_empty_results
    end
    assert_nil ret
  end

  def test_invalid_save
    u = User.new
    assert_nil u.save
  end

  def test_simple_id_find
    @user = User.find(1)
    assert_equal User, @user.class
    assert_equal 1, @user.id.to_i
    assert_equal 'luke', @user.name
    assert_equal 22, @user.age.to_i
  end

  # need to fix find_by to take into account ORs with the same
  # field name, and a mixture of ANDs and ORs, need a composites
  # hash with a length equal to the sum of the previous arguments
  def test_find_by_conjunction_AND
    @users = User.find_by :name => 'david', :age => 44
    assert_equal 2, @users.count
  end

  def test_find_by_conjunction_OR
    @users = User.find_by({:name => 'luke', :age => 44}, :conjunction => "OR")
    assert_equal 6, @users.count
  end

  def test_dynamic_find
    @user = User.find_by_name 'rick'
    assert_equal 13, @user.id.to_i
  end

  def test_build_user_from_params
    params = {:user => {:name => 'luke', :age => '22'}}
    @user = User.new params[:user]
    assert_equal 'luke', @user.name
    assert_equal '22', @user.age
  end

  def test_find_all_from_tbl
    @users = User.all
    sql = "SELECT * FROM users;"
    res = Db.conn.execute(sql)
    assert_equal res.count, @users.count
  end

end

