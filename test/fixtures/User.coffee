s = require("../../lib/spigg.coffee")

class User extends s.Entity

  init: ->
    
    @fields =
      name:  true
      email: true
      start: true
      end:   true
      meta:
        lastlogin: true

    @defaults =
      friends: []

    @setters = 
      name: (str) ->
        str.toLowerCase()
      
      start: (str, obj) ->
        obj.end = "end"
        return str
      
class UserMapper extends s.Mapper
   #save: (doc) ->
   # return @isEntity doc

module.exports.User =       User
module.exports.UserMapper = UserMapper
