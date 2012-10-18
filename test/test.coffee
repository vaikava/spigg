assert = require("chai").assert
User = require("./fixtures/User").User
spigg = require("../lib/spigg.coffee")
mapper = require("./fixtures/User").UserMapper

describe "spigg.js", ->
  
  describe "Separated methods", ->
    
    beforeEach ->
      @entity = new spigg.Entity

    it "_set works as expected by invoking custom setters", ->
    
      obj = 
        name: "JOHN DOE"
        ihaznosetter: "BRR"
        nested:
          email: "INFO@EXAMPLE.COM"  
      
      setters =
        name: (str) ->
          str.toLowerCase()
        nested:
          email: (str) ->
            str.toLowerCase()
      
      expected =
        name: "john doe"
        ihaznosetter: "BRR"
        nested:
          email: "info@example.com"
          
      assert.deepEqual @entity._set(obj, setters), expected
      
    it "_merge works as expected", ->
      o = @entity._merge({name: "John Doe"}, {email: "info@example.com"})
      assert.deepEqual o, name: "John Doe", email: "info@example.com"
    
    it "_merge overwrites props in second argument", ->  
      o = @entity._merge({name: "Jane Doe"}, {name: "John Doe"})
      assert.deepEqual o, name: "Jane Doe"
    
    it "_filter works correctly", ->
      
      obj =
        name: "John Doe"
        email: "info@example.com"
        nested:
          value:      []
          notAllowed: true
          
      allowed = 
        name:  true
        email: false
        nested:
          value: true
      
      # Email should not exist
      expected = 
        name:   obj.name
        nested: 
          value: []
      
      result = @entity._filter(obj, allowed)
      assert.deepEqual result, expected


  describe "Extending entity", ->
    
    beforeEach -> @u = new User
      
    it "Default data was set", ->
      assert.deepEqual @u.data, friends: [] 
      
    it "Can set data through constructor", ->
      @u = new User name: "John doe"
      assert.deepEqual @u.data, {friends: [], name: "john doe"}
    
    it "Can set by key/value", ->
      @u.set "name", "John Doe"
      assert.deepEqual @u.data, {friends: [], name: "john doe"}
    
    it "Can only set allowed properties", ->
      @u.set {key: "value", name: "John Doe", meta: email: "info@example.com"}
      assert.ok !@u.data.key
      assert.ok !@u.data.meta.email
    
    it "Set with empty object doesnt effect current data", ->
      @u.set({})
      assert.deepEqual @u.data, {friends: []}
      
    it "Can set from object", ->
      @u.set name: "John Doe"  
      assert.deepEqual @u.data, {friends: [], name: "john doe"}

    it "Can overwrite set properties", ->
      @u.set name: "John Doe"
      assert.equal @u.data.name, "john doe"
      @u.set name: "Jane Doe"
      assert.equal @u.data.name, "jane doe"
          
    it "Can get by key", ->
      @u.set "name", "John Doe"
      assert.equal @u.get("name"), "john doe"
    
    it "Get without arguments returns all properties", ->
      assert.deepEqual @u.get(), {friends: []}
      
    it "Can get nested properties by dot notation", ->
      d = new Date()
      @u.set meta: lastlogin: d
      assert.equal @u.get("meta.lastlogin"), d
      
    it "Missing properties return the default value", ->
      assert.equal @u.get "missingprop", null
      
    it "Can change the default value", ->
      @u.setDefaultValue(false)
      assert.equal @u.get("missingprop"), false

    it "Can unset properties", ->
      @u.unset "friends"
      assert.ok !@u.data.friends
      assert.lengthOf Object.keys(@u.get()), 0
            
    it "Can reset back to defaults", ->
      @u.set "name", "John Doe"
      assert.lengthOf Object.keys(@u.get()), 2
      @u.reset()
      assert.deepEqual @u.get(), {friends: []}
    
    it "Can clear out the entity", ->
      @u.set "name", "John Doe"
      assert.lengthOf Object.keys(@u.get()), 2
      @u.clear()
      assert.deepEqual @u.get(), {}  

  describe "Revisions", ->

    beforeEach -> @u = new User
    
    it "Setting properties creates revisions", ->
      @u.set name: "Jane Doe"
      assert.lengthOf @u.revisions, 1
      assert.deepEqual @u.revisions[0], @u.data

    it "Changing properties creates multiple revisions", ->
      @u.set name: "John Doe"
      @u.set name: "Jane Doe"
      assert.lengthOf @u.revisions, 2
      assert.equal @u.revisions[0].name, "john doe"
      assert.equal @u.revisions[1].name, "jane doe"

    it "Can get all revisions", ->
      @u.set name: "John Doe"
      @u.set name: "Jane Doe"
      assert.lengthOf @u.getRevision(),2
    
    it "Can get a specific revision by number", ->
      @u.set name: "John Doe"
      @u.set name: "Jane Doe"
      assert.equal @u.getRevision(0).name, "john doe"
    
    it "Can get a historic revision", ->
      @u.set name: "John Doe"
      @u.set name: "Jane Doe"
      assert.equal @u.getRevision(-1).name, "john doe"
            
  describe "spiggMapper", ->
    mapper = new mapper
    user = new User name: "John Doe"
    
    it "isEntity works as expected", ->
      assert.ok(mapper.isEntity(user))
      assert.ok(!mapper.isEntity({k: "I AM ZE OBJECT"}))
      assert.ok(!mapper.isEntity("I AM ZE STRING"))
      assert.ok(!mapper.isEntity(["I AM ZE ARRAY"]))
   
    it "hasData works as expected", ->
      assert.deepEqual mapper.hasData(user), friends: [], name: "john doe"
      