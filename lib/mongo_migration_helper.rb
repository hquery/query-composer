class MongoMigrationHelper
  def self.set_field_default(model, column, default)
    model.all.each {|document| document.update_attribute(column, default) }
  end
end
