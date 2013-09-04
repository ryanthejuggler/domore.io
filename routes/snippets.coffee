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
      if err
        res.json
          error: err
        return
      res.json
        ok: true
        id: snippet._id
        entry: snippet.originalEntry
        data: snippet.data ? snippet.originalEntry
        handler: snippet.handler
        panel: ajaxUI.makePanel
          snippet: snippet
          content: snippet.data ? snippet.originalEntry
          handler: snippet.handler
          hashtags: snippet.hashtags
          ts: snippet.ts


  app.get '/ajax/snippets/get', (req, res) ->
    unless req.user
      res.json
        error: 'not logged in'
      return
    Snippet.getAllForUser req.user, (err, data) ->
      if err then res.json
        error: err
      res.json
        ok: true
        panels: for snippet in data then ajaxUI.makePanel
          snippet: snippet
          content: snippet.data ? snippet.originalEntry
          handler: snippet.handler
          hashtags: snippet.hashtags
          ts: snippet.ts


  app.post '/ajax/snippets/delete', (req, res) ->
    unless req.user
      res.json
        error: 'not logged in'
      return
    Snippet.getByUserAndId req.user, req.body.id, (err, snip) ->
      snip.del (err)->
        if err
          res.json
            error: err
          return
        res.json
          ok: true
