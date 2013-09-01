fs = require 'fs'
md = require('node-markdown').Markdown

module.exports = (app) ->
  app.get '/changelog', (req, res) ->
    fs.readFile 'changelog.md', 'utf8', (err, data)->
      res.render 'md',
        pageBody: err ? md data