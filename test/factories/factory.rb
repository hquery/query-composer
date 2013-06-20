require 'factory_girl'

# ==========
# = USERS =
# ==========
FactoryGirl.define do
  factory :user do |u|
    u.sequence(:email) { |n| "testuser#{n}@test.com"}
    u.password 'password'
    u.password_confirmation 'password'
    u.first_name 'first'
    u.last_name 'last'
    u.sequence(:username) { |n| "testuser#{n}"}
    u.admin false
    u.approved true
  end
end

FactoryGirl.define do
  factory :admin, :parent => :user do |u|
    u.admin true
  end
end

FactoryGirl.define do
  factory :unapproved_user, :parent => :user do |u|
    u.approved false
  end
end

FactoryGirl.define do
  factory :user_with_queries, :parent => :user do |user|
    user.after_create { |u| FactoryGirl(:query, :user => u) }
    user.after_create { |u| FactoryGirl(:query, :user => u) }
    user.after_create { |u| FactoryGirl(:query, :user => u) }
    user.after_create { |u| FactoryGirl(:query_with_queued_results, :user => u) }
    user.after_create { |u| FactoryGirl(:query_with_completed_results, :user => u) }
    user.after_create { |u| FactoryGirl(:generated_query_with_completed_results, :user => u) }
  end
end

FactoryGirl.define do
  factory :user_with_library_functions, :parent => :user do |user|
    user.after_create {|u| FactoryGirl(:library_function, :user => u)}
  end
end

FactoryGirl.define do
  factory :user_with_queries_and_library_functions, :parent => :user_with_queries do |user|
    user.after_create {|u| FactoryGirl(:library_function, :user => u)}
  end
end

# ===========
# = QUERIES =
# ===========

FactoryGirl.define do
  factory :template_query do |q|
    q.sequence(:title) { |n| "title #{n}" }
    q.description "description"
    q.filter ""
    q.map "function(patient) {\r\n  emit(null, {\"count\":1});\r\n}"
    q.reduce "function(patient) {\r\n  emit(null, {\"count\":1});\r\n}"
  end
end

FactoryGirl.define do
  factory :query do |q|
    q.sequence(:title) { |n| "title #{n}" }
    q.description "description"
    q.filter ""
    q.map "function map(patient) {\r\n  emit(null, {\"count\":1});\r\n}"
    q.reduce "function reduce(patient) {\r\n  emit(null, {\"count\":1});\r\n}"
    q.user FactoryGirl.build(:user)
  end
end

FactoryGirl.define do
  factory :generated_query, :parent => :query do |q|
    q.query_structure ({
      "find" =>
        { "and" => [
          { "name" => "demographics",
            "and" => [
              { "category" => "demographics", "title" => "age", "field" => "age", "value" => "18", "comparator" => ">" } ] } ] },
      "filter" =>
        { "and" => [
          { "name" => "demographics",
            "and" => [
              { "category" => "demographics", "title" => "age", "field" => "age", "value" => "65", "comparator" => "<" } ] } ] },
      "extract" =>
        { "selections" => [
            { "title" => "age", "callstack" => "age", "aggregation" => [ "sum" ] } ],
          "groups" => [ { "title" => "gender", "callstack" => "gender" } ] }
    })
    q.generated true
    q.user FactoryGirl.build(:user)
  end
end

FactoryGirl.define do
  factory :query_with_queued_results, :parent => :query do |query|
    query.reduce "function reduce(key, values) {\r\n  var result = 0; \r\n while(values.hasNext()){ result += values.next(); }\r\nreturn result; \r\n}"
  
    query.executions {
      [] << FactoryGirl.build(:queued_execution)
    }
  end
end

FactoryGirl.define do
  factory :query_with_completed_results, :parent => :query do |query|
    query.reduce "function reduce(key, values) {\r\n  var result = 0; \r\n while(values.hasNext()){ result += values.next(); }\r\nreturn result; \r\n}"
  
    query.executions {
      [] << FactoryGirl.build(:completed_execution)
    }
  end
end

FactoryGirl.define do
  factory :generated_query_with_completed_results, :parent => :generated_query do |query|
    query.executions {
      [] << FactoryGirl.build(:completed_execution_for_generated_query)
    }
  end
end

FactoryGirl.define do
  factory :generated_query_with_odd_result_count, :parent => :generated_query do |query|
    query.executions {
      [] << FactoryGirl.build(:execution_with_generated_odd_result_count)
    }
  end
end

FactoryGirl.define do
  factory :generated_query_with_single_result, :parent => :generated_query do |query|
    query.executions {
      [] << FactoryGirl.build(:execution_with_generated_single_result)
    }
  end
end

FactoryGirl.define do
  factory :generated_query_with_no_results, :parent => :generated_query do |query|
    query.executions {
      [] << FactoryGirl.build(:execution)
    }
  end
end

# =============
# = Endpoints =
# =============
FactoryGirl.define do
  factory :endpoint do |e|
    e.sequence(:name) {|n| "Endpoint#{n}"}
    e.base_url 'http://127.0.0.1:3001'
  end
end

# ==============
# = Executions =
# ==============

FactoryGirl.define do
  factory :execution do |e|
    e.time Time.now.to_i
  end
end

FactoryGirl.define do
  factory :queued_execution, :parent => :execution do |e|
    e.after_build do |ex|
      FactoryGirl.create(:result_waiting, :endpoint => FactoryGirl(:endpoint), :execution => ex)
    end
  end
end

FactoryGirl.define do
  factory :completed_execution, :parent => :execution do |e|
    e.after_build do |ex|
      FactoryGirl.create(:result_with_value, :endpoint => FactoryGirl(:endpoint), :execution => ex)
      FactoryGirl.create(:result_with_value, :endpoint => FactoryGirl(:endpoint), :execution => ex)
    end
  end
end

FactoryGirl.define do
  factory :completed_execution_for_generated_query, :parent => :execution do |e|
    e.after_build do |ex|
      FactoryGirl.create(:result_with_value_from_generated_query, :endpoint => FactoryGirl(:endpoint), :execution => ex)
      FactoryGirl.create(:result_with_value_from_generated_query, :endpoint => FactoryGirl(:endpoint), :execution => ex)
      FactoryGirl.create(:result_with_value_from_generated_query, :endpoint => FactoryGirl(:endpoint), :execution => ex)
      FactoryGirl.create(:result_with_value_from_generated_query, :endpoint => FactoryGirl(:endpoint), :execution => ex)
    end
  end
end

FactoryGirl.define do
  factory :execution_with_generated_odd_result_count, :parent => :execution do |e|
    e.after_build do |ex|
      FactoryGirl.create(:result_with_value_from_generated_query, :endpoint => FactoryGirl(:endpoint), :execution => ex)
      FactoryGirl.create(:result_with_value_from_generated_query, :endpoint => FactoryGirl(:endpoint), :execution => ex)
      FactoryGirl.create(:result_with_value_from_generated_query, :endpoint => FactoryGirl(:endpoint), :execution => ex)
    end
  end
end

FactoryGirl.define do
  factory :execution_with_generated_single_result, :parent => :execution do |e|
    e.after_build do |ex|
      FactoryGirl.create(:result_with_value_from_generated_query, :endpoint => FactoryGirl(:endpoint), :execution => ex)
    end
  end
end

# ===========
# = Results =
# ===========

FactoryGirl.define do
  factory :result do |r|
    r.value nil
    r.result_url nil
    r.status nil
  end
end

FactoryGirl.define do
  factory :result_waiting, :parent => :result do |r|
    r.value nil
    r.result_url nil
    r.status Result::QUEUED
    r.query_url 'http://localhost:3000/queries/4e4c08b5431a5f5dc1000001'
    r.created_at Time.new(2011, 1, 1)
    r.updated_at Time.new(2011, 1, 1)
  end
end

FactoryGirl.define do
  factory :result_with_value, :parent => :result do |result|
    result.value ({"M" => 50, "F" => 30})
    result.status Result::COMPLETE
  end
end

FactoryGirl.define do
  factory :result_with_value_from_generated_query, :parent => :result_with_value do |result|
    result.value ({
      "type_group_gender_F" => {
        "values" => {
          "age" => 0,
         "age_sum" => 6000,
          "age_frequency" => {
            "18" => 65,
            "65" => 18
         },
          "age_mean" => 28.193,
          "age_mean_count" => 83,
          "median" => 18,
         "median_list" => [
            18, 18, 18, 18, 18, 18, 18, 18, 18, 18,
            18, 18, 18, 18, 18, 18, 18, 18, 18, 18,
            18, 18, 18, 18, 18, 18, 18, 18, 18, 18,
            18, 18, 18, 18, 18, 18, 18, 18, 18, 18,
            18, 18, 18, 18, 18, 18, 18, 18, 18, 18,
            18, 18, 18, 18, 18, 18, 18, 18, 18, 18,
            18, 18, 18, 18, 18,
            65, 65, 65, 65, 65, 65, 65, 65, 65, 65,
            65, 65, 65, 65, 65, 65, 65, 65
         ],
          "mode" => 18,
         "mode_frequency" => {
            "18" => 65,
           "65" => 18
          }
        },
        "rereduced" => true
      },
      "type_group_gender_M" => {
        "values" => {
          "age" => 0,
          "age_sum" => 4000
       },
        "rereduced" => true
      },
      "type_population" => {
        "values" => {
          "target_pop" => 0,
          "filtered_pop" => 0,
          "unfound_pop" => 0,
          "total_pop" => 0,
          "target_pop_sum" => 300,
          "filtered_pop_sum" => 400,
          "unfound_pop_sum" => 100,
          "total_pop_sum" => 500
        },
        "rereduced" => true
      }
    })
    end
end

# =====================
# = Library Functions =
# =====================

FactoryGirl.define do
  factory :library_function do |f|
    f.sequence(:name) { |n| "sum#{n}()" }
    f.definition "this.sum = function(values) {\r\n        result = 0;\r\n          values.forEach(function(value) {\r\n            result += value;\r\n          });\r\n          return result;\r\n        }\r\n"
  end
end


# ======================
# = Code sets          =
# ======================


FactoryGirl.define do
  factory :code_set do |cs|
    cs.name nil
    cs.type nil
    cs.description nil
    cs.codes nil
  end
end

FactoryGirl.define do
  factory :annulled_marital_status_code, :parent => :code_set do |cs|
    codes = {"MaritalStatusCodes" => ["A"]}
    cs.name "Annulled"
    cs.description ""
    cs.type "marital_status"
    cs.codes codes
  end
end
