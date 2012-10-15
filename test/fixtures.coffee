s = require("../lib/spigg.coffee")
class User extends s.Entity
  defaults: 
    country: "Sweden"
    followers: []
    meta:
      created: new Date()
   
  fields:
    name:      true
    friends:   false
    town:      true
    age:       true
    followers: true
    email:     true
    
  init: ->
    @status = "Initialized"
    
  isAdult: ->
    switch @data.country
      when "Sweden"
        return true if @data.age >= 18
      when "UK"
        return true if @data.age >= 16        
      else 
        return false

  isValid: ->
    return false unless @data.name
    return false unless @isAdult()
    return true
  
  # Custom setter for email adress that also
  # adds a md5 representation of our email to
  # display gravatars.
  _setEmail: (str, obj) ->
    str = String(str).toLowerCase()
    obj.email_md5 = "4af4e151ecbc79407c07ad040862465c"
    str

  # Custom setter for nested object that is accessed
  # through dot notation: set("meta.", val)
  _setMeta_votes: (n) ->
    n/1000

  _setFollowers: (str, obj) ->
    obj.followers = obj.followers ? []
    obj.followers.push str
    false
        
class UserMapper extends s.Mapper
   save: (doc) ->
    return @isEntity doc

module.exports.User =       User
module.exports.UserMapper = UserMapper