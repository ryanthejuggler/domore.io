Snippet = require '../core/snippet'

module.exports = (app) ->
  app.get '/plot', (req, res) ->
    if not req.user
      req.flash 'warning', 'must be logged in to view plots'
      return res.redirect '/404'
    res.render 'plot',
      user: req.user