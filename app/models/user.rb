class User
  include Mongoid::Document
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :authentication_keys => [:username]

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  # attr_accessible :title, :body

  has_many :queries
  has_many :library_functions

  field :first_name, type: String
  field :last_name, type: String
  field :username, type: String
  field :email, type: String
  field :company, type: String
  field :company_url, type: String
  field :encrypted_password, :type => String, :default => ""

  field :agree_license, type: Boolean

  field :effective_date, type: Integer

  field :admin, type: Boolean
  field :approved, type: Boolean
  field :disabled, type: Boolean

  validates_presence_of :first_name, :last_name
  validates_uniqueness_of :username
  validates_uniqueness_of :email

  validates_acceptance_of :agree_license, :accept => true

  validates :email, presence: true, length: {minimum: 3, maximum: 254}, format: {with: /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i}
  validates :username, :presence => true, length: {minimum: 3, maximum: 254}
  validates_presence_of :encrypted_password

  def active_for_authentication? 
    super && approved? && !disabled?
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
  
  def save_library_functions_locally
    
    # update gateway
    # add alias stuff to map function
    
    db = Mongoid::Config.master
    composer_id = COMPOSER_ID
    # need to add this if it is not there
    hquery = db['system.js'].find({_id: 'hquery_user_functions'});
    if (hquery.count == 1) 
      user_namespace = ''
      if (hquery.first['value']['f'+composer_id.to_s].nil?) 
        user_namespace += "hquery_user_functions['f#{composer_id}'] = {}; "
      end
    else
      user_namespace = "hquery_user_functions = {}; hquery_user_functions['f#{composer_id}'] = {}; "
    end
    user_namespace = user_namespace + "f#{id.to_s} = new function(){#{library_function_definitions}}; "
    user_namespace = user_namespace + "hquery_user_functions['f#{composer_id}']['f#{id.to_s}'] = f#{id.to_s}; "
    db.eval(user_namespace)


    db.eval("db.system.js.save({_id:'hquery_user_functions', value : hquery_user_functions })")
  end
end
