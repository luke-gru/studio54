class LazyRecord
  attr_accessor :id
  include ::Studio54
  RecordNotFound = Class.new(::StandardError)

  def self.inherited(base)
    base.__send__(:include, ::Studio54)
  end

  def self.find(id, options={})
    if options.empty?
      res = Db.query("SELECT * FROM #{self.name.downcase + 's'} WHERE id = #{id};")
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

