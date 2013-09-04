crypto = require 'crypto'
User = require '../core/user'

exports.register = (req, res) ->
  res.render 'register',
    title: 'register'

exports.doRegister = (req, res) ->
  if req.body.passwordAgain isnt req.body.password
    req.flash 'danger', "passwords don't match"
    return res.redirect '/register'
  if req.body.invite not in ['RUNKEEPER-2106']
    req.flash 'danger', 'invalid invite code "'+req.body.invite+'"'
    return res.redirect '/register'
  username = req.body.username
  md5 = crypto.createHash 'md5'
  password = md5.update(req.body.password).digest 'base64'
  User.getByName username, (err, user) ->
    if user
      req.flash 'danger', "user by that username already exists"
      return res.redirect '/register'
    user = new User
      username: username
      password: password
      joined: new Date
    user.save (err) ->
      req.flash 'success', 'welcome, '+user.username+'! <a class="btn btn-info btn-sm" href="/login">log in &raquo;</a>'
      res.redirect '/'