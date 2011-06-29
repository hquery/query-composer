this.hQuery ||= {}
# =require core.coffee
###*
This represents all interventional, surgical, diagnostic, or therapeutic procedures or 
treatments pertinent to the patient.
@class
@augments CodedEntry
###
class hQuery.Procedure extends hQuery.CodedEntry
  
  ###*
  @returns {Person} The entity that performed the procedure
  ###
  performer: -> new hQuery.Actor @json['performer']