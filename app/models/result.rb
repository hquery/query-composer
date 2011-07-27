class Result
  include Mongoid::Document

  QUEUED = 'Queued'
  FAILED = 'Failed'
  COMPLETE = 'Complete'
  CANCELED = 'Canceled'

  embedded_in :execution, class_name: "Execution", inverse_of: :results

  belongs_to :endpoint

  field :status, type: String
  field :result_url, type: String
  field :next_poll, type: Integer
  field :value, type: Hash
  field :time, type: String
  field :error_msg, type: String

  def cancel
    if self.status.nil? || self.status == Result::QUEUED
      self.status = Result::CANCELED
      save!
    end
  end

end