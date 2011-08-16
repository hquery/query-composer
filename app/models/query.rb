class Query < BaseQuery
  include Mongoid::Document

  embeds_many :executions, class_name: 'Execution', inverse_of: :query

  belongs_to :user
  has_many :events
  has_and_belongs_to_many :endpoints
  
  before_update :create_map_reduce_if_generated
  before_save :create_map_reduce_if_generated
  
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
  
  private
  
  def create_map_reduce_if_generated
    map = ActionView::Base.new(QueryComposer::Application.paths['app/views'])
    map.render(:template => "queries/builder/_map_function.js.erb", locals: { :query_structure => self.query_structure })
    
    reduce = ActionView::Base.new(QueryComposer::Application.paths['app/views'])
    reduce.render(:template => "queries/builder/_reduce_function.js.erb", locals: { :query_structure => self.query_structure })
  end

end