class AddMaritalStatusCodes < Mongoid::Migration

  def self.up
    `mongoimport -d #{Mongoid.master.name} -h #{Mongoid.master.connection.host_to_try[0]}  -c code_sets test/fixtures/marital_status_codes.json`
  end
  
  def self.down
    collection('code_sets').remove({"type" => "marital_status"})
  end

end