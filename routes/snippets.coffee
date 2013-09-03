Snippet = require '../core/snippet'
jade = require 'jade'

ajaxUI =
  makePanel: (data, callback) -> jade.renderFile 'views/partials/panel.jade', data, callback

module.exports = (app) ->
  app.post '/ajax/snippets/new', (req, res) ->
    unless req.user
      res.json
        error: 'not logged in'
      return
    snippet = new Snippet
      originalEntry: req.body.entry
      owner: req.user._id
      ts: new Date
      location: req.body.location
    snippet.handleAndSave (err) ->
      if err then res.json
        error: err
      res.json
        ok: true
        id: snippet._id
        entry: snippet.originalEntry
        data: snippet.data ? snippet.originalEntry
        handler: snippet.handler
        panel: ajaxUI.makePanel
          content: snippet.data ? snippet.originalEntry
          handler: snippet.handler
          hashtags: snippet.hashtags
          ts: snippet.ts


  app.get '/ajax/snippets/get', (req, res) ->
    unless req.user then res.json
      error: 'not logged in'
    Snippet.getAllForUser req.user, (err, data) ->
      if err then res.json
        err: err
      res.json
        ok: true
        panels: for snippet in data then ajaxUI.makePanel
          content: snippet.data ? snippet.originalEntry
          handler: snippet.handler
          hashtags: snippet.hashtags
          ts: snippet.ts
