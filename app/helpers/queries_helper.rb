module QueriesHelper
  def jsonify(value)
    if value.class==Hash || value.class==Array
      JSON.pretty_generate(value)
    else
      value
    end
  end
end
