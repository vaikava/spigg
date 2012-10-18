s = require("../../lib/spigg.coffee")

class User extends s.Entity

  init: ->
    
    @fields =
      name:  true
      email: true
      meta:
        lastlogin: true

    @defaults =
      friends: []

    @setters = 
      name: (str) ->
        str.toLowerCase()

class UserMapper extends s.Mapper
   #save: (doc) ->
   # return @isEntity doc

module.exports.User =       User
module.exports.UserMapper = UserMapper
