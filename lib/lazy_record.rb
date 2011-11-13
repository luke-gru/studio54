class LazyRecord < Studio54::Base
  include ::Studio54
  # ActiveModel::Callbacks Base.class_eval { includes ActiveSupport::Callbacks }
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
      build_from_params!(params)
    end
    @errors = ActiveModel::Errors.new(self)
  end

  # used to keep track of all table attributes
  def self.tbl_attr_accessor *fields
    fields.each do |f|
      self.attributes << f.to_s
    end
    attr_accessor *fields
  end

  # used to keep track of all attributes that aren't
  # directly related to this model, but another model
  def self.join_tbl_attr_accessor *fields
    fields.each do |f|
      self.join_attributes << f.to_s
    end
    attr_accessor *fields
  end

  def self.attributes
    @attributes ||= []
  end

  def self.join_attributes
    @join_attributes ||= []
  end

  def self.all_attributes
    if Array === primary_key
      primary_key + attributes
    else
      [primary_key] + attributes
    end
  end

  def self.nested_attributes
    @nested_attributes ||= []
  end

  def self.belongs_to_attributes
    @belongs_to_attributes ||= []
  end

  # create database timestamp accessors
  def self.timestamps options={}
    # timestamp columns in the database
    cattr_accessor :timestamp_cols
    if options[:default]
        attr_accessor  :created_at
        attr_accessor  :updated_at
        self.timestamp_cols = { :create => :created_at, :update => :updated_at }
    else
      if update = options[:update]
        attr_accessor update.intern
        self.timestamp_cols = { :update => update.intern }
      end
      if create = options[:create]
        attr_accessor create.intern
        self.timestamp_cols = { :create => create.intern }
      end
    end
  end

  private

  # Defines the accessor(s) and makes sure the other model includes
  # an appropriate association as well.
  #
  # The name of the model can be made explicit if it's different
  # from the default (chop the trailing 's' off from the model name).
  #
  # Example:
  # has_many :tags, {:through => 'tags_articles', :fk => 'tagid'}
  #
  # default
  # =======
  #
  # has_many :tags
  #
  # is equivalent to
  #
  # has_many :tags, {:through => 'tags_articles', :fk => 'tag_id'}
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

    # Make sure associated model #belongs_to this class.
    unless model_klass.belongs_to_attributes.include? self.name.
      tableize
      raise AssociationNotFound.new "#{model_klass} doesn't #belong_to " \
        "#{self.name}"
    end
    class_eval do
      define_method model do
        instance_variable_get("@#{model}") || []
      end
      attr_writer model
      self.nested_attributes << model.to_s
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

  def self.attr_primary *fields
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

  # Associated table name, by default is the same as rails.
  # It just uses the Inflector ActiveSupport::Inflections Inflector :tableize
  def self.associated_tbl_name(tblname=self.name.tableize)
    cattr_accessor :table_name
    self.table_name = tblname.to_s
  end

  public

  # meant for internal use
  def build_from_params!(params)
    params.each do |k, v|
      __send__("#{k}=", v)
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
    sql = "INSERT INTO #{self.table_name} ("
    fields = self.class.attributes
    sql << fields.join(', ') + ') VALUES ('
    fields.each {|f| sql << '?, '}
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
    db_try do
      result = Db.conn.execute sql, *values
    end
    result ? true : false
  end

  # delete the current model instance from the database
  def delete(options={})
    if options[:where]
    else
      sql = "DELETE FROM #{self.table_name} WHERE " \
            "#{self.primary_key} = ?"
      result = nil
      db_try do
        result = Db.conn.execute sql,
          instance_variable_get("@#{self.primary_key}")
      end
      result
    end
  end
  alias destroy delete

  # update the current model instance in the database
  def update(params, extra_where={})
    update_timestamp = self.timestamp_cols[:update]
    values = []
    key = self.primary_key
    id = params.delete key
    sql = ""
    if extra_where.blank?
      sql << "UPDATE #{self.table_name} SET "
      if update_timestamp
        sql << "#{update_timestamp} = ?, "
        values << SQLTime.timestamp
      end
      params.each do |k,v|
        sql << "#{k} = ?, "
        values << v
      end
      sql = sql[0...-2]
      sql << " WHERE #{key} = ?"
      values << id
    else
    end
    res = nil
    db_try do
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
  # example above, it would be 'tag_id', because the given
  # table name is 'tags', and the singular is 'tag'. This
  # is then concatenated with '_id'
  #
  # To override the defaults, provide options to Model::has_many()
  def build_associated tbl
    self_tbl = self.table_name
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
      "#{tbl.to_s.singularize}_id"
    end

    tbl_model_name = tbl.to_s.singularize.camelize
    begin
      tbl_model = Object.const_get tbl_model_name
    rescue NameError
      retry if require "app/models/#{tbl_model_name.downcase}"
    end
    pk = self.primary_key
    sql =
      "SELECT * FROM #{tbl} INNER JOIN #{through} ON #{tbl}." \
      "#{tbl_model.primary_key} = #{through}.#{fk} WHERE #{through}." \
      "#{self_tbl.singularize + '_id'} = ?"

    id = __send__ pk
    res = nil
    db_try do
      res = Db.conn.execute sql, id
    end
    objs = tbl_model.build_from res
    objs = Array.wrap(objs) unless Array === objs
    __send__("#{tbl}=", __send__(tbl) + objs) unless objs.blank?
  end

  def self.db_try &block
    begin
      block.call
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

  def db_try &block
    self.class.db_try &block
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
      sql << "#{k} = ? #{conj} "
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
    build_from res, :always_return_array => true
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

  # convenience method
  def build_from(resultset, options={})
    self.class.build_from(resultset, options)
  end

  # meant for internal use
  def self.test_resultset(res)
    if res.blank?
      raise RecordNotFound.new "Bad resultset #{res}"
    end
  end

  public

  def method_missing(method, *args, &block)
    if method =~ %r{table_name}
      return self.class.__send__ :associated_tbl_name
    end
    super
  end

  class << self
    def method_missing(method, *args, &block)
      if method =~ %r{find_by_(.*)}
        h_args = {$1 => args[0]}
        return __send__ :find_by, h_args, &block
      end

      if method =~ %r{table_name}
        return __send__ :associated_tbl_name
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

