module Studio54
  class Db

    cattr_accessor :host
    cattr_accessor :user
    cattr_accessor :pass
    cattr_accessor :schema
    cattr_accessor :type
    cattr_accessor :conn

    self.host   = 'localhost'
    self.user   = 'root'
    self.pass   = 'root'
    self.schema = 'test'
    # Mysql
    self.type   = 'Mysql'

  end
end

