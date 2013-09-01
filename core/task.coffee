db = require './db'
{ObjectID} = db

###
  @class Task
###
class Task
  ###*
    @field _id {ObjectID}
    @field owner {ObjectID}
    @field title {string}
    @field description {string}
    @field start {Date or "none"}
    @field end {Date or "none"}
    @field type {string} Either 'event' or 'task'
    @field blockedBy {Array(ObjectID)} List of ObjectIDs for tasks that are blocking this one
    @field blockerFor List of ObjectIDs for tasks that this one is blocking
    @field complete {boolean}
  ###

  ###*
    @constructor
  ###
  constructor: (config) ->
    {@_id, @owner, @title, @description, @start, @end, @type, @blockedBy, @blockerFor, @complete} = config
    @title ?= ''
    @description ?= ''
    @start ?= 'none'
    @end ?= 'none'
    @type ?= 'event'
    @blockedBy ?= []
    @blockerFor ?= []
    @complete ?= no

  ###*
    @method save
  ###
  save: (callback) ->
    taskData =
      owner: @owner
      title: @title ? ''
      description: @description ? ''
      start: @start ? 'none'
      end: @end ? 'none'
      type: @type ? 'event'
      blockedBy: @blockedBy
      blockerFor: @blockerFor
      complete: @complete
    if @_id then taskData._id = @_id
    db.collection 'tasks', (err, cxn) ->
      cxn.save taskData,
        safe: true
      , (err) ->
        callback err
