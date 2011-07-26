class Endpoint
  include Mongoid::Document
  
  SUBMIT_PATH = 'queues'
  FUNCTIONS_PATH = 'library_functions'

  has_and_belongs_to_many :queries
  
  validates_presence_of :name, :base_url
  
  field :name, type: String
  field :base_url, type: String
  
  def submit_url
    concat_url_parts(base_url, SUBMIT_PATH)
  end
  def functions_url
    concat_url_parts(base_url, FUNCTIONS_PATH)
  end
  
  private
  
  def concat_url_parts(left, right) 
    left + (left.ends_with?('/') ? '' : '/') + right
  end
  
end