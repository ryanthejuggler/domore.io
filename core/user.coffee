db = require './db'
{ObjectID} = db
crypto = require 'crypto'

###*
  @class User
###
class User
  ###* 
    @field name
    @field username
    @field providers
    @field profile
  ###

  ###*
    @constructor 
  ###
  constructor: (config) ->
    if config?
      {@_id, @username, @name, @providers, @profile, @password, @joined} = config

  ###* 
    @method setBasicsFromPassport 
  ###
  setBasicsFromPassport: (profile) ->
    @profile = profile
  ###* 
    @method save 
  ###
  save: (callback) ->
    user =
      name: @name
      providers: @providers
      profile: @profile
      password: @password
      username: @username
    if @_id then user._id = @_id
    db.collection 'users', (err, cxn) ->
      cxn.save user,
        safe: true
      , (err, user) ->
        callback err, user

###*
  @method load
  @static
###
User.getByLogin = (provider, id, callback) ->
  db.collection 'users', (err,cxn) ->
    cxn.findOne
      'providers.$.provider': provider
      'providers.$.id': id
    ,
      safe: true
    , (err, userData) ->
        callback err, new User userData

User.getByName = (username, callback) ->
  db.collection 'users', (err, cxn) ->
    cxn.findOne
      username:username
    ,
        safe: true
    , (err, userData) ->
        if userData
          callback err, new User userData
        else
          callback err

User.getByUserPass = (username, password, callback) ->
  md5 = crypto.createHash 'md5'
  password = md5.update(password).digest 'base64'
  db.collection 'users', (err, cxn) ->
    cxn.findOne
      username:username
      password:password
    ,
      safe: true
    , (err, userData) ->
      if userData
        callback err, new User userData
      else
        callback err

User.getByID = (id, callback) ->
  db.collection 'users', (err, cxn) ->
    cxn.findOne
      _id:new ObjectID id
    , (err, userData) ->
      console.log userData
      if userData
        callback err, new User userData
      else
        callback err


module.exports = User
