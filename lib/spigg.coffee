class spiggEntity
  constructor: (d, defs) ->
    @data = {}
    @default_val = @default_val ? null
    @_setDefaults() if @defaults and !defs
    @fields = @fields ? {}
    @set(d)

  _setDefaults: ->
    @data[k] = v for k, v of @defaults if @defaults isnt {}
    @
    
  get: (k) ->
    return @data unless k
    @data[k] ? @default_val
    
  set: (k, v) ->
    return @setObject(k) unless v
    self = this
    
    ucfirst = (str) -> str.substr(0, 1).toUpperCase() + str.substr(1)
    
    if typeof @['_set'+ ucfirst(k)] is 'function'
      @["_set" + ucfirst(k)] v, @data, (str) ->
        self.data[k] = str
    else 
      if Object.keys(@fields).length >= 1
        @data[k] = v if @fields[k]
      else
        @data[k] = v
    @
  
  setObject: (o) ->
    for k, v of o
      @set(k, v)
    @
  
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
    
module.exports.Entity = spiggEntity

class spiggModel
  isEntity: (v) ->
    v instanceof spiggEntity ? false

module.exports.Model = spiggModel