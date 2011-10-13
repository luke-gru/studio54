class User < LazyRecord
  has_many :posts
  attr_primary :id
  tbl_attr_accessor :name, :age
end

