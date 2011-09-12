class CodeSet
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :name, :type=> String
  field :type, :type = > String
  field :description, :type=> String

  
  
  
  def add_code(code_system , code)
    cs = get_code_system(code_system)
    unless cs.index(code) do
      cs << code
    end
  end
  
  def remove_code(code_system, code)
    cs = get_code_system(code_system)
    cs.reject!{|item| item == code}
  end
  
  
  def remove_code_system(code_system)
    codes.reject!{|key,val| key == code_system}
  end
  
  def get_code_system(code_system)
    codes[code_system] ||= []
  end
  
  def from_json(json)
   hash = JSON.parse(json)
   name = hash['name'] || name
   type = hash['type'] || type
   description = hash['description'] || description
   codes = hash['codes'] || codes
  end
end
