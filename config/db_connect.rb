module Studio54
  module Config
    begin
      # connect to the MySQL server
      Db.conn = Mysql.real_connect(Db.host, Db.user, Db.pass, Db.schema)
    rescue Mysql::Error => e
      puts "Error code: #{e.errno}"
      puts "Error message: #{e.error}"
      puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to? :sqlstate
    ensure
      # db is closed in lazy_controller
    end
  end
end

