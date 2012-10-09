spigg.js
============
spigg.js is a simple server-side data wrapper that lets you decouple
your business logic from data persistence, to allow both code reusage and 
modularity.

spigg.js gives you **models** for data persistence and **entities** for
business logic, the cornerstones for DRY principles and modularity.


Installation
============
	
	npm install spigg


Usecase
============
You have an application that lets users signup. For each signup, you need to
apply app-specific validation rules to the user-submitted data to create a
`user` that you can persist to the database of your choice.

Mashing this together in one block is great for rapid prototyping, but problems
quickly arise when you need to unit test your code, or work with `users` as
a resource from elsewhere in your application.
If you haven't thought about separation of concerns, you quickly end up doing
integration testing instead of actual unit testing and any DRY principles
can be forgotten soon.

With *spigg* you put all your code that persist data into `models` and the
actual business logic such as data validation and filtering into `entities`. 

Imagine entities as being unaware of both the origin and destination of data.
Entities should focus on creating valid data for your application.

Models on the other hand does store your data and rely fully upon said 
entities to have dealt with validation and filtering of data. 

As long as you stick to your models for accessing and persisting data across
your application, using multiple databases and building cache-layers inside
or on top of your models should be simple.

 
Example
============
	# /entities/User.coffee
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
	  
	  module.exports = User
	  
	# /models/User.coffee
	db = require("mongo")
	class UserModel extends s.Model
   
      save: (doc, fn) ->
        db.users.save doc

	module.exports = UserModel

	# /app.js
	express =   require('express')
    user =      require("./entities/User.coffee")
	userModel = require("./models/User.coffee")
	app =       express()
	
	app.post "/users", (req, res) ->
	  user = new User req.body
	  userModel.save user if user.isValid() 
	  res.send "", 201

    app.listen(80)


Documentation: spiggEntity
============
Use the `spiggEntity` by extending it as shown below:

	
	s = require("spigg)
	
	# Setup a entity for our user
	class User extends s.Entity
	  # Set defaults for values
	  defaults:
	    country: "Sweden"
	    
	# Create user by passing arguments to the constructor 
	#  - Note that user will also contain inherited 
	#    default values from above
	u = new user(name: "John Doe") # => {country: "Sweden", name: "John Doe"}
	
	# Create user without any inherited default
	# properties. Useful for updating already stored data.
	u = new user(name: "John Doe", true) # => {name: "John Doe"}
	
	# Set name by calling the set method
	u.set("name", "Jane Doe")
    
    # Get property from entity by name
    u.get("name") # => "Jane Doe"
    
    # Get all properties from entity
    u.get() # => {country: "Sweden", name: "John Doe"}
    
    # Unset a property
    u.unset("country")
    u.get() # => {name: "John Doe"}
    
    # Reset the user back to default values
    #  - Note that name is missing now
    u.reset()
    u.get() # => {country: "Sweden"}

    # Empties *ALL* properties from the entity
    u.clear()
    u.get() # => {}
    
    # Get the JSON representation of our object
    # - Note: toString() & toJSON() does the same thing
    u.toJSON() => {"country":"Sweden", name: "John Doe"}
    
    # Modify the properties of our entity with a closure
    # - Note: The modifier object will be passed the complete
    #   current properties and should return it after modification
    #   to perform modification of values.
    u.toModifier((obj) ->
      # Modify object here before returing it
      return obj
    )


Documentation: spiggModel
============
`spiggModel` is a blank slate containing the the `isEntity`-method,
which is used to ensure that data that is passed into the model origins
from a class that extends `spiggEntity`.
 
	# Invoke the this.isEntity()-method to do check
	class UserModel extends s.Model
	  save: (user) ->
      	db.save user if @isEntity user


License
============
See `LICENSE` file.

> Copyright (c) 2012 Joakim B

