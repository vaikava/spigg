events = require("events")

class SpiggEntity

  constructor: (d, noDefaults)->
    # Create default values
    @data =      {}
    @defaults =  {}
    @fields =    {}
    @setters =   {}
    @revisions = []
    @default_val = null
    @events = new events.EventEmitter()
    @events.on "change", @_handleChange
    
    # Call init method if defined, set defaults & data
    @init() if typeof @init is 'function'
    
    @data = @_merge @defaults, {} if @defaults and !noDefaults
    #@_setObject(d) if d
    @set d if d
  
  # Returns a property from the entity
  get: (k) ->
    return @data unless k
    return @_getDotNotated(k) if ~k.indexOf "."
    @data[k] ? @default_val

  # Sets a property in the entity either by key/value
  # or from a full object by calling the setter accordingly
  set: (k, v) ->
    # Check if we have key/value args. Merge them into an object if thats the case
    if arguments.length is 2
      o = {}
      o[k] = v
      k = o
    
    # Set the data by :
    # 1: Running it through eventual defined setters
    # 1: Filtering it for valid fields
    # 2: Overwrite current data
    @data = @_merge(@_filter(@_set(k, @setters), @fields), @data)
    
    # Invoke the change event to create revisions
    @events.emit "change", @
    
  # Sets the default value to be returned for missing properties
  # when using the get()-method
  setDefaultValue: (v) ->
    @default_val = v
    
  # Resets the entity back to defaults
  reset: ->
    @data = @_merge @defaults, {}
  
  # Empties the entity completely, including defaults
  clear: ->
    @data = {}

  # Drops a property from the entity
  unset: (k) ->
    delete @data[k]
    @
  
  # Returns a given revision of the entity by id
  getRevision: (n) ->
    
    # Return all revisions if n isnt set
    return @revisions if typeof n is "undefined"
    
    # Returns historic revisions when given negative number
    return @revisions[@revisions.length + n + -1] if n < 0
    
    # Returns revision by number (first rev is always 0)
    return @revisions[n] ? {}
  
  # Returns how many current revisions exists in the entity
  revisions: ->
    return @revisions.length
      
  # Returns a property from @data by dot notation
  _getDotNotated: (k) ->
    walker = (o, i) -> o[i]
    k.split(".").reduce walker, @data
    
  # Runs a object against a similarily mapped object containing
  # setters on a per-property basis.
  _set: (data, setters, val) ->
    return setters(val, @data) if val and typeof setters is 'function'
    o = {}
    
    for key of data
      if setters[key]
        o[key] = @_set(data[key], setters[key], data[key])
      else
        o[key] = data[key]
    o
  
  # Filters a passed object against another object
  # containing allowed fields
  _filter: (obj, fields) ->
    obj ?=    @data
    fields ?= @fields
    o =       {}
    
    return obj if Object.prototype.toString.call(obj) isnt "[object Object]"
    
    for key of obj
      o[key] = @_filter(obj[key], fields[key]) if fields[key]
    
    return o

  # Do a shallow copy of the first obj, overwritting the properties
  # in the second
  _merge: (a, b) ->
    for k, v of a
      b[k] = v
    b
    
  # Creates revisions when being invoked automatically by the
  # eventemitter
  _handleChange: (context) ->
    context.revisions.push context._merge(context.data, {})

class SpiggMapper

  # Checks whether or not the passed argument is
  # a spiggEntity or not
  isEntity: (v) ->
    v instanceof SpiggEntity

  # Checks if a passed argument is a entity and if so,
  # returns the data it contains
  hasData: (v) ->
    return v.data if @isEntity(v)
  
module.exports.Entity = SpiggEntity
module.exports.Mapper = SpiggMapper