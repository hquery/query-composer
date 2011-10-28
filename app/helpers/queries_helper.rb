module QueriesHelper
  def jsonify(value)
    if value.class == Hash || value.class == Array || value.class == BSON::OrderedHash
      JSON.pretty_generate(value)
    else
      value
    end
  end
end
