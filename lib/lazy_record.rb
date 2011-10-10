class LazyRecord < Studio54::Base
  include ::Studio54
  RecordNotFound = Class.new(::StandardError)

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

  def self.tableize(class_name, options={"pluralize" => 's'})
    pluralize = options.delete "pluralize"
    pluralize == 's' ? class_name.downcase + pluralize :
      begin
        # take into account others pluralizations
      end
  end

  # id is the primary key of the table, and does
  # not need to be named 'id' in the table itself
  #
  # TODO take into account other dbms's, this only
  # works w/ mysql
  def self.find(id, options={"pluralize" => 's'})
    opts = options.delete "pluralize"
    if options.empty?
      res = Db.query("SELECT * FROM #{tableize(self.name, opts)} WHERE #{self.primary_key} = #{id};")
      model = self.new
      # TODO take into account fully qualified tables
      fields = [].tap do |a|
        res.fetch_fields.each do |field|
          a << field.name
        end
      end
      res.each_hash do |row|
        fields.each do |field|
          model.__send__("#{field}=".intern, row[field])
        end
      end
    else
    end
    model
  end

end

