crypto = require 'crypto'
User = require '../core/user'

exports.register = (req, res) ->
  res.render 'register',
    title: 'register'

exports.doRegister = (req, res) ->
  if req.body.passwordAgain isnt req.body.password
    req.flash 'error', "passwords don't match"
    return res.redirect '/register'
  username = req.body.username
  md5 = crypto.createHash 'md5'
  password = md5.update(req.body.password).digest 'base64'
  User.getByName username, (err, user) ->
    if user
      req.flash 'error', "user exists"
      return res.redirect '/register'
    user = new User
      username: username
      password: password
      joined: new Date
    user.save (err) ->
      res.redirect '/'