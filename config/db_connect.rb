module Studio54
  begin
    Db.conn.disconnect if Db.conn.kind_of? DBI::DatabaseHandle and
    Db.conn.connected?

    # connect to the MySQL server
    Db.conn = DBI.connect("DBI:#{Db.type}:#{Db.schema}:#{Db.host}",
                          Db.user, Db.pass)

  rescue DBI::DatabaseError => e
    puts "Error code: #{e.err}"
    puts "Error message: #{e.errstr}"
    puts "Error SQLSTATE: #{e.state}" if e.respond_to? :state

    # Db.conn is disconnected automatically if used in a controller
    # action
  end
end

