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
    self.type   = 'mysql'

    # The basic query interface method: Db.query(statement)
    if self.type == 'mysql'
      class << self
        def query(stmt)
          self.conn.query(stmt)
        end
      end
    else
    end


    case self.type
    when 'mysql'
      require "mysql"
    when 'postgresql'
      require "postgres"
    else
      raise "Unrecognized database type #{self.type}"
    end

  end
end

# The basic resultset interface methods
case Studio54::Db.type
when 'mysql'
  # should really be a module
  class Mysql
    class Result
      def empty?
        self.num_rows.zero?
      end
    end
  end
else
end

