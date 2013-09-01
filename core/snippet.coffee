db = require './db'
{ObjectID} = db
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
    @field location {lat:number, lon:number, uncty:number, alt:number, altUncty:number}
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
        @id = result._id
        callback err

  handle: (callback) ->
    entry = @originalEntry
    handled = false
    if entry.match /^\/\//
      @data = entry.substr(2).trim()
      @handler = 'note'
      handled = true
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

Snippet.getAllPicklesForUser = (user, callback) ->
  db.collection 'snippets', (err, cxn) ->
    cxn.find({owner:user._id}).sort(ts:1).toArray (err, docs) ->
      if err then callback err
      snippets = docs
      callback null, snippets


module.exports = Snippet