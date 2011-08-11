class AddTypeToQuery < Mongoid::Migration

  def self.up
    BaseQuery.all.each {|query| query.update_attribute(:_type, 'Query') }
  end
  
  def self.down
    collection('queries').update({'_type' => 'Query'}, { '$unset' => { '_type' => 'Query' } }, {multi: true})
  end
end