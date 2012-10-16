class spiggEntity
  constructor: (d, skipDefaults)->
    @data = {}
    @fields = @fields ? {}
    @default_val = @default_val ? null
    @init() if typeof @init is 'function'
    @_setDefaults() if @defaults and !skipDefaults
    @_setObject(d) if d
    
  get: (k) ->
    return @data unless k
    return @_getDotNotated(k) if ~k.indexOf "."
    @data[k] ? @default_val
    
  set: (k, v) ->
    return @_setObject(k) if typeof k is 'object'
    return @_setDotNotated(k, v) if ~k.indexOf "."
    
    @_set k, v

  setUnsafe: (k, v) ->
    @data[k] = v
    @    
  
  unset: (k) ->
    delete @data[k]
    @
    
  reset: ->
    @data = {}
    @_setDefaults()
    @
  
  clear: ->
    @data = {}
    @
    
  toJSON: -> 
    JSON.stringify @data
    
  toString: ->
    JSON.stringify @data
    
  toModifier: (fn) ->
    @data = fn @data
    @

  _setDefaults: ->
    @data[k] = v for k, v of @defaults
    @

  _set: (k, v) ->
    nv = @_callCustomSetter(k, v)
    if nv is false then return null else v = nv
    
    @data[k] = v
    
    @data = @_filter() # Call filter!
    
   _setObject: (o) ->
     @_set(k, v) for k, v of @_filter(o)
    
  _callCustomSetter: (k, v) ->
    method = '_set' + k.substr(0, 1).toUpperCase() + k.substr(1)
    v = @[method](v, @.data)  if typeof @[method] is 'function'
    v
  
  _getDotNotated: (k) ->
    walker = (o, i) -> o[i]
    k.split(".").reduce walker, @data

  _setDotNotated: (k, v) ->
    arr = k.split(".")
    _k = arr[arr.length - 1]
    
    nv = @_callCustomSetter(arr.join("_"), v)
    if nv is false then return null else v = nv
    
    walker = (o, i) ->
      o[i] = v if i is _k
      o[i]
  
    arr.reduce walker, @data
    @data = @_filter() # Call filter
    
  _filter: (obj, fields) ->
    obj ?=    @data
    fields ?= @fields
    o =       {}
    
    return obj if Object.prototype.toString.call(obj) isnt "[object Object]"
    
    for key of obj
      o[key] = @_filter(obj[key], fields[key]) if fields[key]
    
    return o  

  ###
  _setChanged: (context) ->
    context.revision++
    md5 = crypto.createHash('md5').update(JSON.stringify context.data).digest("hex")
    context.revisions[context.revision] = context.data
    context.changed = true
  ###

module.exports.Entity = spiggEntity

class spiggMapper
  isEntity: (v) ->
    v instanceof spiggEntity ? false

module.exports.Mapper = spiggMapper