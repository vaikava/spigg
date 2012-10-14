assert = require("assert")
sizeOf = (obj) ->
  size = 0
  key = undefined
  for key of obj
    size++ if obj.hasOwnProperty(key)
  size


describe "spigg.js", ->
  
  describe "spiggEntity", ->
    
    user = require("./fixtures").User
    name = "John Doe"
    newname = "Jane Doe"
    
    u = new user
    
    it "Has all methods present", ->
      assert.equal(typeof u.set,        "function")
      assert.equal(typeof u.get,        "function")
      assert.equal(typeof u.unset,      "function")
      assert.equal(typeof u.reset,      "function")
      assert.equal(typeof u.toJSON,     "function")
      assert.equal(typeof u.toString,   "function")
      assert.equal(typeof u.toModifier, "function")
      assert.equal(typeof u.clear,      "function")
    
    it "Internal constructor gets called", ->
      u = new user name: name
      assert.equal u.status, "Initialized"
      
    describe "SET, GET, UNSET, RESET & CLEAR", ->
      u = new user name: name
      
      it "Default data exists", ->
        assert.equal u.data.country, "Sweden"
        
      it "Data was set through constructor", ->
        assert.equal u.data.name, name

      it "Default data was respected", ->
        assert.equal u.data.country, "Sweden"
        
      it "Gets data by key", ->
        assert.equal u.get("country"), "Sweden"
        
      it "Gets all data", ->
        obj = u.get()
        assert.equal sizeOf(obj), 3
        assert.equal obj.country, "Sweden"
          
      it "Sets data by key/value", ->
        u.set "name", newname
        assert.equal u.data.name, newname
      
      it "Unsets value by key", ->
        u.unset("name")
        assert.equal u.get "name", null
        assert.equal sizeOf(u.get()), 2

      it "Stringifies propertly", ->
        u.unset("meta")
        str = JSON.stringify(country: "Sweden")
        assert.equal u.toJSON(), str
        assert.equal u.toString(), str
        
      it "Resets data back to defaults", ->
        u.set "name", name
        u.reset()
        obj = u.get()
        
        assert.equal sizeOf(obj), 2
        assert.equal u.get "name", null
        assert.equal u.get("country"), "Sweden"
        assert.equal obj.country, "Sweden"
        
      it "Can set by object", ->
        u = new user
        u.set age: 20, town: "Stockholm"
        assert.equal sizeOf(u.get()), 4
        assert.equal u.get("age"), 20
        assert.equal u.get("town"), "Stockholm"
      
      it "Can clear data", ->
        u.clear()
        assert.equal sizeOf(u.get()), 0

      it "Can set data through constructor without defaults", ->
        u = new user(name: name, true)
        assert.equal sizeOf(u.get()), 1
        assert.equal u.data.name, name
        assert.equal u.data.country, null

      it "Can set only allowed fields", ->
        u = new user(name: name, friends: true, followers: true, notAllowed: true)
        assert.equal sizeOf(u.get()), 4
        assert.equal u.get("friends"), null # friends is disabled
        assert.equal u.get("followers"), true # followers is allowed
        assert.equal u.get("notAllowed"), null # notAllowed is not specified
     
      it "Can set dot-notated fields", ->
        u = new user
        d = new Date()
        u.set "meta.last_loggedin", d
        assert.ok require("util").isDate(u.get("meta").last_loggedin)
      
      it "Can get dot-notated fields", ->
        u = new user
        assert.ok u.get("meta.last_loggedin") isnt null
        assert.ok require("util").isDate(u.get("meta.last_loggedin"))
      
    describe "Modification of data", ->
      
      it "Can modify by closure", ->
        u = new user name: name
        u.toModifier((obj)->
          obj.name = name+name
          obj
        )
        
        assert.equal u.get("name"), name+name
      
      it "Can set data with custom setters", ->
        u = new user name: name, email: "JOHN@EXAMPLE.ORG"
        assert.equal u.get("name"), name
        assert.equal u.get("email"), "john@example.org"
        assert.equal u.get("email_md5"), "4af4e151ecbc79407c07ad040862465c"
        assert.equal sizeOf(u.get()), 5
        
      it "Custom setters apply when using dot notation", ->
        u = new user
        u.set("meta.votes", 12000)
        assert.equal u.get("meta").votes, 12
        

  
  describe "spiggMapper", ->
    mapper = require("./fixtures").UserMapper
    user = require("./fixtures").User
    mapper = new mapper
    user = new user name: "John Doe"
    
    it "Can validate entity", ->
      assert.ok(mapper.save(user))
      assert.ok(!mapper.save({k: "I AM ZE OBJECT"}))
      assert.ok(!mapper.save("I AM ZE STRING"))
      assert.ok(!mapper.save(["I AM ZE ARRAY"]))