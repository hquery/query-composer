require 'result_presenter'

class Query < BaseQuery
  include Mongoid::Document

  embeds_many :executions, class_name: 'Execution', inverse_of: :query

  belongs_to :user
  
  before_save :generate_map_reduce # noop unless generated?
  
  def last_execution
    executions.desc(:time).first
  end

  def execute(endpoints, should_notify = false)
    # add an execution to the query with the current run time and if the user wants to be notified by email on completion
    execution = Execution.new(time: Time.now.to_i, notification: should_notify)
    self.executions << execution
    self.save!

    execution.execute(endpoints)
  end
  
  def generate_map_reduce
    if (self.generated?)
      map_function = ""
      map_template = ActionView::Base.new(QueryComposer::Application.paths['app/views'])
      map_template = map_template.render(:template => "queries/builder/_map_function.js.erb", locals: { :query_structure => self.query_structure })
      self.map = prettify_generated_function(map_template)
    
      reduce_function = ""
      reduce_template = ActionView::Base.new(QueryComposer::Application.paths['app/views'])
      reduce_template = reduce_template.render(:template => "queries/builder/_reduce_function.js.erb", locals: { :query_structure => self.query_structure })
      self.reduce = prettify_generated_function(reduce_template)
    end
  end

  def clone
    Query.new(self.attributes.except('_id'));
  end
  
  def init_query_structure!
    self.query_structure = {"find"=>{"and"=>[{"or"=>[]}]}, "filter"=>{"and"=>[{"or"=>[]}]}, "extract"=>{"selections"=>[], "groups"=>[]}}
  end
  
  def result_presenter
    ResultPresenter.new(title, last_execution.try(:aggregate_result))
  end
  
  private
  
  # Note: This is not generic to all code; it assumes that all closing blocks are on their own line like we do within our generated code
  # TODO (agoldstein):  We should write comments in generated MapReduce code so a user can understand it, but strip it out when sending out to the gateway
  def prettify_generated_function function
    pretty_function = ""
    tab_count = 0
    function.each_line do |line|
      if (line =~ /^[\t   ]*function /) # Skip a line to make it easier to spot new functions
        pretty_function << "\n"
      end
      if !(line =~ /^[\t   ]*\n/) # Only include lines that consist of more than just tabs and spaces
        line = line.gsub("  ", '') # Erase all existing leading tabs
        if (line =~ /^[\t   ]*[\}\]\)]+.*[\{\[\(]+\n*/) # Indent less to print since we're closing a block, but leave tab_count the same since we're also opening one
          (tab_count-1).times { pretty_function << "  " }
        elsif (line =~ /[\{\[\(]\n*$/) # Indent further if we're opening some kind of block
          tab_count.times { pretty_function << "  " }
          tab_count += 1 
        elsif (line =~ /^[\t   ]*[\}\]\)]+;*\n*/) # Indent less if we're closing some kind of block
          tab_count -= 1 
          tab_count.times { pretty_function << "  " }
        else
          tab_count.times { pretty_function << "  " }
        end
        pretty_function << line
      end
    end
    
    return pretty_function
  end
  
end