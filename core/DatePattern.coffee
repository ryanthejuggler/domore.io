db = require './Db'

class DatePattern
  ###*
    @field start {Date} the start of this pattern
    @field end {Date} the end of this pattern
    @field type {String} type of pattern
    @field matches {Array} array to match, depends on type
  ###
  constructor: (config) ->
    {@start, @end, @type, @matches} = config

  ###*
    @method matchesDate
    Returns whether or not the passed Date matches this pattern.
    @param date {Date}
    @returns {boolean}
  ###
  matchesDate: (date) ->
    date = DatePattern.roundToDate date
    switch @type
      when 'weekly' then return date.getUTCDay() in @matches
      when 'monthly' then return date.getUTCDate() in @matches
      when 'daily' then return yes
      else return no

  getInstancesInRange: (start, end) ->
    start = DatePattern.roundToDate(start)
    end = DatePattern.roundToDate(end)+864e5
    if +start < +@start then start = @start
    if +end > +@end then end = @end
    switch @type
      when 'daily'
        return (new Date(i) for i in [+start..+end] by 864e5)
      when 'weekly'
        out = []
        for i in [+start..+end] by 864e5
          if new Date(i).getUTCDay() in @matches
            out.push new Date(i)
        return out
      when 'monthly'
        out = []
        for i in [+start..+end] by 864e5
          if new Date(i).getUTCDate() in @matches
            out.push new Date(i)
        return out
      else
        return []

  toSerializable: () ->
    start: @start
    end: @end
    type: @type
    matches: @matches



DatePattern.roundToDate = (d) ->
  new Date d.getUTCFullYear(), d.getUTCMonth(), d.getUTCDate()

module.exports = DatePattern
