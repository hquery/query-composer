module QueriesHelper
  def jsonify(value)
    begin
      if value.class == Hash || value.class == Array || value.class == Moped::BSON::OrderedHash
        JSON.pretty_generate(value)
      else
        value
      end
    rescue
    return value
  end
  end
end
