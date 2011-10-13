class LazyRecord < Studio54::Base
  include ::Studio54
  RecordNotFound = Class.new(StandardError)

  def self.attr_accessor *fields
    fields.each do |f|
      self.attributes << f unless self.attributes.include? f
    end
    super *fields
  end

  def self.attributes
    @attributes ||= []
  end

  def initialize(params=nil)
    unless params.nil?
      self.build_from_params!(params)
    end
  end

  def self.inherited(base)
    base.__send__(:include, ::Studio54)
    base.__send__(:cattr_accessor, :primary_key)
  end

  def self.attr_primary(*fields)
    if fields.length == 1
      self.primary_key = fields[0]
    else
      self.primary_key = fields
    end
    class_eval do
      attr_accessor *fields
    end
  end

  # only works for mysql
  def self.test_resultset(res)
    if res.num_rows.zero?
      raise RecordNotFound.new "Bad resultset #{res}"
    end
  end

  # TODO take into account fully qualified tables
  def build_from_resultset!(res)
    fields = [].tap do |a|
      res.fetch_fields.each do |field|
        a << field.name
      end
    end
    params = {}.tap do |p|
      res.each_hash do |row|
        fields.each do |field|
          p[field] = row[field]
          #self.__send__("#{field}=".intern, row[field])
        end
      end
    end
    self.build_from_params!(params)
    self
  end

  def build_from_params!(params)
    params.each do |k, v|
      self.__send__("#{k}=".intern, v)
    end
  end
  alias_method :build, :build_from_params!

  # mysql specific: affected rows
  def insert(rows=1)
    sql = "INSERT INTO #{self.class.table_name} ("
    fields = self.class.attributes
    sql += fields.join(', ') + ') VALUES ('
    values = fields.map {|f| instance_variable_get "@#{f}"}
    values.each do |v|
      if v.nil?
        sql += 'NULL, '
      else
        sql += "'#{v}', "
      end
    end
    sql = sql[0...-2] + ');'
    res = Db.query(sql)
    if res.nil? or res.affected_rows != rows
      return false
    else
      true
    end
  end
  alias_method :save, :insert

  # associated table name, by default is just to add an 's' to the model
  # name
  def self.assoc_table_name=( tblname=self.name.downcase+'s' )
    self.__send__ :cattr_accessor, :table_name
    self.table_name = tblname.to_s
  end

  # id is the primary key of the table, and does
  # not need to be named 'id' in the table itself
  # TODO take into account other dbms's, this only
  # works w/ mysql
  def self.find(id)
    sql = "SELECT * FROM #{self.table_name} WHERE #{self.primary_key} = #{id};"
    res = Db.query(sql)
    test_resultset res
    model = self.new
    model.build_from_resultset!(res)
  end


  def self.find_by(mult='AND', hash)
    sql = "SELECT * FROM #{self.table_name} WHERE "
    hash.each do |k, v|
      sql += "#{k} = '#{v}' #{mult} "
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
    test_resultset res
    model = self.new
    model.build_from_resultset!(res)
  end

  class << self
    def method_missing(method, *args, &block)
      if method =~ %r{find_by_(.*)}
        h_args = {$1 => args[0]}
        return self.__send__ :find_by, h_args, &block
      end

      if method =~ %r{table_name}
        return self.__send__ :assoc_table_name=
      end

      super
    end
  end

end

