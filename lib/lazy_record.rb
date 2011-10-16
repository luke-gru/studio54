class LazyRecord < Studio54::Base
  include ::Studio54
  RecordNotFound      = Class.new(StandardError)
  AssociationNotFound = Class.new(StandardError)

  def self.inherited(base)
    base.__send__(:include, ::Studio54)
    base.__send__(:cattr_accessor, :primary_key)
  end

  # if parameters are given, builds the model
  # object with the attributes from the given
  # parameters
  def initialize(params=nil)
    unless params.nil?
      self.build_from_params!(params)
    end
  end

  # used to keep track of all table attributes
  def self.tbl_attr_accessor *fields
    fields.each do |f|
      self.attributes << f unless self.attributes.include? f
    end
    self.__send__ :attr_accessor, *fields
  end

  def self.attributes
    @attributes ||= []
  end

  def self.nested_attributes
    @nested_attributes ||= []
  end

  def self.belongs_to_attributes
    @belongs_to_attributes ||= []
  end

  private

  # Barely does anything, just defines the accessor(s)
  # and makes sure the other model includes an appropriate
  # association as well. These methods are mainly for
  # documentation.
  #
  # The name of the model can be made explicit if it's different
  # from the default (taking off the trailing 's')
  # has_many {:tags => TagsModel}, {:comments => CommentsModel}
  def self.has_many *models
    models.each do |m|
      if m.is_a? Symbol
        model_string = m.to_s[0...-1]
        self.require_model model_string
        model_klass = Object.const_get m.to_s[0...-1].camelize
        ivar_name = m
      elsif m.is_a? Hash
        v = nil
        v_sym_name = nil
        m.each do |k, v|
          model_string = v.name.tableize
          self.require_model model_string
          model_klass  = Object.const_get v.name
          ivar_name = v_sym_name = model_string.intern
        end
      end
      # Make sure associated model #belongs_to this class.
      # The associated model is required automatically if
      # not already required manually.
      unless model_klass.belongs_to_attributes.include? self.name.
        tableize.intern
        raise AssociationNotFound.new "#{model_klass} doesn't #belong_to
      #{self.name}"
      end
      class_eval do
        define_method ivar_name do
          instance_variable_get "@#{ivar_name}" || []
        end
        attr_writer ivar_name
        self.nested_attributes << ivar_name unless
          self.nested_attributes.include? ivar_name
      end
    end
  end

  class << self
    # has_one has the same implementation as has_many
    alias_method :has_one, :has_many
  end

  # barely does anything, just works with has_many
  def self.belongs_to *models
    models.each do |m|
      self.belongs_to_attributes << m unless
        self.belongs_to_attributes.include? m
    end
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

  public

  # internal use only
  def build_from_params!(params)
    params.each do |k, v|
      self.__send__("#{k}=".intern, v)
    end
  end

  private

  # internal use only
  def self.test_resultset(res)
    if res.empty?
      raise RecordNotFound.new "Bad resultset #{res}"
    end
  end

  # associated table name, by default is just to add an 's' to the model
  # name
  def self.assoc_table_name=( tblname=self.name.downcase+'s' )
    self.__send__ :cattr_accessor, :table_name
    self.table_name = tblname.to_s
  end

  public

  # save current model instance into database
  def save
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
    if res.nil? or res.affected_rows != 1
      false
    else
      true
    end
  end


  # id is the primary key of the table, and does
  # not need to be named 'id' in the table itself
  # TODO take into account other dbms's, this only
  # works w/ mysql
  def self.find(id)
    sql = "SELECT * FROM #{self.table_name} WHERE #{self.primary_key} = #{id};"
    res = Db.query(sql)
    test_resultset res
    build_from res
  end


  def self.find_by(hash, options={})
    opts = {:composite => 'AND'}.merge options
    composite = opts[:composite]
    sql = "SELECT * FROM #{self.table_name} WHERE "
    hash.each do |k, v|
      sql += "#{k} = '#{v}' #{composite} "
    end
    case composite
    when 'AND'
      sql = sql[0...-4]
    when 'OR'
      sql = sql[0...-3]
    else
      raise "composite sql condition in #{__method__} must be one of AND, OR"
    end
    res = Db.query(sql)
    test_resultset res
    build_from res
  end

  def self.all
    sql = "SELECT * FROM #{self.table_name};"
    res = Db.query(sql)
    test_resultset res
    build_from res
  end

  private

  # internal use only
  def self.build_from(resultset)
    model_instances = [].tap do |m|
      resultset.each_hash do |h|
        model = self.new
        model.build_from_params! h
        m << model
      end
    end
    model_instances.length == 1 ? model_instances[0] :
    model_instances
  end

  public

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

