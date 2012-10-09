class spiggEntity
  constructor: (d, defs) ->
    @data = {}
    @default_val = @default_val ? null
    @_setDefaults() if @defaults and !defs
    @set(d)

  _setDefaults: ->
    @data[k] = v for k, v of @defaults if @defaults isnt {}
    @
    
  get: (k) ->
    return @data unless k
    @data[k] ? @default_val
    
  set: (k, v) ->
    @data[k] = v if k and v
    @data[_k] = _v for _k, _v of k unless v
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