class User < LazyRecord
  has_many :posts
  attr_primary :id
  tbl_attr_accessor :name, :age

  define_callbacks :save
  set_callback :save, :before do |object|
    object.name = "jeff"
    object.age = 60
  end

  def save
    run_callbacks :save do
      super
    end
  end

end

