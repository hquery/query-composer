class LibraryFunction
  include Mongoid::Document

  belongs_to :user
  
  validates_presence_of :name, :definition
  
  field :name, type: String
  field :definition, type: String

end
