class Query
  include Mongoid::Document
  
  embeds_many :executions, class_name: 'Execution', inverse_of: :query
  
  belongs_to :user
  has_many :events
  has_and_belongs_to_many :endpoints
  
  field :title, type: String
  field :description, type: String
  field :filter, type: String
  field :map, type: String
  field :reduce, type: String
  
  def last_execution
    executions.desc(:time).first
  end
  
  def execute(should_notify = false)
    # add an execution to the query with the current run time and if the user wants to be notified by email on completion
    execution = Execution.new(time: Time.now.to_i, notification: should_notify)
    self.executions << execution
    self.save!
    
    execution.execute()
  end
  
end