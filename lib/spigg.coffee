events =  require("events")
crypto =  require("crypto")

class spiggEntity
  constructor: (d, defs) ->
    @data = {}
    @default_val = @default_val ? null
    @_setDefaults() if @defaults and !defs
    @fields = @fields ? {}
    @events = new events.EventEmitter()
    @events.on "change", @_setChanged
    @revision = 0
    @revisions = {}
    @set(d)

  _setDefaults: ->
    @data[k] = v for k, v of @defaults if @defaults isnt {}
    @
    
  get: (k) ->
    return @data unless k
    @data[k] ? @default_val
    
  set: (k, v) ->
    return @setObject(k) unless v
    
    
    
  _set: (k, v, self) ->
    
    method = '_set' + k.substr(0, 1).toUpperCase() + k.substr(1)
    
    if typeof self[method] isnt 'function'
      if Object.keys(self.fields).length >= 1
        self.data[k] = v if self.fields[k]
      else
        self[k] = v
        
    else
    
      self[method](v, self.data, ->
        console.log "IN CALLBACK"
        self.events.emit "change", k, arguments[0]
        self.data[k] = arguments[0]
        console.log "args", arguments
      )

    ucfirst = (str) -> str.substr(0, 1).toUpperCase() + str.substr(1)
    
    if typeof @['_set'+ ucfirst(k)] is 'function'
      v = @['_set'+ ucfirst(k)](v, @.data)
    
    if Object.keys(@fields).length >= 1
      @data[k] = v if @fields[k]
    else
      @data[k] = v
    @

  set: (k, v) ->
    return @setObject(k) unless v
    customSetter = '_set'+k.substr(0, 1).toUpperCase()+k.substr(1)
    @events.emit "change", @
    
    if typeof @[customSetter] is 'function'
      @data[k] = @[customSetter] v, @data
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

  _setChanged: (context) ->
    context.revision++
    #md5 = crypto.createHash('md5').update(JSON.stringify context.data).digest("hex")
    context.revisions[context.revision] = context.data
    context.changed = true
    
module.exports.Entity = spiggEntity

class spiggModel
  isEntity: (v) ->
    v instanceof spiggEntity ? false

module.exports.Model = spiggModel