@field_mappings ||= {}

@field_mappings extends "patient.age": (p) ->
    p.age
    
  getCodes: (arr) ->
    for x in arr
      x.type
      
  "patient.medications": (p) ->
     p.medications
     
  "patient.gender": (p) ->
    p.gender()

  "patient.conditions": (p) ->
    p.conditions()

  "patient.immunizations": (p) ->
    p.immunizations()

  "patient.allergies": (p) ->
    p.allergies()

  "patient.vital_signs": (p) ->
    p.vitalSigns()
    
  "patient.results": (p) ->
    p.results()
    
  "pateint.procedures": (p) ->
    p.procedures()
    
  "patient.encounters" : (p) ->
    p.encounters()

  "patient.medication_codes": (p) ->
    @field_mappings.getCodes(p.medications())

  "patient.condition_codes": (p) ->
    @field_mappings.getCodes(p.conditions())

  "patient.immunization_codes": (p) ->
    @field_mappings.getCodes(p.immunizations())

  "patient.allergy_codes": (p) ->
    @field_mappings.getCodes(p.allergies())

  "patient.vital_sign_codes": (p) ->
    @field_mappings.getCodes(p.vitalSigns())

  "patient.result_codes": (p) ->
    @field_mappings.getCodes(p.results())

  "pateint.procedure_codes": (p) ->
    @field_mappings.getCodes(p.procedures())

  "patient.encounter_codes" : (p) ->
    @field_mappings.getCodes(p.encounters()) 