class CodeList

  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :name, :type=> String
  field :type, :type => String
  field :description, :type=> String
  has_many :code_sets

  
end