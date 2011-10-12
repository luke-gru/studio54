class LazyRecord < Studio54::Base
  include ::Studio54
  RecordNotFound = Class.new(StandardError)

  def self.inherited(base)
    base.__send__(:include, ::Studio54)
    base.__send__(:cattr_accessor, :primary_key)
  end

  def self.attr_primary(field)
    self.primary_key = field
    class_eval do
      attr_accessor field.intern
    end
  end

  # TODO take into account fully qualified tables
  def build_from_resultset!(res)
    fields = [].tap do |a|
      res.fetch_fields.each do |field|
        a << field.name
      end
    end
    res.each_hash do |row|
      fields.each do |field|
        self.__send__("#{field}=".intern, row[field])
      end
    end
    self
  end

  # associated table name, by default is just to add an 's' to the model
  # name
  def self.assoc_table_name=( tblname=self.name.downcase+'s' )
    self.__send__ :cattr_accessor, :table_name
    self.table_name = tblname
  end

  # id is the primary key of the table, and does
  # not need to be named 'id' in the table itself
  # TODO take into account other dbms's, this only
  # works w/ mysql
  def self.find(id)
    sql = "SELECT * FROM #{self.table_name} WHERE #{self.primary_key} = #{id};"
    res = Db.query(sql)
    model = self.new
    model.build_from_resultset!(res)
  end

  class << self

    def find_by(hash, mult='AND', &block)
      sql = "SELECT * FROM #{self.table_name} WHERE "
      hash.each do |k, v|
        sql += "#{k} = #{v} #{mult} "
      end
      case mult
      when 'AND'
        sql = sql[0...-4]
      when 'OR'
        sql = sql[0...-3]
      else
        raise "multiple conditions in #{__method__} must be one of AND, OR"
      end
      res = Db.query(sql)
      model = self.new
      model.build_from_resultset!(res)
    end

    def method_missing(method, *args, &block)
      if method =~ %r{find_by_(.*)}
        h_args = {$1.to_sym => args[0]}
        return self.__send__ :find_by, h_args, &block
      end

      if method =~ %r{table_name}
        return self.__send__ :assoc_table_name=
      end

      super
    end

  end

end

