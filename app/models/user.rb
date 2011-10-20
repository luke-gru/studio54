class User < LazyRecord
  attr_primary :id
  has_many :posts
  tbl_attr_accessor :name, :age

  def attributes(options={})
    opts = options.merge :include_pk => true
    if opts[:include_pk]
      attrs = self.class.all_attributes
    else
      attrs = self.class.attributes
    end
    {}.tap do |h|
      attrs.each do |a_name|
        h[a_name] = instance_variable_get "@#{a_name}"
      end
    end
  end

  def self.validate_presence_of *fields
    fields.each do |f|
      validate :"#{f}_not_blank"
      define_method :"#{f}_not_blank" do
        errors.add(self.class.table_name.singularize, "#{f} can't be blank") if (self.__send__ :"#{f}").blank?
      end
    end
  end
  attr_accessor :humor
  validate_presence_of :humor

  # validations
  validate :name_not_blank
  validate :age_greater_than_18
  def name_not_blank
    errors.add(:user, "Name can't be blank") if self.name.blank?
  end

  def age_greater_than_18
    errors.add(:user, "Age must be greater than 18") if self.age.to_i <= 18
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
  end

  def save
    run_callbacks :save do
      super
    end
  end

end

