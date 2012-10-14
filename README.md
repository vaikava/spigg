spigg.js
============
spigg.js brings the *Data mapper* pattern to node.js, giving you database-
agnostic **mappers** for data persistence and **entities** for business
logic, to ensure DRY principles and testability across your application.

spigg.js is lightweight by design and only ships with a handful of methods
to get, set, unset and clear your data and thereby leaves everything else
up to you.

Read about the *data mapper* pattern [here](http://martinfowler.com/eaaCatalog/dataMapper.html).


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

With *spigg* you put all your code that persist data into `mappers` and the
actual business logic such as data validation and filtering into `entities`. 

Imagine entities as being unaware of both the origin and destination of data.
Entities should focus on creating valid data for your application.

Mappers on the other hand does store your data and rely fully upon said 
entities to have dealt with validation and filtering of data. 

As long as you stick to your mappers for accessing and persisting data across
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
	  
	  module.exports = User
	  
	# /mappers/User.coffee
	class UserMapper extends s.Mapper
   
      save: (doc, fn) ->
        require("db").collection("users").save doc

	module.exports = UserMapper

	# /app.js
	express =    require('express')
    user =       require("./entities/User.coffee")
	userMapper = require("./mappers/User.coffee")
	app =        express()
	
	app.post "/users", (req, res) ->
	  user = new User req.body
	  userMapper.save user if user.isValid() 
	  res.send "", 201

    app.listen(80)


Documentation: spiggEntity
============
Use the `spiggEntity` by extending it as shown below:
	
	s = require("spigg")
	
	# Setup a entity for our user
	class User extends s.Entity
	
	  # Create a init method that gets invoked when
	  # constructing the class
	  init: ->
	  	# Do stuff on init here
	
	  # Set defaults for values
	  defaults:
	    country: "Sweden"
	    
	  # Specify fields that should ONLY be allowed in this
	  # entity. Non-specified fields will not appear in the
	  # entity. Note that without the "fields"-property shown
	  # below, all fields are allowed.
	  fields:
	  	name:    true
	  	age:     true
	  	country: true
	    
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
    
    # Get nested properties with dot notation
    u.get("meta.created") # => Sun Oct 14 2012 18:55:52 GMT+0000 (UTC)
    
    # Set nested properties with dot notation
    u.set("meta.votes", 12000)
    
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

    # Create a custom setter that is automatically called whenever
    # the **email** property is updated. This setter *MUST* return the
    # value to be used for the property.
    #
    # The actual data object is also passed as a reference, to allow direct 
    # modification of the data object for full freedom.  
    #
    #  - Note the underscore (_) in beginning of the setter function's
    # name and that first character must of property name must be
    # capitalized for the auto setter to work.
    #
	_setEmail: (str, obj, callback) ->
	  # Always store emails in lowercase
	  str = String(str).toLowerCase()
	  
	  # Add a md5 version of our email to our data object
	  # to allow getting the users gravatar.
	  obj.email_md5 = crypto.createHash('md5').update(str).digest("hex")
	   
	  return str


Documentation: spiggMapper
============
`spiggMapper` is a blank slate containing only the the `isEntity`-method,
which is used to ensure that data that is passed into the mapper origins
from a class that extends `spiggEntity`. Use the `isEntity`-method
as shown below:
 
	class userMapper extends s.Mapper
	  save: (user) ->
      	db.save user if @isEntity user

Roadmap
============
* Support for revisions


License
============
See `LICENSE` file.

> Copyright (c) 2012 Joakim B

