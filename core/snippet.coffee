db = require './db'
{ObjectID} = db
handleJson = require '../handlers/json'

###*
  @class Snippet
###
class Snippet
  ###*
    @field _id {ObjectID}
    @field owner {ObjectID}
    @field originalEntry {string}
    @field ts {Date} timestamp
    @field data {Object}
    @field location {pos:{lat:number, lon:number, sigma:number}, alt:{value:number, sigma:number}}
    @field hashtags {Array(string)}
    @field handler {string}
  ###
  constructor: (config)->
    {@_id, @owner, @originalEntry, @ts, @location, @data, @hashtags, @handler} = config

  ###*
    @method pickle
  ###
  pickle: ->
    snipData =
      owner: @owner
      originalEntry: @originalEntry
      ts: @ts
      location: @location
      data: @data
      hashtags: @hashtags
      handler: @handler
    if @_id then snipData._id = @_id
    snipData

  ###*
    @method save
  ###
  save: (callback) ->
    snipData = @pickle()
    db.collection 'snippets', (err, cxn) =>
      cxn.save snipData,
        safe: true
      , (err, result) =>
        @_id = result._id
        callback err

  del: (callback) ->
    db.collection 'snippets', (err, cxn) =>
      cxn.remove
        _id:@_id
      ,
          safe: true
      , (err, result) =>
          callback err

  handle: (callback) ->
    entry = @originalEntry
    handled = false
    if entry.match /^\/\//
      @data = entry.substr(2).trim()
      @handler = 'note'
      handled = true
    else
      try
        q = handleJson entry
        [tag, @data, @hashtags] = q
        @handler = tag
        handled = true
      catch err
        console.log err
        @data = @originalEntry
        @handler= 'data'
    callback null, handled

  handleAndSave: (callback) ->
    @handle (err) =>
      @save callback


Snippet.getAllForUser = (user, callback) ->
  Snippet.getAllPicklesForUser user, (err, docs) ->
    if err then callback err
    snippets = for doc in docs
      new Snippet doc
    callback null, snippets

Snippet.getByUserAndId = (user, id, callback) ->
  id = new ObjectID id
  db.collection 'snippets', (err, cxn) ->
    cxn.find(owner:user._id, _id:id).toArray (err, docs) ->
      if err then callback err
      if docs.length is 0 then callback 'no such animal'
      snippet = docs[0]
      snippet = new Snippet snippet
      callback null, snippet

Snippet.getAllPicklesForUser = (user, callback) ->
  db.collection 'snippets', (err, cxn) ->
    cxn.find({owner:user._id}).sort(ts:1).toArray (err, docs) ->
      if err then callback err
      snippets = docs
      callback null, snippets


Snippet.getAllPicklesForUserAndType = (user, type, callback) ->
  db.collection 'snippets', (err, cxn) ->
    cxn.find({owner:user._id,handler:type}).sort(ts:1).toArray (err, docs) ->
      if err then callback err
      snippets = docs
      callback null, snippets


module.exports = Snippet