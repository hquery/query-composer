@queryStructure ||= {}

class queryStructure.VitalSignRule extends queryStructure.Rule
  constructor: (data) ->
    super("VitalSignRule", data)
  
  test:  (p) ->
    codes = p.vitalSigns().match(this.data.code.codes)
    return codes.length != 0
  
  
class queryStructure.EncounterRule extends queryStructure.Rule
  constructor: (data) ->
    super("EncounterRule", data)
    
  test: (p)  ->
    codes = p.encounters().match(this.data.code.codes)
    return codes.length != 0  