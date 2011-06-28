require 'factory_girl'

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

Factory.define :endpoint do |e| 
  e.sequence(:name) {|n| "Endpoint#{n}"}
  e.next_poll nil
  e.result ({"null" => {"count" => 10}})
  e.result_url nil
  e.status 'Complete'
  e.submit_url 'http://127.0.0.1:3001/queues' 
end

Factory.define :query do |q|
  q.sequence(:title) { |n| "title #{n}" }
  q.description "description"
  q.filter ""
  q.map "function(patient) {\r\n  emit(null, {\"count\":1});\r\n}"
  q.reduce "function(patient) {\r\n  emit(null, {\"count\":1});\r\n}"
end

Factory.define :user_with_queries, :parent => :user do |user|
  user.after_create { |u| Factory(:query_with_endpoints, :user => u) }
  user.after_create { |u| Factory(:query_with_endpoints, :user => u) }
  user.after_create { |u| Factory(:query_with_endpoints, :user => u) }
end

Factory.define :query_with_endpoints, :parent => :query do |query|
  query.after_create do |q|
    q.endpoints << Factory(:endpoint)
    q.endpoints << Factory(:endpoint)
  end
end

Factory.define :query_with_result, :parent => :query do |query|
  query.after_create do |q|
    q.endpoints << Factory(:endpoint, result: ({"foo" => "bar"}), result_url: 'http://127.0.0.1:3001/queues')
  end
end