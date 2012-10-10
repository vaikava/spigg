s = require("../lib/spigg.coffee")
class User extends s.Entity
  defaults: 
    country: "Sweden"
   
  fields:
    name:      true
    friends:   false
    town:      true
    age:       true
    followers: true
    email:     true
    
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

class UserModel extends s.Model
   save: (doc) ->
    return @isEntity doc

module.exports.User = User
module.exports.UserModel = UserModel