class User < LazyRecord
  attr_primary :id
  has_many :posts
  tbl_attr_accessor :name, :age
  attr_accessor :humor
  attr_accessor :email

  # validations
  validates_presence_of :humor
  validates_length_of :name, :minimum => 5, :message => 'is too short'
  validates_numericality_of :age, :less_than => 99, :message => 'must be less than 99'
  validates_format_of :email, :without => /SPAM/

  validate :name_not_blank
  validate :age_greater_than_18
  def name_not_blank
    errors.add(:name, "can't be blank") if self.name.blank?
  end

  def age_greater_than_18
    errors.add(:age, "must be greater than 18") if self.age.to_i <= 18
  end

  define_callbacks :drink
  set_callback :drink, :before do |obj|
    obj.age = 21
  end
  def drink
    run_callbacks :drink do
      "mmm"
    end
  end

  define_callbacks :save
  set_callback :save, :before do |object|
    @humor = true
  end

  def save
    run_callbacks :save do
      super
    end
  end

end

