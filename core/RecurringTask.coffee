db = require './Db'
{ObjectID} = db

###
@class RecurringTask
###

class RecurringTask extends Task
  ###*
  @field _id {ObjectID}
  @field owner {ObjectID}
  @field firstInstance {ObjectID}
  @field datePattern {DatePattern}
  @field exceptions {Array(Task)}

  ###
  constructor: (config) ->
