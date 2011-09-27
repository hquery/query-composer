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
  
  def set_properties(h)
   puts h
   self.name = h['name'] || name
   self.type = h['type'] || type
   self.description = h['description'] || description
   _codes = h['codes']
  
   if _codes.kind_of? Array
     c = {}
   
     _codes.each do |code|
       n = code['code_system'].strip
       a = code['codes'].split(",").collect{|x| x.strip }
       puts n, a
       unless n.empty? 
         c[n] = a
       end
     end 
     _codes = c   
   end 
   self.codes =  _codes || codes
   save
  end
  
end
