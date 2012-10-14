class spiggEntity
  constructor: (d, defs) ->
    @data = {}
    @default_val = @default_val ? null
    @_setDefaults() if @defaults and !defs
    @fields = @fields ? {}
    #events =  require("events")
    #crypto =  require("crypto")
    #@events = new events.EventEmitter()
    #@events.on "change", @_setChanged
    #@revision = 0
    #@revisions = {}
    @_setObject(d) if d
    @init() if typeof @init is 'function'

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
    @data[k] = v for k, v of @defaults if @defaults isnt {}
    @

  _set: (k, v) ->
    v = @_callCustomSetter(k, v)
    
    if @fields isnt {}
      @data[k] = v if @fields[k]
    else
      @data[k] = v
    
   _setObject: (o) ->
     @_set(k, v) for k, v of o
  
  _callCustomSetter: (k, v) ->
    method = '_set' + k.substr(0, 1).toUpperCase() + k.substr(1)
    v = @[method](v, @.data) if typeof @[method] is 'function'
    v
  
  _getDotNotated: (k) ->
    walker = (o, i) -> o[i] # ? @default_val
    k.split(".").reduce walker, @data

  _setDotNotated: (k, v) ->
    arr = k.split(".")
    _k = arr[arr.length - 1]
    
    v = @_callCustomSetter(arr.join("_"), v)
  
    walker = (o, i) ->
      o[i] = v if i is _k
      o[i]
  
    arr.reduce walker, @data
    
  _setChanged: (context) ->
    context.revision++
    md5 = crypto.createHash('md5').update(JSON.stringify context.data).digest("hex")
    context.revisions[context.revision] = context.data
    context.changed = true
    
module.exports.Entity = spiggEntity

class spiggMapper
  isEntity: (v) ->
    v instanceof spiggEntity ? false

module.exports.Mapper = spiggMapper