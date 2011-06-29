
this.hQuery ||= {}
###*
Converts a a number in UTS Seconds since the epoch to a date.
@param {number} utcSeconds seconds since the epoch in UTC
@returns {Date}
###
hQuery.dateFromUtcSeconds = (utcSeconds) ->
  new Date utcSeconds * 1000

###*
@class A code with its corresponding code system
###
class hQuery.CodedValue
  ###*
  @param {String} c value of the code
  @param {String} csn name of the code system that the code belongs to
  @constructs
  ###
  constructor: (@c, @csn) ->

  ###*
  @returns {String} the code
  ###
  code: -> @c

  ###*
  @returns {String} the code system name
  ###
  codeSystemName: -> @csn



###*
@class an Address for a person or organization 
###
class hQuery.Address
  constructor: (@json) ->
  ###*
  @returns {String} the street address
  ###   
  streetAddress: -> @json['streetAddress']
  ###*
  @returns {String} the city
  ###
  city: -> @json['city']
  ###*
  @returns {String} the State or province
  ###
  stateOrProvince: -> @json['stateOrProvince']
  ###*
  @returns {String} the zip code
  ###
  zip: -> @json['zip']
  ###*
  @returns {String} the country
  ###
  country: -> @json['country']


###*
@class an object that describes a means to contact an entity.  This is used to represent 
phone numbers, email addresses,  instant messaging accounts ....  
###
class hQuery.Telecom
  constructor: (@json) ->
  ###*
  @returns {String} the type of telecom entry, phone, sms, email ....
  ###  
  type: -> @json['type']
  ###*
  @returns {String} the value of the entry -  the actual phone number , email address , ....
  ###  
  value: -> @json['value']
  ###*
  @returns {String} the use of the entry. Is it a home, office, .... type of contact
  ###  
  use: -> @json['use']
  ###*
  @returns {Boolean} is this a preferred form of contact
  ###  
  preferred: -> @json['preferred']


###*
@class an object that describes a person.  includes a persons name, addresses, and contact information
###
class hQuery.Person
  constructor: (@json) ->
  ###*
   @returns {String} the given name of the person
  ###  
  given: -> @json['given']
  ###*
   @returns {String} the last/family name of the person
   ###
  last: -> @json['last']
  ###*
   @returns {Array} an array of {@link Address} objects associated with the person
   ###
  addresses: ->
    for address in @json['addresses']
      new hQuery.Address address
  ###*
  @returns {Array} an array of {@link Telecom} objects associated with the person
  ###
  telecoms: ->
    for tel in @json['telecoms']
      new hQuery.Telecom tel


###*
@class an actor is either a person or an organization
###
class hQuery.Actor
  constructor: (@json) ->
  person: ->
    if @json['person'] 
      new hQuery.Person @json['person']
  organization: ->
    if @json['organization']
      new hQuery.Organization @json['organization']
      

###*
@class an organization
###
class hQuery.Organization
  constructor: (@json) ->



class hQuery.DateRange
  constructor: (@json) ->
  hi: -> 
    if @json['hi'] 
      dateFromUtcSeconds @json['hi'] 
  low: ->   dateFromUtcSeconds @json['low'] 
    
class hQuery.Informant
  constructor: (@json) ->
  contacts: ->
    for contact in @json['contacts'] 
      new hQuery.Person contact
  organization: -> new hQuery.Organization @json['organization']    
    
###*
@class
###
class hQuery.CodedEntry
  ###*
  @param {Object} A hash representing the coded entry
  @constructor
  ###
  constructor: (@json) ->

  ###*
  Date and time at which the coded entry took place
  @returns {Date}
  ###
  date: -> dateFromUtcSeconds: @json['time']

  ###*
  An Array of CodedValues which describe what kind of coded entry took place
  @returns {Array}
  ###
  type: -> createCodedValues @json['codes']

  ###*
  A free text description of the type of coded entry
  @returns {String}
  ###
  freeTextType: -> @json['description']
  
  ###*
  Unique identifier for this coded entry
  @returns {String}
  ###
  id: -> @json['id']

###*
@private
###
hQuery.createCodedValues = (jsonCodes) ->
  codedValues = []
  for codeSystem, codes of jsonCodes
    for code in codes
      codedValues.push new hQuery.CodedValue code, codeSystem
  codedValues


