Task = require '../core/task'
jade = require 'jade'

ajaxUI =
  makePanel: (data, callback) -> jade.renderFile 'views/partials/todo.jade', data, callback


module.exports = (app) ->
  app.get '/todo', (req, res) ->
    if not req.user
      req.flash 'warning', 'must be logged in to view to-do list'
      return res.redirect '/login'
    res.render 'todo'

  app.post '/ajax/todo/new', (req, res) ->
    unless req.user
      res.json
        error: 'not logged in'
      return
    task = new Task
      title: req.body.entry
      owner: req.user._id
      created: new Date
      location: req.body.location
    task.process()
    task.save (err) ->
      if err
        res.json
          error: err
        return
      res.json
        ok: true
        id: task._id
        entry: task.title
        data: task.title
        panel: ajaxUI.makePanel
          task: task
          id: task._id
          content: task.description
          title: task.title
          hashtags: task.hashtags
          ts: if task.type is 'event' then task.start else task.end


  app.get '/ajax/todo/get', (req, res) ->
    unless req.user
      res.json
        error: 'not logged in'
      return
    Task.getAllForUser req.user, (err, data) ->
      if err then res.json
        error: err
      res.json
        ok: true
        panels: for task in data then ajaxUI.makePanel
          task: task
          id: task._id
          content: task.description
          title: task.title
          hashtags: task.hashtags
          ts: if task.type is 'event' then task.start else task.end


  app.post '/ajax/todo/delete', (req, res) ->
    unless req.user
      res.json
        error: 'not logged in'
      return
    Task.getByUserAndId req.user, req.body.id, (err, snip) ->
      unless snip
        res.json
          error: 'no such task'
        return
      snip.del (err)->
        if err
          res.json
            error: err
          return
        res.json
          ok: true

  app.post '/ajax/todo/all', (req, res) ->
    unless req.user
      res.json
        error: 'not logged in'
      return
    Task.getAllPicklesForUserAndType req.user, req.body.type, (err, data) ->
      if err
        res.json
          error: err
      return
      res.json
        ok: true
        data: data
