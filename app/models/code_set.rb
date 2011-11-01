class CodeSet
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :name, :type=> String
  field :type, :type => String
  field :description, :type=> String
  field :codes, :type=> Hash
  
  
  
  def add_code(code_system , code)
    cs = get_code_system(code_system)
    unless cs.index(code)
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
  
  def set_properties(saved_code_set)
    self.name = saved_code_set['name'] || self.name
    self.type = saved_code_set['type'] || self.type
    self.description = saved_code_set['description'] || self.description
    
    saved_codes = saved_code_set['codes']
  
    if saved_codes.kind_of? Array
      updated_codes = {}
      
      saved_codes.each do |item|
        code_system = item['code_system'].strip
        code = item['codes'].split(",").collect{ |x| x.strip }

        updated_codes[code_system] ||= []
        updated_codes[code_system] += code
      end
      
      saved_codes = updated_codes
    end 
    
    self.codes = saved_codes || self.codes
    self.save!
  end
  
end
