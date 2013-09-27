db = require './Db'
{ObjectID} = db
DatePattern = require './DatePattern'

hashtagPattern = /#\w+/g

###
  @class Task
###
class Task
  ###*
    @field _id {ObjectID}
    @field owner {ObjectID}
    @field title {string}
    @field description {string}
    @field hashtags {Array(String)}
    @field start {Date or "none"} datetime when this event starts or task can start
    @field end {Date or "none"} datetime when this event ends or task is due
    @field type {string} Either 'event' or 'task'
    @field blockedBy {Array(ObjectID)} List of ObjectIDs for tasks that are blocking this one
    @field blockerFor List of ObjectIDs for tasks that this one is blocking
    @field status {String} one of (blocked|ready|inprogress|complete)
    @field recurs {undefined or DatePattern} if this task recurs, the DatePattern that
        describes the repetition of this task
    @field recurring {undefined or Task} if this is an instance of a recurring task,
        the first task in the set
  ###

  ###*
    @constructor
  ###
  constructor: (config) ->
    {@_id, @owner, @title, @description, @hashtags} = config
    {@start, @end, @type, @blockedBy, @blockerFor, @status} = config
    @title ?= ''
    @description ?= ''
    @start ?= 'none'
    @end ?= 'none'
    @type ?= 'event'
    @blockedBy ?= []
    @blockerFor ?= []
    @status ?= 'ready'
    @hashtags ?= []
    if config.recurs?
      {@recurs} = config
      @recurs = new DatePattern @recurs
    if config.recurring? then {@recurring} = config


  pickle: ->
    taskData =
      owner: @owner
      title: @title ? ''
      description: @description ? ''
      start: @start ? 'none'
      end: @end ? 'none'
      type: @type ? 'event'
      blockedBy: @blockedBy
      blockerFor: @blockerFor
      status: @status
      hashtags: @hashtags
    if @_id then taskData._id = @_id
    if @recurs then taskData.recurs = @recurs
    taskData

  process: ->
    newTags = @title.match hashtagPattern
    if newTags then for tag in newTags
      tag = tag.replace /^#/, ''
      if tag not in @hashtags
        @hashtags.push tag
    newTags = @description.match hashtagPattern
    if newTags then for tag in newTags
      tag = tag.replace /^#/, ''
      if tag not in @hashtags
        @hashtags.push tag

  ###*
    @method save
  ###
  save: (callback) ->
    taskData = @pickle()
    db.collection 'tasks', (err, cxn) ->
      cxn.save taskData,
        safe: true
      , (err) ->
        callback err

  del: (callback) ->
    db.collection 'tasks', (err, cxn) =>
      cxn.remove
        _id:@_id
      ,
        safe: true
      , (err, result) =>
        callback err


Task.getAllPicklesForUser = (user, callback) ->
  db.collection 'tasks', (err, cxn) ->
    cxn.find({owner:user._id}).sort(start:1).toArray (err, docs) ->
      if err then callback err
      snippets = docs
      callback null, snippets


Task.getAllForUser = (user, callback) ->
  Task.getAllPicklesForUser user, (err, docs) ->
    if err then callback err
    tasks = for doc in docs
      new Task doc
    callback null, tasks


Task.getByUserAndId = (user, id, callback) ->
  id = new ObjectID id
  db.collection 'tasks', (err, cxn) ->
    cxn.find(owner:user._id, _id:id).toArray (err, docs) ->
      if err then callback err
      if docs.length is 0 then callback 'no such animal'
      snippet = docs[0]
      snippet = new Task snippet
      callback null, snippet


module.exports = Task