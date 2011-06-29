this.hQuery ||= {}
# =require core.coffee
###*
@class Provider

  Describes a person/organization that has provided treatment for the given condition. 
  
  The dateRange element describes the last range that the actor provided treatment for the 
  condition.
  
  The provider is represented by the core:actor substitution group which equates to either a 
  person element or and organization element being present.
  
###
class hQuery.Provider
  constructor: (@json) ->
  effectiveDate: -> new DateRange @json['effectiveDate'] 
  actor: -> new Actor @json['actor'] 
  informant: -> new Informant @json['informant'] 
  narrative: -> @json['narrative']

###*
@class Condition

This section is used to describe a patients problems/conditions. The types of conditions described have been constrained to the SNOMED CT 
Problem Type code set.

The problemDate element is used to define the time during which the condition was last observed/active. 

The problemType element is used to describe the type of problem/condition.

An unbounded number of treating providers for the particular condition can be supplied.

Element names map to the hData CoC profile

narrative element referrs to narrative (human readable) style content. Usually a human readable version of the
encoded content.

###  
class hQuery.Condition
###*
@param {Object} A hash representing the Condition
@constructs
###
constructor: (@json) ->
  type: -> new hQuery.CodedValue @json['problemType'].codeSystem, @json['problemType'].code 
  name: -> @json['problemName']
  date: -> new hQuery.DateRange(@json['problemDate'])
  code: ->  new hQuery.CodedValue @json['problemCode'].codeSystem, @json['problemCode'].code 
  providers: ->    
    for  provider in @json['treatingProviders'] 
       new Provider provider 