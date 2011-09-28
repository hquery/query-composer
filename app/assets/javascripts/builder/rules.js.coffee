@queryStructure ||= {}

class queryStructure.VitalSignRule extends queryStructure.Rule
  constructor: (data) ->
    super("VitalSignRule", data)
  
  test:  (p) ->
    if this.data.code == null
      return true
    codes = p.vitalSigns().match(this.data.code.codes)
    return codes.length != 0
  
  
class queryStructure.EncounterRule extends queryStructure.Rule
  constructor: (data) ->
    super("EncounterRule", data)
    
  test: (p)  ->
    if this.data.code == null
      return true
    codes = p.encounters().match(this.data.code.codes)
    return codes.length != 0  
    

class queryStructure.DemographicRule extends queryStructure.Rule
  constructor: (data) ->
    super("DemographicRule", data)

  test: (p)  ->
    match = true
    if(this.data.ageRange)
      match = p.age() >=this.data.ageRange.low &&  p.age() <= this.data.ageRange.high 
      print("matched age? " + match)
    if this.data.maritalStatusCode && match 
       match = p.maritalStatus().includesCodeFrom(this.data.maritalStatusCode.codes)
       print("matched msc? " + match)
    if this.data.gender && match
      match = p.gender() == this.data.gender
      print("matched gender? " + match)
   
    if this.data.raceCode && match
      match = p.race().includesCodeFrom(this.data.raceCode.codes)
      print("matched race? " + match)
    
    return match  