class LazyRecord < Studio54::Base
  include ::Studio54
  # ActiveModel::Callbacks Base.class_eval {includes ActiveSupport::Callbacks}
  extend  ActiveModel::Callbacks
  include ActiveModel::Serializers::JSON
  include ActiveModel::Serializers::Xml
  extend  ActiveModel::Naming
  extend  ActiveModel::Translation
  include ActiveModel::Validations

  RecordNotFound      = Class.new(StandardError)
  AssociationNotFound = Class.new(StandardError)

  def self.inherited(base)
    base.class_eval do
      cattr_accessor :primary_key
      attr_reader :errors
    end
  end

  # if parameters are given, builds the model
  # object with the attributes from the given
  # parameters
  def initialize(params=nil)
    unless params.nil?
      self.build_from_params!(params)
    end
    @errors = ActiveModel::Errors.new(self)
  end

  # used to keep track of all table attributes
  def self.tbl_attr_accessor *fields
    fields.each do |f|
      self.attributes << f.to_s unless self.attributes.include? f.to_s
    end
    self.__send__ :attr_accessor, *fields
  end

  def self.attributes
    @attributes ||= []
  end

  def self.all_attributes
    @all_attributes ||= begin
      attrs = @attributes.dup
      attrs.unshift primary_key
    end
  end

  def self.nested_attributes
    @nested_attributes ||= []
  end

  def self.belongs_to_attributes
    @belongs_to_attributes ||= []
  end

  private

  # Defines the accessor(s) and makes sure the other model includes
  # an appropriate association as well.
  #
  # The name of the model can be made explicit if it's different
  # from the default (chop the trailing 's' off from the model name).
  #
  # Example:
  # has_many :tags, {:through => 'tags_articles', :fk => 'article_id'}
  def self.has_many model, options={}
    # @join_tables:
    # Used with LR#build_associated, to find out what the join table and
    # the foreign key are. If not found, it generates default ones by the
    # heuristic explained above the LR#build_associated method declaration.
    @join_tables ||= {}
    unless @join_tables[model]
      @join_tables[model] = {}
    end
    if through = options[:through]
      @join_tables[model][:through] = through
    end
    if fk = options[:fk]
      @join_tables[model][:fk] = fk
    end

    model_string = model.to_s.singularize
    self.require_model model_string
    model_klass = Object.const_get model_string.camelize
    ivar_name = model

    # Make sure associated model #belongs_to this class.
    unless model_klass.belongs_to_attributes.include? self.name.
      tableize
      raise AssociationNotFound.new "#{model_klass} doesn't #belong_to " \
        "#{self.name}"
    end
    class_eval do
      define_method ivar_name do
        instance_variable_get("@#{ivar_name}") || []
      end
      attr_writer ivar_name
      self.nested_attributes << ivar_name
    end
  end

  class << self
    # has_one has the same implementation as has_many
    alias_method :has_one, :has_many
  end

  # barely does anything, just works with has_many
  def self.belongs_to *models
    models.each do |m|
      self.belongs_to_attributes << m.to_s
    end
  end

  def self.attr_primary(*fields)
    if fields.length == 1
      self.primary_key = fields[0].to_s != "" ? fields[0].to_s : nil
    else
      self.primary_key = fields.map {|f| f.to_s }
    end
    class_eval do
      fields.each do |f|
        attr_accessor f unless f.nil?
      end
    end
  end

  # associated table name, by default is just to add an 's' to the model
  # name
  def self.assoc_table_name=( tblname=self.name.tableize )
    self.__send__ :cattr_accessor, :table_name
    self.table_name = tblname.to_s
  end

  public

  # meant for internal use
  def build_from_params!(params)
    params.each do |k, v|
      self.__send__("#{k}=".intern, v)
    end
  end

  # Have to implement Model#attributes to play nice
  # with ActiveModel serializers
  def attributes(options={})
    opts = {:include_pk => true}.merge options
    if opts[:include_pk]
      attrs = self.class.all_attributes
    else
      attrs = self.class.attributes
    end
    {}.tap do |h|
      attrs.each do |a_name|
        h[a_name] = instance_variable_get "@#{a_name}"
      end
    end
  end

  # save current model instance into database
  def save
    return unless valid?
    sql = "INSERT INTO #{self.class.table_name} ("
    fields = self.class.attributes
    sql += fields.join(', ') + ') VALUES ('
    fields.each {|f| sql += '?, '}
    sql = sql[0...-2] + ')'
    values = fields.map do |f|
      ivar = instance_variable_get "@#{f}"
      if ivar.nil?
        "NULL"
      else
        ivar
      end
    end
    result = nil
    self.class.db_try do
      result = Db.conn.execute sql, *values
    end
    result ? true : false
  end

  # delete the current model instance from the database
  def destroy(options={})
    if options[:where]
    else
      sql = "DELETE FROM #{self.class.table_name} WHERE " \
            "#{self.primary_key} = ?"
      result = nil
      self.class.db_try do
        result = Db.conn.execute sql,
          instance_variable_get("@#{self.primary_key}")
      end
      result
    end
  end

  # update the current model instance in the database
  def update_attributes(params, extra_where={})
    values = []
    key = self.primary_key
    id = params.delete key
    if extra_where.blank?
      sql = "UPDATE #{self.class.table_name} SET "
      params.each do |k,v|
        sql += "#{k} = ?, "
        values << v
      end
      sql = sql[0...-2]
      sql += " WHERE #{key} = ?"
      values << id
    else
    end
    res = nil
    self.class.db_try do
      res = Db.conn.execute sql, *values
    end
    res
  end

  # This method uses the model instance's class::has_many()
  # method to determine what the join table is called. The
  # default join table name that this method uses if no
  # options were given to Model::has_many() (see Model::has_many()
  # for the passable options) is the following:
  #
  # the tbl argument (for example, :tags), concatenated with
  # `self`'s class's table name (for example, 'articles')
  # to make 'tags_articles'
  #
  # The default foreign key uses a similar heuristic. For the
  # example above, it would be 'article_id', because `self`'s
  # table name is `articles`, and the singular is 'article'. This
  # is then concatenated with '_id'
  #
  # To override the defaults, provide options to Model::has_many()
  def build_associated tbl
    self_tbl = self.class.table_name
    through = if _through = self.class.
             instance_variable_get("@join_tables")[tbl][:through]
      _through
    else
      "#{tbl}_#{self_tbl}"
    end
    fk = if _fk = self.class.
           instance_variable_get("@join_tables")[tbl][:fk]
      _fk
    else
      "#{self_tbl.singularize}_id"
    end

    pk = self.class.primary_key
    id = __send__ pk
    sql = "SELECT * FROM #{through} WHERE #{fk} = ?"
    res = nil
    self.class.db_try do
      res = Db.conn.execute sql, id
    end
    model_name = tbl.to_s.singularize.capitalize

    begin
      tbl_model = Object.const_get(model_name)
    rescue NameError
      retry if require "app/models/#{model_name.downcase}"
    end

    objs = tbl_model.build_from res
    objs = Array.wrap(objs) unless Array === objs
    __send__("#{tbl}=", __send__(tbl) + objs) unless objs.blank?
  end

  def self.db_try
    begin
      yield
    rescue DBI::DatabaseError
      @retries ||= 0; @retries += 1
      if @retries == 1
        load 'config/db_connect.rb'
        retry
      else
        raise
      end
    end
  end

  # id is the primary key of the table, and does
  # not need to be named 'id' in the table itself
  # TODO take into account other dbms's, this only
  # works w/ mysql
  def self.find(id)
    sql = "SELECT * FROM #{self.table_name} WHERE #{self.primary_key} = ?"
    res = nil
    db_try do
      res = Db.conn.execute sql, id
    end
    build_from res
  end

  def self.find_by(hash, options={})
    opts = {:conjunction => 'AND'}.merge options
    conj = opts[:conjunction]
    sql = "SELECT * FROM #{self.table_name} WHERE "
    values = []
    hash.each do |k, v|
      sql += "#{k} = ? #{conj} "
      values << v
    end
    case conj
    when 'AND'
      sql = sql[0...-4]
    when 'OR'
      sql = sql[0...-3]
    else
      raise "conjunction in sql condition (WHERE) must be one of AND, OR"
    end
    res = nil
    db_try do
      res = Db.conn.execute sql, *values
    end
    build_from res
  end

  def self.all
    sql = "SELECT * FROM #{self.table_name}"
    res = nil
    db_try do
      res = Db.conn.execute(sql)
    end
    build_from res, :always_return_array => true
  end

  private

  # meant for internal use
  def self.build_from(resultset, options={})
    opts = {:always_return_array => false}.merge options
    test_resultset resultset
    model_instances = [].tap do |m|
      resultset.fetch_hash do |h|
        model = self.new
        model.build_from_params! h
        m << model
      end
      resultset.finish
    end
    model_instances.length == 1 && !opts[:always_return_array] ?
      model_instances[0] : model_instances
  end

  # meant for internal use
  def self.test_resultset(res)
    if res.blank?
      raise RecordNotFound.new "Bad resultset #{res}"
    end
  end

  public

  class << self
    def method_missing(method, *args, &block)
      if method =~ %r{find_by_(.*)}
        h_args = {$1 => args[0]}
        return __send__ :find_by, h_args, &block
      end

      if method =~ %r{table_name}
        return __send__ :assoc_table_name=
      end

      super
    end
  end

end

# Arrays should respond to build_associated just like models.
class Array
  def build_associated tbl
    each do |m|
      m.__send__ :build_associated, tbl
    end
  end
end

