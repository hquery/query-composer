require 'factory_girl'

# ==========
# = USERS =
# ==========
Factory.define :user do |u| 
  u.sequence(:email) { |n| "testuser#{n}@test.com"} 
  u.password 'password' 
  u.password_confirmation 'password'
  u.first_name 'first'
  u.last_name 'last'
  u.sequence(:username) { |n| "testuser#{n}"}
  u.admin false
  u.approved true
end

Factory.define :admin, :parent => :user do |u|
  u.admin true
end

Factory.define :unapproved_user, :parent => :user do |u|
  u.approved false
end

Factory.define :user_with_queries, :parent => :user do |user|
  user.after_create { |u| Factory(:query_with_endpoints, :user => u) }
  user.after_create { |u| Factory(:query_with_endpoints, :user => u) }
  user.after_create { |u| Factory(:query_with_endpoints, :user => u) }
  user.after_create { |u| Factory(:query_with_execution, :user => u) }
  user.after_create { |u| Factory(:query_with_completed_results, :user => u) }
end

Factory.define :user_with_library_functions, :parent => :user do |user|
  user.after_create {|u| Factory(:library_function, :user => u)}
end

Factory.define :user_with_queries_and_library_functions, :parent => :user_with_queries do |user|
  user.after_create {|u| Factory(:library_function, :user => u)}
end

# ===========
# = QUERIES =
# ===========

Factory.define :query do |q|
  q.sequence(:title) { |n| "title #{n}" }
  q.description "description"
  q.filter ""
  q.map "function(patient) {\r\n  emit(null, {\"count\":1});\r\n}"
  q.reduce "function(patient) {\r\n  emit(null, {\"count\":1});\r\n}"
end

Factory.define :query_with_endpoints, :parent => :query do |query|
  query.after_create do |q|
    q.endpoints << Factory(:endpoint)
    q.endpoints << Factory(:endpoint)
  end
end

Factory.define :query_with_execution, :parent => :query_with_endpoints do |query|
  query.executions { 
    [] << Factory.build(:execution)
  }
  query.after_create do |q| 
    q.executions.each {|execution| execution.results = q.endpoints.collect{|endpoint| Factory.build(:result, :endpoint => endpoint)} }
  end
end

Factory.define :query_with_completed_results, :parent => :query_with_endpoints do |query|
  query.reduce "function(key, values) {\r\n  var result = 0; \r\n values.forEach(function(value) {\r\nresult += value;\r\n});\r\nreturn result; \r\n}"
  
  query.executions { 
    [] << Factory.build(:execution)
  }
  query.after_create do |q| 
    q.executions.each {|execution| execution.results = q.endpoints.collect{|endpoint| Factory.build(:result_with_value, :endpoint => endpoint)} }
  end
end


# =============
# = Endpoints =
# =============
Factory.define :endpoint do |e| 
  e.sequence(:name) {|n| "Endpoint#{n}"}
  e.base_url 'http://127.0.0.1:3001' 
end

# ==============
# = Executions =
# ==============

Factory.define :execution do |e|
  e.time Time.now.to_i
end

# ===========
# = Results =
# ===========

Factory.define :result do |r|
  r.next_poll nil
  r.value nil
  r.result_url nil
  r.status nil
end

Factory.define :result_with_value, :parent => :result do |result| 
  result.value ({"M" => 50, "F" => 30})
  result.status 'Complete'
end

# =====================
# = Library Functions =
# =====================

Factory.define :library_function do |f|
  f.sequence(:name) { |n| "sum#{n}()" }
  f.definition "username.sum = function(values) {\r\n        result = 0;\r\n          values.forEach(function(value) {\r\n            result += value;\r\n          });\r\n          return result;\r\n        }\r\n"
end