s = require("../lib/spigg.coffee")

class User extends s.Entity
  defaults: 
    country: "Sweden"
    
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
  
  # Custom setter for profile
  setProfile: (str) ->
    str.replace(/&/g, '&amp;').replace(/>/g, '&gt;')
    str.replace(/</g, '&lt;').replace(/"/g, '&quot;');
    @data["profile"] = str


class UserModel extends s.Model
   save: (doc) ->
    return @isEntity doc

module.exports.User = User
module.exports.UserModel = UserModel