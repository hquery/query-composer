class TemplateQuery<BaseQuery
  include Mongoid::Document
  
    def to_query
    Query.new(self.attributes.except('_id'));
  end

end
