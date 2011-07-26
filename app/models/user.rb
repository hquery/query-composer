class User
  include Mongoid::Document
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,:recoverable, :rememberable, :trackable, :validatable,:authentication_keys => [:username]

  has_many :queries
  has_many :library_functions

  field :first_name, type: String
  field :last_name, type: String
  field :username, type: String
  field :email, type: String
  field :company, type: String
  field :company_url, type: String

  field :agree_license, type: Boolean

  field :effective_date, type: Integer
  
  field :admin, type: Boolean
  field :approved, type: Boolean

  validates_presence_of :first_name, :last_name
  validates_uniqueness_of :username
  validates_uniqueness_of :email


  validates_acceptance_of :agree_license, :accept => true
  


  validates :email, presence: true, 
                    length: {minimum: 3, maximum: 254},
                    format: {with: /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i}
  validates :username, :presence => true, length: {minimum: 3, maximum: 254}

  def active_for_authentication? 
    super && approved?
  end
  
  # ==========
  # = FINDERS =
  # ==========
  
  def self.find_by_username(username)
    User.first(:conditions => {:username => username})
  end
  def self.find_by_email(email)
    User.first(:conditions => {:email => email})
  end
  
  # =============
  # = Modifiers =
  # =============
  
  def grant_admin
    update_attributes(:admin => true)
    update_attributes(:approved => true)
  end

  def approve
    update_attributes(:approved => true)
  end

  def revoke_admin
    update_attributes(:admin => false)
  end

  # =============
  # = utilities =
  # =============
  def library_function_definitions
    (library_functions.map {|function| function.definition}).join("\r\n")
  end
end
