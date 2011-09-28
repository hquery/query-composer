class AddTypeToQuery < Mongoid::Migration

  def self.up
    BaseQuery.all.each {|query| query.update_attribute(:_type, 'Query') }
  end
  
  def self.down
    collection('queries').update({}, { '$unset' => { '_type' => 1 } }, {multi: true})
  end
end