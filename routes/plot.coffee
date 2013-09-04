Snippet = require '../core/snippet'

module.exports = (app) ->
  app.get '/plot', (req, res) ->
    if not req.user
      return res.redirect '/404'
    res.render 'plot'