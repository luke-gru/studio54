class User < LazyRecord
  has_many :posts
  attr_primary :id
  tbl_attr_accessor :name, :age

  # validations

  validate :name_not_blank
  def name_not_blank
    errors.add(:user, "Name can't be blank") if self.name.blank?
  end

  define_callbacks :save
  set_callback :save, :before do |object|
    object.name = ""
    object.age = 60
  end

  def save
    run_callbacks :save do
      super
    end
  end

end

