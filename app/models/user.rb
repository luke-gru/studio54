class User < LazyRecord
  attr_primary :id
  has_many :posts
  tbl_attr_accessor :name, :age

  # validations
  validate :name_not_blank
  validate :age_greater_than_18
  def name_not_blank
    errors.add(:user, "Name can't be blank") if self.name.blank?
  end

  def age_greater_than_18
    errors.add(:user, "Age must be greater than 18") if self.age.to_i <= 18
  end

  define_callbacks :save
  set_callback :save, :before do |object|
  end

  def save
    run_callbacks :save do
      super
    end
  end

end

