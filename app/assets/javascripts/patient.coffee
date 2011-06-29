# =require core.coffee
# =require medication.coffee
this.hQuery ||= {}
# =require condition.coffee
# =require encounter.coffee
# =require procedure.coffee
# =require result.coffee
###*
@class Representation of a patient
###
class hQuery.Patient
  ###*
  @constructs
  ###
  constructor: (@json) ->

  ###*
  @returns {String} containing M or F representing the gender of the patient
  ###
  gender: -> @json['gender']

  ###*
  @returns {String} containing the patient's given name
  ###
  given: -> @json['first']
  family: -> @json['last']

  ###*
  @returns {Date} containing the patient's birthdate
  ###
  birthtime: ->
    hQuery.dateFromUtcSeconds @json['birthdate']

  ###*
  @returns {Array} A list of {@link Encounter} objects
  ###
  encounters: ->
    for encounter in @json['encounters']
      new hQuery.Encounter encounter
    
  ###*
  @returns {Array} A list of {@link Medication} objects
  ###
  medications: ->
    for medication in @json['medications']
      new hQuery.Medication medication
      
      
  ###*
  @returns {Array} A list of {@link Condition} objects
  ###
  conditions: ->
    for condition in @json['conditions']
      new hQuery.Condition condition

  ###*
  @returns {Array} A list of {@link Procedure} objects
  ###
  procedures: ->
    for procedure in @json['procedures']
      new hQuery.Procedure procedure
      
  ###*
  @returns {Array} A list of {@link Result} objects
  ###
  results: ->
    for result in @json['results']
      new hQuery.Result result

  ###*
  @returns {Array} A list of {@link Result} objects
  ###
  vitalSigns: ->
    for vital in @json['vital_signs']
      new hQuery.Result vital
      
