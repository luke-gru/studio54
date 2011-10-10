module Studio54
  class Db

    cattr_accessor :host
    cattr_accessor :user
    cattr_accessor :pass
    cattr_accessor :schema
    cattr_accessor :type

    cattr_accessor :conn

    class << self
      def query(stmt)
        self.conn.query(stmt)
      end
    end

    self.host   = 'localhost'
    self.user   = 'root'
    self.pass   = 'root'
    self.schema = 'test'
    self.type   = 'mysql'

    case self.type
    when "mysql"
      require "mysql"
    when "postgresql"
      require "postgresql"
    else
      raise "Unrecognized database type #{self.type}"
    end

  end
end

