class User < LazyRecord
  attr_primary :id
  attr_accessor :name
  attr_accessor :age
end

