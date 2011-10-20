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
    self.conn   = nil
    # self.conn is set in config/db_connect.rb

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
      def count
        self.num_rows
      end

      def empty?
        count.zero?
      end
      # Mysql library already defines Result#affected_rows.
      # All other dbms gems should adhere to this interface.
    end
  end
else
  raise "Unrecognized database type #{Studio54::Db.type}"
end

